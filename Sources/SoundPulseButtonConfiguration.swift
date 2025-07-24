//
//  SoundPulseButtonConfiguration.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import SwiftUI

/// Background type for SoundPulseButton
public enum SoundPulseButtonBackground {
    case color(Color)
    case mesh([Color])
}

/// Configuration structure for customizing SoundPulseButton appearance and behavior
@MainActor
public struct SoundPulseButtonConfiguration {
    public var colors = Colors()
    public var layout = Layout()
    public var effects = Effects()
    public var background = Background()

    public init() { }

    /// Color configuration for button components
    public struct Colors {
        public var pulse: Color = .white
        public var icon: Color = .white
        public var shadow: Color = .black
        public var loader: Color = .white

        public init() { }
    }

    /// Layout configuration for button sizing and positioning
    public struct Layout {
        public var icon: Image = .init(systemName: "mic.fill")
        public var baseRadius: CGFloat = 44
        public var iconSize: CGFloat = 44
        public var frameMultiplier: CGFloat = 4.4

        public init() { }

        /// Initialize with custom icon
        public init(icon: Image) {
            self.icon = icon
        }
    }

    /// Effects configuration for animations and visual effects
    public struct Effects {
        public var innerPulse = InnerPulse()
        public var ripples = Ripples()
        public var loader = Loader()
        public var shimmer = Shimmer()
        public var button = Button()
        public var shadow = Shadow()

        public init() { }

        /// Inner pulse rings configuration
        public struct InnerPulse {
            public var circleCount: Int = 0 // Disabled by default
            public var interStepDistance: CGFloat = 9
            public var opacity: Double = 0.15
            public var stepAnimationDelay: Double = 0.03

            public init() { }
        }

        /// Ripple waves configuration
        public struct Ripples {
            public var count: Int = 0 // Disabled by default
            public var maxOffset: CGFloat = 36
            public var baseOpacity: Double = 0.6
            public var lineWidth: CGFloat = 1
            public var blurRadius: CGFloat = 1
            public var startInset: CGFloat = 4
            public var pauseBetweenSteps: Double = 0.82
            public var pauseBetweenCycles: Double = 0.82
            public var startDelay: Double = 0.2
            public var animationDuration: Double = 3.2

            public init() { }
        }

        /// Loading indicator configuration
        public struct Loader {
            public var trimTo: CGFloat = 0.3
            public var padding: CGFloat = 6
            public var opacity: Double = 0.3
            public var blurRadius: CGFloat = 0.5
            public var lineWidth: CGFloat = 6
            public var appearanceDuration: Double = 0.1
            public var rotationDuration: Double = 1.0

            public init() { }
        }

        /// Shimmer effect configuration
        public struct Shimmer {
            public var baseOpacity: Double = 0.75
            public var blurRadius: CGFloat = 3
            public var radiusMultiplier: CGFloat = 2
            public var startRadiusMultiplier: CGFloat = 0.3
            public var baseVisibilityOpacity: Double = 0.75
            public var bottomPadding: CGFloat = 11
            public var startDelay: Double = 2.2
            public var animationDuration: Double = 3.2

            public init() { }
        }

        /// Button interaction configuration
        public struct Button {
            public var scaleMultiplier: CGFloat = 0.5
            public var pressScale: CGFloat = 0.8
            public var pressOpacity: Double = 0.8
            public var inactiveScale: CGFloat = 1
            public var inactiveOpacity: Double = 0.85
            public var loadingOpacity: Double = 0.4
            public var pressAnimationDuration: Double = 0.1
            public var listeningAnimationDuration: Double = 0.5
            public var backgroundRotationDuration: Double = 5.0
            public var scaleAnimationDuration: Double = 0.3
            public var hapticEnabled: Bool = true

            public init() { }
        }

        /// Shadow effect configuration
        public struct Shadow {
            public var opacity: Double = 0.15
            public var radius: CGFloat = 10
            public var pressedRadius: CGFloat = 2
            public var offsetY: CGFloat = 5
            public var pressedOffsetY: CGFloat = 1

            public init() { }
        }
    }

    /// Background configuration for button states
    public struct Background {
        public var idle: SoundPulseButtonBackground = .color(.accentColor)
        public var listening: SoundPulseButtonBackground = .color(.red)
        public var rotation = Rotation()
        public var meshPower: Double = 5

        public init() { }

        /// Background rotation configuration
        public struct Rotation {
            public var idle: Bool = false
            public var listening: Bool = false

            public init() { }
        }
    }
}

// MARK: - Preset Configurations

public extension SoundPulseButtonConfiguration {
    /// Default configuration
    static let `default` = SoundPulseButtonConfiguration()

    /// Small size preset
    static func small() -> SoundPulseButtonConfiguration {
        var config = SoundPulseButtonConfiguration.default
        config.layout.baseRadius = 32
        config.layout.iconSize = 32
        return config
    }

    /// Large size preset
    static func large() -> SoundPulseButtonConfiguration {
        var config = SoundPulseButtonConfiguration.default
        config.layout.baseRadius = 56
        config.layout.iconSize = 56
        return config
    }
}
