//
//  SoundPulseButtonIconView.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import SwiftUI

/// Icon view with shimmer effect for SoundPulseButton
struct SoundPulseButtonIconView: View {
    let isPulseShown: Bool
    let scale: CGFloat
    let shimmerRadius: CGFloat
    let configuration: SoundPulseButtonConfiguration

    var body: some View {
        ZStack {
            baseIcon
            activeIcon
            shimmerEffect
        }
        .mask {
            iconMask
        }
    }

    private var baseIcon: some View {
        configuration.colors.icon
            .opacity(isPulseShown ? 0 : 1)
    }

    private var activeIcon: some View {
        configuration.colors.icon
            .opacity(configuration.effects.shimmer.baseOpacity)
    }

    @ViewBuilder
    private var shimmerEffect: some View {
        if isPulseShown {
            RadialGradient(
                colors: [
                    .clear,
                    .clear,
                    .white.opacity(0.67),
                    .white.opacity(0.33),
                    .white,
                    .white.opacity(0.33),
                    .white.opacity(0.67),
                    .clear,
                    .clear
                ],
                center: .center,
                startRadius: shimmerRadius * configuration.effects.shimmer.startRadiusMultiplier,
                endRadius: shimmerRadius
            )
            .padding(.bottom, configuration.effects.shimmer.bottomPadding)
            .blur(radius: configuration.effects.shimmer.blurRadius)
        }
    }

    private var iconMask: some View {
        configuration.layout.icon
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: configuration.layout.iconSize)
            .frame(height: configuration.layout.iconSize)
            .scaleEffect(scale)
            .foregroundStyle(configuration.colors.icon)
            .animation(
                .easeInOut(duration: configuration.effects.button.scaleAnimationDuration),
                value: scale
            )
    }
}
