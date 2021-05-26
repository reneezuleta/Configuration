//
//  Configuration.swift
//  Configuration
//
//  Created by Renee Zuleta on 4/9/21.
//

import Foundation
import utilities

public enum TuneType{  // used to know what was the type of the last tune played
    case melody    // used to createtune
    case beat    // used to createtune
    case tune           // used to createtune (both melody and beat
    case rythmGrooves  // used for createRythm case
}

public struct Scale{
    public var name:String  // C, C#, D ......
    public var sharp:String // #  or space
    public var type:String  // major or  minor
    public var fullName:String
}


public struct Channel{
    public var id : UInt8
    public var type : String // Melody, Chord, Silent, Opposing
    public var related:[UInt8]
    public var scale:Scale
    public var instrument :UInt8
    public var instrumentRange:String
}

public struct Config{
    public var confPathURL:URL
    public var confFileURL:URL
    public var tunePathURL:URL
    public var midiFileURL:URL
    public var rythmPathURL:URL
    public var rythmFileURL:URL
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
    public var channel :[Channel]
    
    public init(){
       //build the url we need to use for configuration file
        let baseURL :URL = getDocDirectory()
        //create all needed directories in docs dir
        confPathURL = makeDir(thisURL:baseURL,dir:"config")
        tunePathURL = makeDir(thisURL:baseURL,dir:"tune")
        rythmPathURL = makeDir(thisURL:baseURL,dir:"rythm")
        
        confFileURL = confPathURL
        confFileURL.appendPathComponent("default.txt")
        print ("the config file path \(confFileURL.path)")
        midiFileURL = tunePathURL
        midiFileURL.appendPathComponent("defaultMelody.midi")
        print ("the midi file path \(midiFileURL.path)")
        rythmFileURL = rythmPathURL
        rythmFileURL.appendPathComponent("defaultRythm.midi")

        
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
        rithmPattern = 0x11111111 //nothe that ls bit is first
        // there will be ppqn * sig denominator slots
        //for now allocate 32, may increase later
        rithmInstruments = [UInt8]()
        for _ in 0...31 {
            rithmInstruments.append(34)  // 34 means no instrument
        }
        // to match defaulpt pattern
        rithmInstruments[0] = 42  // closed hat  bit 0
        rithmInstruments[4] = 42  // closed hat  bit 0
        rithmInstruments[8] = 38  // acoustic snare   bit 8
        rithmInstruments[12] = 42  // closed hat  bit 0
        rithmInstruments[16] = 42  // low tom   bit 16
        rithmInstruments[20] = 42  // low tom   bit 16
        rithmInstruments[24] = 38  // side stick   bit 24
        rithmInstruments[28] = 42  // low tom   bit 16
        
        midiParams = midiDefines()
        let relatedChannels:[UInt8] = [0,0,0]
        channel = [Channel]()
        for i in (0..<16){
            channel.append(Channel(id: UInt8(i), type: "Silent", related: relatedChannels, scale: Scale(name: "C",sharp: " ",type: "Major",fullName: "C Major"), instrument: 0, instrumentRange: "Middle"))
        }
        channel[0].type = "Melody"
        channel[1].type = "Opposing"
        channel[2].type = "Chord"
        channel[3].type = "Chord"
        
        //attempt to read defaulr config file
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
        bpm = UInt16(val) ?? 60
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
    public mutating func togleLoop()-> Void{
        if loop {
            loop = false
        }
        else{
            loop = true
        }
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
        for _ in (0...ticksPerMeasure - 1) {
            let randomPosition = arc4random_uniform(UInt32(ticksPerMeasure))
            let randomInstrumentOffset = arc4random_uniform(UInt32(midiParams.percussionInstruments.count))
            if randomInstrumentOffset > 0{ // 0 is none
                rithmInstruments[Int(randomPosition)] = UInt8(midiParams.percussionInstruments[    Int(randomInstrumentOffset)].0)
                let maskValue:UInt32 = 0x01
                rithmPattern = rithmPattern | maskValue << randomPosition
            }
            //update pattern:
        }
    }
    
    public mutating func setChannelType(channelId:Int, val:String) ->Void {
        channel[channelId].type = val
    }
    
    public mutating func setChannelInstrument(channelId:Int, val:UInt8){
        channel[channelId].instrument = val
    }
    
    public mutating func setChannelRange(channelId:Int, val:String){
        channel[channelId].instrumentRange = val
    }
    
    public mutating func setChannelScaleName(channelId:Int, val:String){
        channel[channelId].scale.name = val
        channel[channelId].scale.fullName = val + channel[channelId].scale.sharp + " " +
                                            channel[channelId].scale.type
    }
    
    public mutating func setChannelScaleSharp(channelId:Int, val:String){
        channel[channelId].scale.sharp = val
        channel[channelId].scale.fullName = channel[channelId].scale.name + val + " " +
                                            channel[channelId].scale.type
    }
    public mutating func togleScaleSharp(channelId:Int){
        if channel[channelId].scale.sharp == "#" {
            setChannelScaleSharp(channelId: channelId, val: " ")
        }
        else {
            setChannelScaleSharp(channelId: channelId, val: "#")
        }
    }
    public mutating func setChannelScaleType(channelId:Int, val:String){
        channel[channelId].scale.type = val
        channel[channelId].scale.fullName = channel[channelId].scale.name +
                                            channel[channelId].scale.sharp + " " + val
        
    }
    public mutating func togleScaleType(channelId:Int){
        if channel[channelId].scale.type == "Major" {
            setChannelScaleType(channelId: channelId, val: "Minor")
        }
        else {
            setChannelScaleType(channelId: channelId, val: "Major")
        }
    }
 
    
    public func getPowerOf2(number : UInt8) -> UInt8 {
        var num = number
        for i in (0...7){
            num = num >> 1
            if num == 0 {
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

