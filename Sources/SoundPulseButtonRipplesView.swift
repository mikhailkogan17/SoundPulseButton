//
//  SoundPulseButtonRipplesView.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

import SwiftUI

/// Ripple waves view for SoundPulseButton
struct SoundPulseButtonRipplesView: View {
    /// Configuration for individual ripple wave
    struct WaveParameters: Identifiable {
        let id: UUID
        let radius: CGFloat
        let opacity: Double

        init(radius: CGFloat, opacity: Double) {
            id = UUID()
            self.radius = radius
            self.opacity = opacity
        }

        init(id: UUID, radius: CGFloat, opacity: Double) {
            self.id = id
            self.radius = radius
            self.opacity = opacity
        }
    }

    let waves: [WaveParameters]
    let configuration: SoundPulseButtonConfiguration

    var body: some View {
        ZStack {
            ForEach(waves) { wave in
                let lineWidth = configuration.effects.ripples.lineWidth
                let blurRadius = configuration.effects.ripples.blurRadius
                let strokeColor = configuration.colors.pulse

                Circle()
                    .stroke(strokeColor, lineWidth: lineWidth)
                    .opacity(wave.opacity)
                    .blur(radius: blurRadius)
                    .frame(width: wave.radius * 2, height: wave.radius * 2)
            }
        }
    }
}
