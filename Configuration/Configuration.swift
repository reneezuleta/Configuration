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
    public var altSigNum:UInt8
    public var altSigDen:UInt8
    public var altSignatureEventInfo:[UInt8]
    public var bpm:UInt16
    public var resolutionString:String
    public var resolution:Double
    public var ticksPerMeasure:UInt8
    public var microSecPerTick:UInt32
    public var measureCountString:String
    public var measureCount:UInt8
    //public var loopForEverString:String
    public var loop:Bool
    public var withPolyRythm:Bool
    public var firstPolyValue:UInt8
    public var secondPolyValue:UInt8
    public var rithmPattern:UInt32
    public var preloadedGrooves :[UInt32]
    public let defaultInstrument1 :(UInt8,String) = (UInt8(42),"Closed Hi Hat")
    public let defaultInstrument2 :(UInt8,String) = (UInt8(38),"Acustic Snare")
    public let defaultRandomBeatInstr : (UInt8,String) = (UInt8(36),"Bass Drum 1")
    public let defaultStartMarkerInstr: (UInt8,String) = (UInt8(49),"Crash Cymbal 1")
    public let defaultStartMarker2Instr: (UInt8,String) = (UInt8(53),"Ride Bell")
    public var rithmInstruments:  [(UInt8,String)]  //  will be size 32
    //public var midiParams: midiDefines
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
        // signature event ff 58 04 nn dd cc bb
        // nn numerator
        // dd denominator power of 2
        // cc number of midiclocks in a metronome click, defaulting to 36
        // assuming 24 midiclocks pwe queter note
        //  if c = 48, metronome clicks every 2 quarter notes
        //     c = 24, metronome clicks every quarter note
        // bb number of notated 32nd notes in a midi quarter note (24 clocks/4 = 8, usual value)
        // setting bb to 8 makes for 24 midi clocks per quarter note
        signatureEventInfo = [0x04,0x02,0x24,0x08]  // event for sign 4/4
        altSigNum = 13 //UInt8(setSignatureNumerator(sig: signatureString))
        altSigDen = 8
        altSignatureEventInfo = [0x0D,0x03,0x24,0x08]  // event for alt signature
        bpm = 120
        resolutionString = "1/16"
        resolution = 1/16
        ticksPerMeasure = 16
        microSecPerTick = UInt32(1000000 * 60 / UInt32(bpm))
        measureCountString = "4"
        measureCount = 4
        //loopForEverString = "0" //short for false
        loop = false
        withPolyRythm = false
        firstPolyValue  = 0
        secondPolyValue  = 0
        preloadedGrooves = [0x11111111,
                           0x21212121,
                           0x13131313,
                           0x21412141]
        rithmPattern = preloadedGrooves[0] //nothe that ls bit is first
        // there will be ppqn * sig denominator slots
        //for now allocate 32, may increase later
        rithmInstruments = [(UInt8,String)]()
        //loadInstrumentsForPattern(pattern: rithmPattern )
        
        for _ in 0...31 {
            rithmInstruments.append((0,"None"))  // 34 means no instrument
        }
       /*
        // to match default pattern
        rithmInstruments[0] = (UInt8(42),"Closed Hi Hat") // closed hat  bit 0
        rithmInstruments[4] = (UInt8(42),"Closed Hi Hat")
        rithmInstruments[8] = (UInt8(38),"Acustic Snare")
        rithmInstruments[12] = (UInt8(42),"Closed Hi Hat")
        rithmInstruments[16] = (UInt8(42),"Closed Hi Hat")
        rithmInstruments[20] = (UInt8(42),"Closed Hi Hat")
        rithmInstruments[24] = (UInt8(38),"Acustic Snare")
        rithmInstruments[28] = (UInt8(42),"Closed Hi Hat")
       */
        //midiParams = midiDefines()
        let relatedChannels:[UInt8] = [0,0,0]
        channel = [Channel]()
        for i in (0..<16){
            channel.append(Channel(id: UInt8(i), type: "Silent", related: relatedChannels, scale: Scale(name: "C",sharp: " ",type: "Major",fullName: "C Major"), instrument: 0, instrumentRange: "Middle"))
        }
        channel[0].type = "Melody"
        channel[1].type = "Opposing"
        channel[2].type = "Chord"
        channel[3].type = "Chord"
        loadInstrumentsForPattern(pattern: rithmPattern) /// have to call when all is initialized
        let status = loadConfiguration(fromURL: confFileURL)
        if status != ""{
            print("no default file, stick to hardcoded values")
        }
    }
    
    public mutating func loadConfiguration (fromURL:URL) -> String{
        //attempt to read default config
        var status :String = ""
        do{
            print("try to read ",fromURL)
            let entries = try String(contentsOf:fromURL)
            for entry in entries.split(separator:"\n"){
                print("processing config file entry ",entry)
                let param:String = String(entry.split(separator:"=")[0])
                var valueInFile:String
                switch(param){
                case "sign" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setSign(val: valueInFile)
                    break
                case "bpm" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setBpm(val: valueInFile)
                    break
                case "reso" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setReso(val: valueInFile)
                    break
                case "msrc" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setMsrc(val:valueInFile)
                    break
                case "loop" :
                    valueInFile = String(entry.split(separator:"=")[1])
                    setLoop(val:valueInFile)
                    break
                default :
                    print("reading config found unknow param")
                }
            }

        }
        catch{
            print("no config file, use hardcoded values")
            status = "load settings unable read file"
        }
        return status
    }

    public func saveConfiguration(configFileURL:URL) -> String{
        var errorMsg = ""
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var entries=[String]()//define empty array of strings
        entries.append("sign="+signatureString+"\n")
        entries.append("bpm="+String(bpm)+"\n")
        entries.append("reso="+resolutionString+"\n")
        entries.append("msrc="+measureCountString+"\n")
        entries.append("loop="+String(loop)+"\n")
        entries.append("rithmPattern="+String(rithmPattern)+"\n")
        for i in 0...15 {
            entries.append("instrCode"+String(i)+"="+String(rithmInstruments[i].0))
            entries.append("instrName"+String(i)+"="+rithmInstruments[i].1)
        }
        for i in 0...15{
            entries.append("ch"+String(i)+"\n")   // this is just a marker
            entries.append("chType="+channel[i].type+"\n")
            entries.append("scaleName="+channel[i].scale.name+"\n")
            entries.append("scaleSharp="+channel[i].scale.sharp+"\n")
            entries.append("scaleType="+channel[i].scale.type+"\n")
            entries.append("chInstr="+String(channel[i].instrument)+"\n")
            entries.append("chRange="+channel[i].instrumentRange+"\n")
        }
        print("in save configuration will save")
        var dataString:String = ""
        for entry in entries{
            dataString += "\(entry)"
        }
        print (dataString)
        do{
            // write method overwrites as opposed to append method
            try dataString.write(to:configFileURL,atomically: true,encoding: .utf8)
        }catch{
            print("error writing config file")
            errorMsg = error.localizedDescription
        }
        return errorMsg
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
        loadInstrumentsForPattern(pattern: rithmPattern) // pattern follows resolution
    }
    public mutating func setMsrc(val: String)-> Void{
        measureCountString = val
        measureCount = UInt8(val) ?? 4
    }
 
    public mutating func setLoop(val: String)-> Void{
        loop = Bool(val) ?? false
    }
    public mutating func togleLoop()-> Void{
        if loop {
            loop = false
        }
        else{
            loop = true
        }
    }
    public mutating func updateRithm(position: UInt8, newInstr :(UInt8,String))-> Void {
        if newInstr.0 > 0 {
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
            rithmInstruments[i] = (0,"None")
        }
    }
    public mutating func randomRithmPattern(){
        clearRithmPattern()
        for _ in (0...ticksPerMeasure - 1) {
            let randomPosition = arc4random_uniform(UInt32(ticksPerMeasure))
            rithmInstruments[Int(randomPosition)] = defaultInstrument1
            let maskValue:UInt32 = 0x01
            rithmPattern = rithmPattern | maskValue << randomPosition
        }
    }
    public mutating func loadInstrumentsForPattern(pattern:UInt32){
        let beatCount = (ticksPerMeasure / sigDen) * sigNum
        for _ in 0...beatCount-1 {
            rithmInstruments.append((0,"None"))  // 34 means no instrument
        }
        var counter = 0 // will switch to default2 on 3rd beat in measure
        for i in 0 ..< ticksPerMeasure{
            let bitValue = pattern >> i  // least significant bit is position 1
            if bitValue & 0x00000001 == 1{
                counter += 1
                if counter < 3 {
                    rithmInstruments[Int(i)] = defaultInstrument1// closed hat  bit 0
                }
                else {
                    rithmInstruments[Int(i)] = defaultInstrument2
                    counter = 0
                }
            }
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



