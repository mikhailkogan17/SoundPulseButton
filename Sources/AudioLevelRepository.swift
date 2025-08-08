import Accelerate
import AVFoundation
import Foundation

final actor AudioLevelRepository {
    private var baselineNoiseLevel: Float = 0.001
    private var peakLevel: Float = 0.1

    private var audioLevelContinuation: AsyncStream<Double>.Continuation?
    private var _audioLevelStream: AsyncStream<Double>?

    // Log throttling
    private var lastContinuationNilLogTime: Date?
    private let continuationNilLogInterval: TimeInterval = 5.0
    private var lastNoChannelDataLogTime: Date?
    private let noChannelDataLogInterval: TimeInterval = 10.0

    init() { }

    var audioLevelStream: AsyncStream<Double> {
        if let stream = _audioLevelStream {
            return stream
        }

        return createAudioLevelStream()
    }

    private func createAudioLevelStream() -> AsyncStream<Double> {
        let stream = AsyncStream { continuation in
            self.audioLevelContinuation = continuation

            continuation.onTermination = { @Sendable _ in
                // AudioLevel stream terminated
            }
        }
        _audioLevelStream = stream
        return stream
    }

    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard buffer.frameLength > 0 else {
            print("AudioLevelRepository: Empty buffer with frameLength: \(buffer.frameLength)")
            return
        }

        guard let channelData = buffer.floatChannelData?[0] else {
            if let lastLogTime = lastNoChannelDataLogTime,
               Date.now.timeIntervalSince(lastLogTime) < noChannelDataLogInterval {
                // Skip logging - within throttle interval
            } else {
                print("AudioLevelRepository: No channel data")
                lastNoChannelDataLogTime = .now
            }
            return
        }

        let frameCount = Int(buffer.frameLength)
        let rms = calculateRMS(channelData, frameCount: frameCount)

        updateAdaptiveLevels(rms: rms)

        let normalizedLevel = calculateNormalizedLevel(rms: rms)
        let enhancedLevel = enhanceLevel(normalizedLevel)

        guard let continuation = audioLevelContinuation else {
            if let lastLogTime = lastContinuationNilLogTime,
               Date.now.timeIntervalSince(lastLogTime) < continuationNilLogInterval {
                // Skip logging - within throttle interval
            } else {
                print("AudioLevel continuation is nil, cannot yield data")
                lastContinuationNilLogTime = .now
            }
            return
        }

        continuation.yield(enhancedLevel)
    }

    private func calculateRMS(_ channelData: UnsafeMutablePointer<Float>, frameCount: Int) -> Float {
        guard frameCount > 0 else {
            print("AudioLevelRepository: Invalid frameCount: \(frameCount)")
            return 0.0
        }

        var sum: Float = 0.0
        vDSP_svesq(channelData, 1, &sum, vDSP_Length(frameCount))

        let rmsSquared = sum / Float(frameCount)
        guard rmsSquared >= 0 else {
            print("AudioLevelRepository: Invalid RMS squared: \(rmsSquared)")
            return 0.0
        }

        return sqrt(rmsSquared)
    }

    private func updateAdaptiveLevels(rms: Float) {
        // Much more aggressive baseline noise adaptation
        if rms < baselineNoiseLevel * 3 {
            let smoothingFactor = Float(0.1) // smoothing factor
            let inverseSmoothing = 1 - smoothingFactor
            let baselinePart = baselineNoiseLevel * inverseSmoothing
            let rmsPart = rms * smoothingFactor
            baselineNoiseLevel = min(baselinePart + rmsPart, 0.0001) // Cap baseline very low
        }

        if rms > peakLevel {
            peakLevel = rms
        } else {
            peakLevel = peakLevel * 0.995 + rms * 0.005 // Faster peak decay
        }
    }

    private func calculateNormalizedLevel(rms: Float) -> Double {
        // Use raw RMS with moderate amplification for smooth microphone visualization
        let amplifiedRMS = rms * 30.0 // 30x amplification for visible but not jarring effect
        let normalizedLevel = min(amplifiedRMS, 1.0)
        return Double(max(normalizedLevel, 0))
    }

    private func enhanceLevel(_ rawLevel: Double) -> Double {
        // Enhance small audio levels for better visibility
        let smoothed = max(0, min(1, rawLevel))
        return pow(smoothed, 0.4) // enhancement power
    }
}

enum AudioLevelRepositoryError: LocalizedError {
    case engineNotInitialized
    case inputNodeNotAvailable
    case monitoringFailed

    var errorDescription: String? {
        switch self {
        case .engineNotInitialized:
            "Audio engine could not be initialized"
        case .inputNodeNotAvailable:
            "Audio input node not available"
        case .monitoringFailed:
            "Audio level monitoring failed to start"
        }
    }
}
