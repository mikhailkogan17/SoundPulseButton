import AVFoundation
import Foundation

public protocol SoundPulseButtonAudioBufferProvider: AnyObject, Sendable {
    var audioBufferStream: AsyncStream<AVAudioPCMBuffer> { get async }
}
