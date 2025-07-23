//
//  SoundPulseButtonInnerCirclesView.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import SwiftUI
import SwiftUIX

/// Inner pulse circles view for SoundPulseButton
struct SoundPulseButtonInnerCirclesView: View {
    let scale: CGFloat
    let configuration: SoundPulseButtonConfiguration

    var body: some View {
        ZStack {
            ForEach(0 ..< configuration.effects.innerPulse.circleCount, id: \.self) { index in
                let baseRadius = configuration.layout.baseRadius
                let interStepDistance = configuration.effects.innerPulse.interStepDistance
                let radius = baseRadius * scale - interStepDistance * Double(index + 1) * scale

                Circle()
                    .fill(configuration.colors.pulse)
                    .blendMode(.softLight)
                    .opacity(configuration.effects.innerPulse.opacity)
                    .width(radius * 2).height(radius * 2)
                    .animation(
                        .easeInOut(duration: configuration.effects.button.scaleAnimationDuration)
                            .delay(
                                Double(configuration.effects.innerPulse.circleCount - index) * configuration
                                    .effects.innerPulse
                                    .stepAnimationDelay
                            ),
                        value: scale
                    )
            }
        }
    }
}
