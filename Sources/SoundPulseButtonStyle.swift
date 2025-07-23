//
//  SoundPulseButtonStyle.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import SwiftUI

extension View {
    /// Conditionally apply a modifier
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// Button style for SoundPulseButton with press effects and haptic feedback
struct SoundPulseButtonStyle: ButtonStyle {
    let isListening: Bool
    let isPulseVisible: Bool
    let isLoading: Bool
    let configuration: SoundPulseButtonConfiguration

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .if(self.configuration.effects.button.hapticEnabled) { view in
                view.sensoryFeedback(
                    .impact(
                        flexibility: configuration.isPressed ? .rigid : .solid,
                        intensity: feedbackIntensity(isPressed: configuration.isPressed)
                    ),
                    trigger: configuration.isPressed
                )
            }
            .scaleEffect(buttonScale(isPressed: configuration.isPressed))
            .opacity(buttonOpacity(isPressed: configuration.isPressed))
            .shadow(
                color: self.configuration.colors.shadow.opacity(
                    isPulseVisible
                        ? self.configuration.effects.shadow.opacity
                        : 0
                ),
                radius: configuration.isPressed
                    ? self.configuration.effects.shadow.pressedRadius
                    : self.configuration.effects.shadow.radius,
                x: 0,
                y: configuration.isPressed
                    ? self.configuration.effects.shadow.pressedOffsetY
                    : self.configuration.effects.shadow.offsetY
            )
            .animation(
                .easeInOut(duration: self.configuration.effects.button.pressAnimationDuration),
                value: configuration.isPressed
            )
            .animation(
                .easeInOut(duration: self.configuration.effects.button.listeningAnimationDuration),
                value: isListening
            )
    }

    private func buttonScale(isPressed: Bool) -> CGFloat {
        if !isLoading, isPressed {
            configuration.effects.button.pressScale
        } else if !isListening {
            configuration.effects.button.inactiveScale
        } else {
            1.0
        }
    }

    private func buttonOpacity(isPressed: Bool) -> CGFloat {
        if isPressed {
            configuration.effects.button.pressOpacity
        } else if !isListening {
            configuration.effects.button.inactiveOpacity
        } else {
            1.0
        }
    }

    private func feedbackIntensity(isPressed: Bool) -> CGFloat {
        if isPressed, !isListening {
            1.0
        } else if !isPressed, isListening {
            1.0
        } else {
            0.5
        }
    }
}
