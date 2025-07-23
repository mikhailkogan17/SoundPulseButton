//
//  SoundPulseButtonLoaderView.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import SwiftUI

/// Loading indicator view for SoundPulseButton
struct SoundPulseButtonLoaderView: View {
    let rotation: Double
    let configuration: SoundPulseButtonConfiguration

    var body: some View {
        let radius = configuration.layout.baseRadius +
            configuration.effects.loader.padding +
            configuration.effects.loader.lineWidth / 2

        return ZStack {
            Circle()
                .trim(from: 0, to: configuration.effects.loader.trimTo)
                .stroke(
                    configuration.colors.loader.opacity(configuration.effects.loader.opacity),
                    style: StrokeStyle(lineWidth: configuration.effects.loader.lineWidth, lineCap: .round)
                )
                .blur(radius: configuration.effects.loader.blurRadius)
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(rotation))
        }
        .transition(.opacity)
    }
}
