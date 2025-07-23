//
//  SoundPulseButtonBackgroundView.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import ColorfulX
import SwiftUI

/// Background gradient view for SoundPulseButton
struct SoundPulseButtonBackgroundView: View {
    let isListening: Bool
    let rotation: Double
    let configuration: SoundPulseButtonConfiguration

    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        let currentBackground = isListening ? configuration.background.listening : configuration.background.idle
        let shouldRotate = isListening
            ? configuration.background.rotation.listening
            : configuration.background.rotation.idle

        Group {
            switch currentBackground {
            case let .color(color):
                color
            case let .mesh(colors):
                meshGradient(colors: colors)
            }
        }
        .rotationEffect(.degrees(shouldRotate ? rotation : 0))
    }

    private func meshGradient(colors: [Color]) -> MulticolorGradient {
        let points: [MulticolorGradientView.Parameters.ColorStop] = colors.enumerated().map { index, color in
            let angle = Double(index) / Double(colors.count) * 2 * .pi + .pi * 5 / 4
            let radius = 0.4
            let x = 0.5 + radius * cos(angle)
            let y = 0.5 + radius * sin(angle)

            return MulticolorGradientView.Parameters.ColorStop(
                color: .init(.init(color)),
                position: .init(x: x, y: y)
            )
        }

        return MulticolorGradient(parameters: .constant(.init(
            points: points,
            power: configuration.background.meshPower
        )))
    }
}
