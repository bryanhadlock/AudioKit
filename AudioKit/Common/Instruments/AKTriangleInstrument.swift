//
//  AKTriangleInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// A wrapper for AKTriangleOscillator to make it a playable as a polyphonic instrument.
public class AKTriangleInstrument: AKPolyphonicInstrument {
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    /// Instantiate the Triangle Instrument
    ///
    /// - parameter voiceCount: Maximum number of voices that will be required
    ///
    public init(voiceCount: Int) {
        super.init(voice: AKTriangleVoice(), voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Index of voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    public override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let frequency = note.midiNoteToFrequency()
        let amplitude = Double(velocity) / 127.0 * 0.3
        let triangleVoice = voice as! AKTriangleVoice
        triangleVoice.oscillator.frequency = frequency
        triangleVoice.oscillator.amplitude = amplitude
        triangleVoice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Index of voice to stop
    /// - parameter note: MIDI Note Number
    ///
    public override func stopVoice(voice: AKVoice, note: Int) {
        let triangleVoice = voice as! AKTriangleVoice //you'll need to cast the voice to its original form
        triangleVoice.stop()
    }
}

internal class AKTriangleVoice: AKVoice {
    
    var oscillator: AKTriangleOscillator
    var adsr: AKAmplitudeEnvelope
    
    override init() {
        oscillator = AKTriangleOscillator()
        adsr = AKAmplitudeEnvelope(oscillator,
            attackDuration: 0.2,
            decayDuration: 0.2,
            sustainLevel: 0.8,
            releaseDuration: 1.0)

        super.init()
        avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func copy() -> AKVoice {
        let copy = AKTriangleVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return oscillator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        oscillator.start()
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        adsr.stop()
    }
}