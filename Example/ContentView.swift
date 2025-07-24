//
//  ContentView.swift
//  SoundPulseButton Example
//
//  Created by Mikhail Kogan on 23/07/2025.
//

import SoundPulseButton
import SwiftUI

struct ContentView: View {
    @State
    private var isListening = false
    @State
    private var isLoading = false

    private let mockAudioProvider = MockAudioProvider()

    var body: some View {
        VStack(spacing: 30) {
            // Controls
            controlsSection

            // Effects Examples
            effectsGrid
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 16) {
            Text("Controls")
                .font(.headline)

            HStack(spacing: 20) {
                Button(isListening ? "Stop Listening" : "Start Listening") {
                    isListening.toggle()
                }
                .buttonStyle(.borderedProminent)

                Button(isLoading ? "Stop Loading" : "Start Loading") {
                    isLoading.toggle()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var effectsGrid: some View {
        HStack(alignment: .top, spacing: 20) {
            // Background Rotation Effect
            effectExample(
                title: "Background Rotation",
                description: "Rotates background during listening"
            ) {
                SoundPulseButton(
                    isListening: isListening,
                    isLoading: isLoading,
                    audioBufferProvider: mockAudioProvider,
                    onTap: { }
                )
                .withBackground(idle: .mesh(
                    [.purple, .indigo, .cyan]
                ), listening: .mesh(
                    [.purple, .indigo, .cyan]
                ))
                .withBackgroundRotation(
                    idle: false,
                    listening: true
                )
            }

            // Icon Shimmer Effect
            effectExample(
                title: "Icon Shimmer",
                description: "Adds shimmer effect to the icon during listening"
            ) {
                SoundPulseButton(
                    isListening: isListening,
                    isLoading: isLoading,
                    audioBufferProvider: mockAudioProvider,
                    onTap: { }
                )
                .withBackground(idle: .mesh(
                    [.purple, .indigo, .cyan]
                ), listening: .mesh(
                    [.purple, .indigo, .cyan]
                ))
                .withIconShimmering()
            }

            // Inner Circles Count Effect
            effectExample(
                title: "Inner Circles",
                description: "Shows 3 inner pulse circles"
            ) {
                SoundPulseButton(
                    isListening: isListening,
                    isLoading: isLoading,
                    audioBufferProvider: mockAudioProvider,
                    onTap: { }
                )
                .withBackground(idle: .mesh(
                    [.purple, .indigo, .cyan]
                ), listening: .mesh(
                    [.purple, .indigo, .cyan]
                ))
                .withInnerCircles(count: 3)
            }

            // Ripples Count Effect
            effectExample(
                title: "Ripples",
                description: "Shows ripple waves"
            ) {
                SoundPulseButton(
                    isListening: isListening,
                    isLoading: isLoading,
                    audioBufferProvider: mockAudioProvider,
                    onTap: { }
                )
                .withBackground(idle: .mesh(
                    [.purple, .indigo, .cyan]
                ), listening: .mesh(
                    [.purple, .indigo, .cyan]
                ))
                .withRipples(count: 1)
            }

            // Shadow Effect
            effectExample(
                title: "Shadow",
                description: "Adds shadow"
            ) {
                SoundPulseButton(
                    isListening: isListening,
                    isLoading: isLoading,
                    audioBufferProvider: mockAudioProvider,
                    onTap: { }
                )
                .withBackground(idle: .mesh(
                    [.purple, .indigo, .cyan]
                ), listening: .mesh(
                    [.purple, .indigo, .cyan]
                ))
                .withShadow()
            }
        }
    }

    private func effectExample(
        title: String,
        description: String,
        @ViewBuilder content: () -> some View
    )
        -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.bold())
                .lineLimit(0)
                .multilineTextAlignment(.center)
                .frame(minHeight: 44)

            content()
                .frame(width: 150, height: 150)
                .padding(.vertical)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 40)
        }
        .padding()
        .frame(width: 250)
    }
}

#Preview {
    ContentView()
}
