import AVFoundation

/// Generates the "got it" / "try again" audio cues on the fly (no bundled sound
/// assets needed) so the app never has to show a score or a checkmark on screen.
final class ToneGenerator {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44100

    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }

    func playSuccess() {
        play(frequencies: [523.25, 659.25, 783.99], noteDuration: 0.12) // C-E-G, bright
    }

    func playTryAgain() {
        play(frequencies: [392.00, 349.23], noteDuration: 0.18) // G-F, soft, no shame
    }

    private func play(frequencies: [Double], noteDuration: Double) {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }
        if !engine.isRunning { try? engine.start() }
        for (index, frequency) in frequencies.enumerated() {
            guard let buffer = sineBuffer(frequency: frequency, duration: noteDuration, format: format) else { continue }
            player.scheduleBuffer(buffer, at: nil, options: []) { }
        }
        player.play()
    }

    private func sineBuffer(frequency: Double, duration: Double, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        let channel = buffer.floatChannelData?[0]
        let fadeSamples = Int(sampleRate * 0.01)
        for frame in 0..<Int(frameCount) {
            let sample = sin(2.0 * Double.pi * frequency * Double(frame) / sampleRate)
            var amplitude = 0.3
            if frame < fadeSamples {
                amplitude *= Double(frame) / Double(fadeSamples)
            } else if frame > Int(frameCount) - fadeSamples {
                amplitude *= Double(Int(frameCount) - frame) / Double(fadeSamples)
            }
            channel?[frame] = Float(sample * amplitude)
        }
        return buffer
    }
}
