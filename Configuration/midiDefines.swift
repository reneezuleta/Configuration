//
//  midiDefines.swift
//  Configuration
//
//  Created by Renee Zuleta on 4/23/21.
//

import Foundation

public struct midiDefines{
    let firstNote = 0
    let lastNote = 127
    
    public var percussionAllInstruments :[(UInt8,String)] =
                            [(0, "None"),
                             (35,"Acoustic Bass Drum"),
                             (36,"Bass Drum 1"),
                             (37,"Side Stick"),
                             (38,"Acustic Snare"),
                             (39,"Hand Clap"),
                             (40,"Electric Snare"),
                             (41,"Low Floor Tom"),
                             (42,"Closed Hi Hat"),
                             (43,"Hi Floor Tom"),
                             (44,"Pedal Hi-Hat"),
                             (45,"Low Tom"),
                             (46,"Open High Hat"),
                             (47,"Low Mid Tom"),
                             (48,"Hi Mid Tom"),
                             (49,"Crash Cymbal 1"),
                             (50,"High Tom"),
                             (51,"Ride Cymbal 1"),
                             (52,"Chinese Cymbal"),
                             (53,"Ride Bell"),
                             (54,"Tabourine"),
                             (55,"Splash Cymbal"),
                             (56,"Cow Bell"),
                             (57,"Crash Cymbal 2"),
                             (58,"Vibraslap"),
                             (59,"Ride Cymbal 2"),
                             (60,"Hi Bongo"),
                             (61,"Low Bongo"),
                             (62,"Conga Dead Stroke"),
                             (63,"Conga"),
                             (64,"Tumba"),
                             (65,"High Timbale"),
                             (66,"Low Timbale"),
                             (67,"High Agogo"),
                             (68,"Low Agogo"),
                             (69,"Cabasa"),
                             (70,"Maracas"),
                             (71,"Whistle Short"),
                             (72,"WHistle Long"),
                             (73,"Guiro Short"),
                             (74,"Guiro Long"),
                             (75,"Claves"),
                             (76,"High WoodBlock"),
                             (77,"Low WoodBlock"),
                             (78,"Cuica High"),
                             (79,"Cuica Low"),
                             (80,"Triangle Mute"),
                             (81,"Triange Open"),
                             (82,"Shaker"),  // after 82 is expanded range, check if it works
                             (83,"Sleigh Bell"), // if it works add 27 trhu 34
                             (84,"Bell Tree"),
                             (85,"Castanets"),
                             (86,"Mute Surdu"),
                             (87,"Open Surdu")
                            ]
    
    public var percussionInstruments  :[(UInt8,String)] =
         [(0, "None"),
         (35,"Acoustic Bass Drum"),
         (36,"Bass Drum 1"),
         (37,"Side Stick"),
         (38,"Acustic Snare"),
         (40,"Electric Snare"),
         (41,"Low Floor Tom"),
         (42,"Closed Hi Hat"),
         (43,"Hi Floor Tom"),
         (44,"Pedal Hi-Hat"),
         (45,"Low Tom"),
         (46,"Open High Hat"),
         (47,"Low Mid Tom"),
         (48,"Hi Mid Tom"),
         (49,"Crash Cymbal 1"),
         (50,"High Tom"),
         (51,"Ride Cymbal 1"),
         (52,"Chinese Cymbal"),
         (53,"Ride Bell"),
         (54,"Tabourine"),
         (55,"Splash Cymbal"),
         (56,"Cow Bell"),
         (57,"Crash Cymbal 2"),
         (59,"Ride Cymbal 2"),
         (65,"High Timbale"),
         (66,"Low Timbale"),
         (80,"Triangle Mute"),
         (81,"Triange Open"),

    ]
    let pianoStart = 0
    let percussionStart = 9
    let organStart = 17
    let guitarStart = 25
    let bassStart = 33
    let stringStart = 41
    let ensembleStart = 49
    let brassStart = 57
    let reedStart = 65
    let pipeStart = 73
    let synthLeadStart = 81
    let synthPadStart = 89
    let synthEffectStart = 97
    let ethnicStart = 105
    let soundEffectStart = 113
/*
    public var midiInstrumentTypes :[(Int,String)] =
                           [(pianoStart, "Piano Timbres"),
                            percussionStart,"Chromatic Percussion",
                            organStart,"Organ Timbres",
                            guitarStart,"Guitar Timbres",
                            bassStart,"Bass Timbres",
                            stringStart,"String Timbres",
                            ensembleStart,"Ensemble Timbres",
                            brassStart,"Brass Timbres",
                            reedStart,"Reed Timbres",
                            pipeStart,"Pipe Timbres",
                            synthLeadStart,"Synth Lead",
                            synthPadStart,"Synth Pad",
                            synthEffectStart,"Synth Effect",
                            ethnicStart,"Ethnic Timbres",
                            soundEffectStart,"Sound Effects"]
 */
    public var pianoTimbres :[(Int,String)] =
                            [(1, "Piano Acoustic"),
                             (2,"Piano Bright"),
                             (3,"Piano Electric"),
                             (4,"Piano HonkyTonk"),
                             (5,"Piano Rhodes"),
                             (6,"Piano Chorused"),
                             (7,"Harpsichord"),
                             (8,"Clavinet")]
    
    public var chromaticPercussion :[(Int,String)] =
                            [(1, "Celesta"),
                             (2, "GlockenSpiel"),
                             (3, "Music Box")]
    
    public var organTimbres :[(Int,String)] =
                            [(1, "Hammond Organ"),
                             (2, "Percussive Organ"),
                             (3, "Rock Organ")]
    
    public var guitarTimbres :[(Int,String)] =
                            [(1, "Acoustic Nylon"),
                             (2, "Acoustic Steel"),
                             (3, "Electric Jazz")]
    
    public var bassTimbres :[(Int,String)] =
                            [(1, "Acoustic Bass"),
                             (2, "Fingered Electric Bass"),
                             (3, "Plucked Electric Bass")]
   public init(){}
}

