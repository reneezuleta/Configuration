//
//  Configuration.swift
//  Configuration
//
//  Created by Renee Zuleta on 4/9/21.
//

import Foundation


public struct Config{
    public var confFileURL:URL
    public var midiFileURL:URL
    public var sampleMidiFileURL:URL
    public var signature:String
    public var sigNum:Int8
    public var sigDen:Int8
    public var beatPerMeasure:String
    public var bpm:Int16
    public var pulsesPerQuarterNote:String
    public var ppqn:Int8
    public var measureCount:String
    public var measures:Int8
    public var loopForEver:String
    public var loop:Bool
    public var rithmPattern:UInt32
    public var rithmInstruments: [UInt16]
    public var midiParams: midiDefines
    
    public init(){
       //build the url we need to use for configuration file
        //midiFileURL = URL(string: "temp")!
        //confFileURL = URL(string: "temp")!
        confFileURL = getDocDirectory()
        confFileURL = makeDir(thisURL:confFileURL,dir:"config")
        midiFileURL = makeDir(thisURL:confFileURL,dir:"midi")
        sampleMidiFileURL = midiFileURL
        confFileURL.appendPathComponent("config.txt")
        midiFileURL.appendPathComponent("myMidi.midi")
        sampleMidiFileURL.appendPathComponent("sampleMidi.midi")
        signature = "4/4"
        sigNum = setSignatureNumerator(sig: signature)
        sigDen = setSignatureDenominator(sig: signature)
        beatPerMeasure = "120"
        bpm = 120
        pulsesPerQuarterNote = "8"
        ppqn = 8
        measureCount = "4"
        measures = 4
        loopForEver = "false"
        loop = false
        rithmPattern = 0xc888000f //1100100010001000
        //rithmPattern = 0b1100100010001000
        rithmInstruments = [46, // open high hat
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
                case "ppqn=" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setPpqn(val: valueInFile)
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
        signature = val
        sigNum = Int8(val.split(separator:"/")[0]) ?? 4;
        sigDen = Int8(val.split(separator:"/")[1]) ?? 4;
    }
    public mutating func setBpm(val: String)-> Void{
        beatPerMeasure = val
        bpm = Int16(val) ?? 120
    }
    public mutating func setPpqn(val: String)-> Void{
        pulsesPerQuarterNote = val
        ppqn = Int8(val) ?? 4
    }
    public mutating func setMsrc(val: String)-> Void{
        measureCount = val
        measures = Int8(val) ?? 4
    }
    public mutating func setLoop(val: String)-> Void{
        loopForEver = val
        loop = Bool(val) ?? false
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
    entries.append("sign="+config.signature+"\n")
    entries.append("bpm="+String(config.bpm)+"\n")
    entries.append("ppqn="+String(config.ppqn)+"\n")
    entries.append("msrc="+String(config.measureCount)+"\n")
    entries.append("loop="+String(config.loopForEver)+"\n")

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

func setSignatureNumerator(sig:String)->Int8{
    //coalesce to 1 if string does not show a number
    return Int8(sig.split(separator:"/")[0]) ?? 1;
}

func setSignatureDenominator(sig:String)->Int8{
    //coalesce to 1 if string does not show a number
    return Int8(sig.split(separator:"/")[1]) ?? 1;
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

