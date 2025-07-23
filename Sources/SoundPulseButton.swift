//
//  SoundPulseButton.swift
//  SoundPulseButton
//
//  Created by Mikhail Kogan on 24/06/2025.
//

@preconcurrency import AVFoundation
import ColorfulX
import SwiftUI
import SwiftUIX

/// A customizable sound pulse button with audio level visualization and various effects
@MainActor
public struct SoundPulseButton: View {
    // MARK: - Public Properties

    public let isListening: Bool
    public let isLoading: Bool

    public let onTap: () -> Void

    public var configuration: SoundPulseButtonConfiguration = .default

    // MARK: - Private State

    @State
    private var showPulse = false
    @State
    private var showLoader = false
    @State
    private var loaderRotation: Double = 0
    @State
    private var backgroundRotation: Double = 0
    @State
    private var isRotationActive = false
    @State
    private var shimmerRadius: CGFloat = 0
    @State
    private var rippleWaves: [SoundPulseButtonRipplesView.WaveParameters] = []
    @State
    private var rippleTask: Task<Void, Never>?
    @State
    private var shimmerTask: Task<Void, Never>?
    @State
    private var audioLevel: Double = 0
    @State
    private var buttonRadius: CGFloat = 0
    private let audioBufferProvider: SoundPulseButtonAudioBufferProvider
    @State
    private var audioLevelRepository: AudioLevelRepository?

    @Environment(\.colorScheme)
    private var colorScheme

    // MARK: - Initialization

    /// Creates a SoundPulseButton with the specified parameters
    /// - Parameters:
    ///   - isListening: Whether the button is actively listening
    ///   - isLoading: Whether the button is in loading state
    ///   - audioBufferProvider: Provider for audio buffer stream
    ///   - onTap: Callback when button is tapped
    public init(
        isListening: Bool,
        isLoading: Bool,
        audioBufferProvider: SoundPulseButtonAudioBufferProvider,
        onTap: @escaping () -> Void
    ) {
        self.isListening = isListening
        self.isLoading = isLoading
        self.audioBufferProvider = audioBufferProvider
        self.onTap = onTap
    }

    // MARK: - Body

    public var body: some View {
        button
            ._onAppearAndChange(of: audioLevel) { newValue in
                audioLevel = newValue
                updateAnimationState()
            }
            .onChange(of: isListening) {
                updateAnimationState()
            }
            .onChange(of: showPulse) { _, newValue in
                if newValue {
                    startListeningAnimation()
                } else {
                    stopListeningAnimation()
                }
            }
            .onChange(of: isLoading) { _, newValue in
                if newValue {
                    startLoadingAnimation()
                } else {
                    stopLoadingAnimation()
                }
            }
            .task {
                await setupAudioLevel()
            }
    }

    // MARK: - Private Views

    private var button: some View {
        Button {
            guard !isLoading else { return }
            onTap()
        } label: {
            ZStack {
                SoundPulseButtonBackgroundView(
                    isListening: isListening,
                    rotation: isRotationActive ? backgroundRotation : 0,
                    configuration: configuration
                )
                .width(configuration.layout.baseRadius * configuration.layout.frameMultiplier)
                .height(configuration.layout.baseRadius * configuration.layout.frameMultiplier)
                .mask {
                    backgroundMask
                }

                innerPulse
                    .opacity(showPulse ? 1.0 : 0.0)

                buttonIcon
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .clipShape(Circle())
        }
        .buttonStyle(SoundPulseButtonStyle(
            isListening: isListening,
            isPulseVisible: showPulse,
            isLoading: isLoading,
            configuration: configuration
        ))
        .disabled(isLoading)
        .width(configuration.layout.baseRadius * configuration.layout.frameMultiplier)
        .height(configuration.layout.baseRadius * configuration.layout.frameMultiplier)
        .clipShape(Circle())
        .contentShape(Circle())
        .padding(.vertical)
    }

    private var backgroundMask: some View {
        ZStack {
            Circle()
                .width(buttonRadius * 2).height(buttonRadius * 2)
                .animation(
                    .easeInOut(duration: configuration.effects.button.scaleAnimationDuration)
                        .delay(
                            configuration.effects.innerPulse
                                .stepAnimationDelay * Double(configuration.effects.innerPulse.circleCount + 1)
                        ),
                    value: audioLevel
                )

            if showLoader {
                loader
            }
        }
        .overlay(
            ripples
                .opacity(showPulse ? 1.0 : 0.0)
                .allowsHitTesting(false)
        )
    }

    private var loader: some View {
        SoundPulseButtonLoaderView(rotation: loaderRotation, configuration: configuration)
    }

    private var ripples: some View {
        SoundPulseButtonRipplesView(
            waves: rippleWaves,
            configuration: configuration
        )
    }

    private var innerPulse: some View {
        SoundPulseButtonInnerCirclesView(
            scale: scale,
            configuration: configuration
        )
    }

    private var buttonIcon: some View {
        SoundPulseButtonIconView(
            isPulseShown: showPulse,
            scale: scale,
            shimmerRadius: shimmerRadius,
            configuration: configuration
        )
    }

    // MARK: - Computed Properties

    private var scale: CGFloat {
        guard showPulse else {
            return 1.0
        }
        return 1.0 + CGFloat(audioLevel) * configuration.effects.button.scaleMultiplier
    }

    // MARK: - Animation Methods

    private func startListeningAnimation() {
        updatePulseState(isVisible: true)
        if configuration.background.rotation.listening {
            startBackgroundRotation()
        }
        startShimmerAnimation()
        startRipplesAnimation()
    }

    private func stopListeningAnimation() {
        updatePulseState(isVisible: false)
        if !configuration.background.rotation.idle {
            stopBackgroundRotation()
        }
        stopShimmerAnimation()
        stopRipplesAnimation()
    }

    private func startLoadingAnimation() {
        withAnimation(.easeInOut(duration: configuration.effects.loader.appearanceDuration)) {
            showLoader = true
            withAnimation(
                .linear(duration: configuration.effects.loader.rotationDuration)
                    .repeat(while: showLoader)
            ) {
                loaderRotation = 360
            }
        }
    }

    private func stopLoadingAnimation() {
        withAnimation(.easeInOut(duration: configuration.effects.loader.appearanceDuration)) {
            showLoader = false
            loaderRotation = 0
        }
    }

    private func updatePulseState(isVisible: Bool) {
        withAnimation(.easeInOut(duration: configuration.effects.button.listeningAnimationDuration)) {
            showPulse = isVisible
        }

        withAnimation(
            .easeInOut(duration: configuration.effects.button.scaleAnimationDuration)
                .delay(
                    configuration.effects.innerPulse
                        .stepAnimationDelay * Double(configuration.effects.innerPulse.circleCount + 1)
                )
        ) {
            buttonRadius = configuration.layout.baseRadius * scale
        }
    }

    private func startBackgroundRotation() {
        isRotationActive = true
        withAnimation(
            .linear(duration: configuration.effects.button.backgroundRotationDuration)
                .repeat(while: isRotationActive)
        ) {
            backgroundRotation = 360
        }
    }

    private func stopBackgroundRotation() {
        withAnimation(.easeInOut(duration: configuration.effects.button.listeningAnimationDuration)) {
            isRotationActive = false
            backgroundRotation = 0
        }
    }

    private func startShimmerAnimation() {
        shimmerTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(configuration.effects.shimmer.startDelay))

            while !Task.isCancelled {
                startShimmerCycle()

                let cycleInterval = configuration.effects.shimmer.animationDuration + configuration.effects.ripples
                    .pauseBetweenCycles
                try? await Task.sleep(for: .seconds(cycleInterval))
            }
        }
    }

    private func startShimmerCycle() {
        shimmerRadius = 0
        withAnimation(
            .linear(duration: configuration.effects.shimmer.animationDuration)
        ) {
            shimmerRadius = configuration.layout.iconSize * configuration.effects.shimmer.radiusMultiplier
        }
    }

    private func stopShimmerAnimation() {
        shimmerTask?.cancel()
        shimmerTask = nil
    }

    private func startRipplesAnimation() {
        rippleWaves.removeAll()

        rippleTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(configuration.effects.ripples.startDelay))

            while !Task.isCancelled {
                await createRippleCycle()

                try? await Task.sleep(for: .seconds(configuration.effects.ripples.pauseBetweenCycles))
            }
        }
    }

    private func stopRipplesAnimation() {
        rippleTask?.cancel()
        rippleTask = nil
        withAnimation {
            for (index, wave) in rippleWaves.enumerated() {
                rippleWaves[index] = .init(
                    id: wave.id,
                    radius: configuration.layout.baseRadius - configuration.effects.ripples.startInset,
                    opacity: 0
                )
            }
        }
    }

    @MainActor
    private func createRippleCycle() async {
        for index in 0 ..< configuration.effects.ripples.count {
            if index > 0 {
                try? await Task.sleep(for: .seconds(configuration.effects.ripples.pauseBetweenSteps))
            }
            createRippleWave()
        }
    }

    private func createRippleWave() {
        let startRadius = buttonRadius - configuration.effects.ripples.startInset
        let maxRadius = startRadius + configuration.effects.ripples.maxOffset

        // Create wave configuration with initial state
        let wave = SoundPulseButtonRipplesView.WaveParameters(
            radius: startRadius,
            opacity: configuration.effects.ripples.baseOpacity
        )
        rippleWaves.append(wave)

        // Animate wave expansion
        withAnimation(.easeOut(duration: configuration.effects.ripples.animationDuration)) {
            // Update the wave in the array
            if let index = rippleWaves.firstIndex(where: { $0.id == wave.id }) {
                rippleWaves[index] = .init(
                    id: wave.id,
                    radius: maxRadius,
                    opacity: 0
                )
            }
        }

        // Remove wave after animation
        Task {
            try? await Task.sleep(for: .seconds(configuration.effects.ripples.animationDuration + 0.1))
            rippleWaves.removeAll { $0.id == wave.id }
        }
    }

    private func updateAnimationState() {
        if isListening {
            updatePulseState(isVisible: true)
        } else {
            updatePulseState(isVisible: false)
        }

        // Handle background rotation based on current state
        let shouldRotate = isListening
            ? configuration.background.rotation.listening
            : configuration.background.rotation.idle
        if shouldRotate, !isRotationActive {
            startBackgroundRotation()
        } else if !shouldRotate, isRotationActive {
            stopBackgroundRotation()
        }

        if isLoading {
            startLoadingAnimation()
        } else {
            stopLoadingAnimation()
        }
    }

    private func setupAudioLevel() async {
        let audioLevelRepository = AudioLevelRepository()
        self.audioLevelRepository = audioLevelRepository

        // Start processing audio buffers in background
        Task.detached {
            for await buffer in await audioBufferProvider.audioBufferStream {
                await audioLevelRepository.processAudioBuffer(buffer)
            }
        }

        // Listen to audio level updates on main actor
        for await level in await audioLevelRepository.audioLevelStream {
            await MainActor.run {
                audioLevel = level
            }
        }
    }
}

// MARK: - Configuration Methods

public extension SoundPulseButton {
    /// Apply a custom configuration to the button
    func withConfiguration(_ configuration: SoundPulseButtonConfiguration) -> SoundPulseButton {
        var copy = self
        copy.configuration = configuration
        return copy
    }

    /// Configure the button size (affects both base radius and icon size)
    func withSize(_ size: CGFloat) -> SoundPulseButton {
        var copy = self
        copy.configuration.layout.baseRadius = size
        copy.configuration.layout.iconSize = size
        return copy
    }

    /// Configure the button icon
    func withIcon(_ image: Image) -> SoundPulseButton {
        var copy = self
        copy.configuration.layout.icon = image
        return copy
    }

    /// Configure loading indicator
    func withLoader(_ loaderConfig: SoundPulseButtonConfiguration.Effects.Loader = .init()) -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.loader = loaderConfig
        return copy
    }

    /// Configure background for different states
    func withBackground(idle: SoundPulseButtonBackground, listening: SoundPulseButtonBackground) -> SoundPulseButton {
        var copy = self
        copy.configuration.background.idle = idle
        copy.configuration.background.listening = listening
        return copy
    }

    /// Configure background rotation for different states
    func withBackgroundRotation(idle: Bool, listening: Bool) -> SoundPulseButton {
        var copy = self
        copy.configuration.background.rotation.idle = idle
        copy.configuration.background.rotation.listening = listening
        return copy
    }

    /// Configure icon shimmer effect
    func withIconShimmering(
        _ shimmerConfig: SoundPulseButtonConfiguration.Effects
            .Shimmer = .init()
    )
        -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.shimmer = shimmerConfig
        return copy
    }

    /// Configure inner pulse circles
    func withInnerCircles(
        _ innerPulseConfig: SoundPulseButtonConfiguration.Effects
            .InnerPulse = .init()
    )
        -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.innerPulse = innerPulseConfig
        return copy
    }

    /// Configure inner pulse circles with count
    func withInnerCircles(count: Int) -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.innerPulse.circleCount = count
        return copy
    }

    /// Configure ripple waves
    func withRipples(_ ripplesConfig: SoundPulseButtonConfiguration.Effects.Ripples = .init()) -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.ripples = ripplesConfig
        return copy
    }

    /// Configure ripple waves with count
    func withRipples(count: Int) -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.ripples.count = count
        return copy
    }

    /// Configure haptic feedback
    func withHaptic(enabled: Bool = true) -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.button.hapticEnabled = enabled
        return copy
    }

    /// Configure shadow effects
    func withShadow(_ shadowConfig: SoundPulseButtonConfiguration.Effects.Shadow = .init()) -> SoundPulseButton {
        var copy = self
        copy.configuration.effects.shadow = shadowConfig
        return copy
    }
}

// MARK: - Animation Extension

private extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = false) -> Animation {
        if expression {
            repeatForever(autoreverses: autoreverses)
        } else {
            self
        }
    }
}

// MARK: - Mock Audio Buffer Provider

private class MockAudioBufferProvider: SoundPulseButtonAudioBufferProvider, @unchecked Sendable {
    var audioBufferStream: AsyncStream<AVAudioPCMBuffer> {
        AsyncStream { continuation in
            Task {
                let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
                let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)!

                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(16))
                    continuation.yield(buffer)
                }
                continuation.finish()
            }
        }
    }
}

