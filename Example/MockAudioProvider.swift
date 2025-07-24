//
//  MockAudioProvider.swift
//  SoundPulseButton Example
//
//  Created by Mikhail Kogan on 23/07/2025.
//

@preconcurrency import AVFoundation
import SoundPulseButton

/// Mock audio buffer provider for the example app
final class MockAudioProvider: SoundPulseButtonAudioBufferProvider, Sendable {
    nonisolated var audioBufferStream: AsyncStream<AVAudioPCMBuffer> {
        AsyncStream { continuation in
            Task {
                guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
                    continuation.finish()
                    return
                }

                // Generate mock audio data with varying levels
                var time: Double = 0
                let timeIncrement = 1.0 / 60.0 // 60 FPS

                while !Task.isCancelled {
                    // Create new buffer for each iteration to avoid data races
                    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024) else {
                        continuation.finish()
                        return
                    }

                    // Simulate audio levels with sine wave
                    let level = abs(sin(time * 2.0 * .pi * 0.5)) // 0.5 Hz frequency

                    // Fill buffer with mock data based on level
                    if let channelData = buffer.floatChannelData?[0] {
                        for index in 0 ..< Int(buffer.frameCapacity) {
                            channelData[index] = Float(level * 0.1) // Scale down for realistic levels
                        }
                        buffer.frameLength = buffer.frameCapacity
                    }

                    // Create a copy to avoid data races
                    guard let copyBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: buffer.frameCapacity) else {
                        continuation.finish()
                        return
                    }

                    // Copy data to the new buffer
                    copyBuffer.frameLength = buffer.frameLength
                    if let sourceData = buffer.floatChannelData?[0],
                       let destData = copyBuffer.floatChannelData?[0] {
                        memcpy(destData, sourceData, Int(buffer.frameLength) * MemoryLayout<Float>.size)
                    }

                    continuation.yield(copyBuffer)

                    time += timeIncrement
                    try? await Task.sleep(for: .milliseconds(16)) // ~60 FPS
                }
                continuation.finish()
            }
        }
    }
}
