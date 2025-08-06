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
    let progress: CGFloat?
    let configuration: SoundPulseButtonConfiguration
    @State
    private var trimTo: CGFloat = 0

    var body: some View {
        let radius = configuration.layout.baseRadius +
            configuration.effects.loader.padding +
            configuration.effects.loader.lineWidth / 2

        return ZStack {
            Circle()
                .trim(from: 0, to: trimTo)
                .stroke(
                    configuration.colors.loader.opacity(configuration.effects.loader.opacity),
                    style: StrokeStyle(lineWidth: configuration.effects.loader.lineWidth, lineCap: .round)
                )
                .blur(radius: configuration.effects.loader.blurRadius)
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(rotation))
                .animation(.bouncy(duration: 1.5), value: trimTo)
                .onAppear {
                    trimTo = progress ?? configuration.effects.loader.trimTo
                }
                .onChange(of: progress) { oldProgress, newProgress in
                    if oldProgress == nil, let newProgress {
                        trimTo = newProgress
                    } else if newProgress == nil {
                        trimTo = configuration.effects.loader.trimTo
                    } else if let newProgress {
                        withAnimation {
                            trimTo = newProgress
                        }
                    }
                }
        }
        .transition(.opacity)
    }
}
