//
//  Configuration.swift
//  Configuration
//
//  Created by Renee Zuleta on 4/9/21.
//

import Foundation
import utilities

public struct Config{
    public var confFileURL:URL
    public var midiFileURL:URL
    public var rythmFileURL:URL
    public var sampleMidiFileURL:URL
    public var signatureString:String
    public var sigNum:UInt8
    public var sigDen:UInt8
    public var signatureEventInfo:[UInt8]
    public var bpmString:String
    public var bpm:UInt16
    public var resolutionString:String
    public var resolution:Double
    public var ticksPerMeasure:UInt8
    public var microSecPerTick:UInt32
    public var measureCountString:String
    public var measureCount:UInt8
    public var loopForEverString:String
    public var loop:Bool
    public var rithmPattern:UInt32
    public var rithmInstruments: [UInt8] // will default to 32 to allow max resolution
    public var midiParams: midiDefines
    
    public init(){
       //build the url we need to use for configuration file
        //midiFileURL = URL(string: "temp")!
        //confFileURL = URL(string: "temp")!
        confFileURL = getDocDirectory()
        confFileURL = makeDir(thisURL:confFileURL,dir:"config")
        midiFileURL = makeDir(thisURL:confFileURL,dir:"midi")
        rythmFileURL = makeDir(thisURL:confFileURL,dir:"rythm")
        sampleMidiFileURL = midiFileURL
        confFileURL.appendPathComponent("config.txt")
        midiFileURL.appendPathComponent("myMidi.midi")
        sampleMidiFileURL.appendPathComponent("sampleMidi.midi")
        rythmFileURL.appendPathComponent("myRythm.midi")
        signatureString = "4/4"
        sigNum = 4 //UInt8(setSignatureNumerator(sig: signatureString))
        sigDen = 4 //UInt8(setSignatureDenominator(sig: signatureString))
        signatureEventInfo = [0x04,0x02,0x18,0x98]  // event for sign 4/4
        bpmString = "120"
        bpm = 120
        resolutionString = "1/16"
        resolution = 1/16
        ticksPerMeasure = 16
        microSecPerTick = UInt32(1000000 * 60 / UInt32(bpm))
        measureCountString = "4"
        measureCount = 4
        loopForEverString = "0" //short for false
        loop = false
        rithmPattern = 0xF0001113 //nothe that ls bit is first
        // there will be ppqn * sig denominator slots
        //for now allocate 32, may increase later
        rithmInstruments = [46, // open high hat, offset 0 corresponds to bit 0
                           36, // bass drum 1
                           0,0,
                           36, // bass drum
                           0,0,0,
                           37, // sidestick
                           0,0,0,
                           36, // sidestick
                           0,0,0,
                           0,0,0,0,0,0,0,0,
                           0,0,0,0,36,36,36,36]
        midiParams = midiDefines()
        
       do{
            print("try to read ",confFileURL)
            let entries = try String(contentsOf:confFileURL)
            for entry in entries.split(separator:"\n"){
                print("processing entry ",entry)
                let param:String = String(entry.split(separator:"=")[0])
                var valueInFile:String
                switch(param){
                case "sign=" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setSign(val: valueInFile)
                    break
                case "bpm=" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setBpm(val: valueInFile)
                    break
                case "reso=" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setReso(val: valueInFile)
                    break
                case "msrc" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setMsrc(val:valueInFile)
                    break
                case "loop" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setMsrc(val:valueInFile)
                    break
                default :
                    print("reading config found unknow param")
                }
            }

        }
        catch{
            print("no config file, use hardcoded values")
        }
    }
    public func loadSystemSettings(message:String){
        print(message)
    }
    public mutating func setSign(val :String) ->Void{
        signatureString = val
        sigNum = UInt8(val.split(separator:"/")[0]) ?? 4;
        sigDen = UInt8(val.split(separator:"/")[1]) ?? 4;
        signatureEventInfo[0] = sigNum
        signatureEventInfo[1] = getPowerOf2(number: sigDen)
        signatureEventInfo[2] = 0x18  // 24 midi clocks per quarter note
        signatureEventInfo[3] = 0x08  //  8 midi clocks per 1/32 note
    }
    public mutating func setBpm(val: String)-> Void{
        bpmString = val
        bpm = UInt16(val) ?? 120
        microSecPerTick = UInt32(1000000 * 60 / UInt32(bpm))
    }
    public mutating func setReso(val: String)-> Void{
        resolutionString = val
        if val.contains("/"){
            //fractional case
            let tempString = val.split(separator: "/")[1]
            resolution = 1/Double(tempString)!
            ticksPerMeasure = UInt8(tempString)!
        }
        else {
            resolution = Double(val) ?? 1/16
            ticksPerMeasure = UInt8(val) ?? 1
        }
    }
    public mutating func setMsrc(val: String)-> Void{
        measureCountString = val
        measureCount = UInt8(val) ?? 4
    }
    public mutating func setLoop(val: String)-> Void{
        loopForEverString = val
        loop = Bool(val) ?? false
    }
    public mutating func updateRithm(position: UInt8, newInstr :UInt8)-> Void {
        if newInstr > 34 {
            rithmPattern = setBitInWord(bitPosition: position, word32: rithmPattern)
        }
        else{
            rithmPattern = clearBitInWord(bitPosition: position, word32: rithmPattern)
        }
        rithmInstruments[Int(position)] = newInstr
    }
    public mutating func clearRithmPattern(){
        rithmPattern = 0
        for i in (0...rithmInstruments.count - 1) {
            rithmInstruments[i] = 0
        }
    }
    public mutating func randomRithmPattern(){
        clearRithmPattern()
        for i in (0...ticksPerMeasure - 1) {
            var randomPosition = arc4random_uniform(UInt32(ticksPerMeasure))
            var randomInstrumentOffset = arc4random_uniform(UInt32(midiParams.percussionInstruments.count))
            if randomInstrumentOffset > 0{ // 0 is none
                rithmInstruments[Int(randomPosition)] = UInt8(midiParams.percussionInstruments[    Int(randomInstrumentOffset)].0)
                var maskValue:UInt32 = 0x01
                rithmPattern = rithmPattern | maskValue << randomPosition
            }
            //update pattern:
        }
    }
    
    public func getPowerOf2(number : UInt8) -> UInt8 {
        var num = number
        for i in (0...7){
            num = num >> 1
            if number == 0 {
                return UInt8(i)
            }
        }
        return 0
    }
}


func getDocDirectory()->URL{
        var url:URL
        //! at end will force abort if nill returned, we must have a doc directory to live
        url = FileManager.default.urls(for: .documentDirectory,
                                             in:  .userDomainMask).first!
        return url
        
}

func makeDir(thisURL:URL,dir:String)->URL{
    var newURL = thisURL
    newURL.appendPathComponent(dir)
    print("about to create ",newURL)
    do{
        try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
    }catch{
        print(error)
    }
    return newURL
}

func saveConfiguration(configURL:URL,config:Config){
    var entries=[String]()//define empty array of strings
    entries.append("sign="+config.signatureString+"\n")
    entries.append("bpm="+config.bpmString+"\n")
    entries.append("reso="+config.resolutionString+"\n")
    entries.append("msrc="+config.measureCountString+"\n")
    entries.append("loop="+String(config.loopForEverString)+"\n")

    print("in save configuration will save")
    var dataString:String = ""
    for entry in entries{
        dataString += "\(entry)"
    }
    print (dataString)
    do{
        try dataString.write(to:configURL,atomically: true,encoding: .utf8)
    }catch{
        print("error writing config file")
    }
}

func deleteFile(fileURL:URL){
    if (FileManager.default.fileExists(atPath: fileURL.path)){
        do{
            try FileManager.default.removeItem(at:fileURL)
        }catch{
            print("error deleting file")
        }
    }
}

/*
 Following is to test in playground
 */
/*
var test = getDocDirectory()
print (test)
var c = Config()
print (c.confFileURL)
print("signature ",c.signature)
print("num ",c.sigNum)
print("den ",c.sigDen)
print("bpm ",c.bpm)
saveConfiguration(configURL: c.confFileURL, config:c)
//deleteFile(fileURL: c.confFileURL)
//deleteFile(fileURL: c.midiFileURL)
*/

