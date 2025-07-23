# SoundPulseButton

A highly customizable SwiftUI button component with audio level visualization and various visual effects including pulse rings, ripple waves, shimmer effects, and more.

## Visual Effects

**SoundPulseButton** provides multiple customizable visual effects that activate during different states:

### Core Effects
- **Inner Pulse Rings** - Animated circles that scale from the center, responding to audio levels with staggered delays
- **Ripple Waves** - Expanding wave effects that emanate from the button's current radius during listening state
- **Icon Shimmer** - Radial gradient shimmer overlay that sweeps across the icon with configurable timing
- **Loading Animation** - Rotating ring indicator that appears around the button during loading state
- **Background Rotation** - Smooth rotation of the gradient background when in listening mode

### Audio-Responsive Features
- **Real-time Scaling** - Button and icon dynamically scale based on audio level input (0.0 to 1.0)
- **Progressive Opacity** - Shimmer effect intensity increases with audio level
- **Staggered Animations** - Multiple pulse rings animate with calculated delays for smooth wave effect

## Features

- **Audio Level Visualization**: Real-time scaling based on audio level input
- **Pulse Rings**: Animated inner circles that scale with audio level
- **Ripple Waves**: Expanding wave effects that start from the current button radius
- **Shimmer Effect**: Radial gradient shimmer overlay on the icon
- **Loading State**: Rotating loading indicator
- **Press Effects**: Scale and opacity changes with haptic feedback
- **Background Gradient**: Customizable multicolor gradient with rotation
- **RTL Support**: Works with right-to-left layouts
- **Fully Configurable**: Every aspect can be customized through configuration

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/mikhailkogan17/SoundPulseButton", from: "0.1.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to target

## Basic Usage

```swift
import SoundPulseButton

SoundPulseButton(
    isListening: viewModel.isListening,
    isLoading: viewModel.isLoading,
    audioLevel: viewModel.audioLevel,
    onTap: handleMicrophoneTap
)
```

## Configuration Methods

### Size Presets

```swift
// Small button
SoundPulseButton(...)
    .withConfiguration(.small())

// Large button  
SoundPulseButton(...)
    .withConfiguration(.large())

// Custom size
SoundPulseButton(...)
    .withSize(60)
```

### Colors


// Custom gradient
SoundPulseButton(...)
    .withMeshGradient(
        colors: [.red, .blue, .purple],
        positions: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0.5), CGPoint(x: 0.5, y: 1)]
    )
```

### Icon

```swift
SoundPulseButton(...)
    .withIcon(Image(systemName: "mic.fill"))
```

### Effects Configuration

```swift
// Configure inner pulse rings
SoundPulseButton(...)
    .withInnerCircles(circle: 3)

// Configure ripple waves
SoundPulseButton(...)
    .withRipples(count: 3)

// Configure shimmer effect
SoundPulseButton(...)
    .withShimmer(.init(
        startDelay: 1.0,
        animationDuration: 2.0,
        radiusMultiplier: 3.0
    ))
```

## Configuration Structure

### SoundPulseButtonConfiguration

The main configuration structure with three main sections:

#### Colors
- `gradientColors`: Array of colors for the background gradient
- `gradientPositions`: Positions for gradient color stops
- `pulse`: Color for pulse rings and ripples
- `icon`: Icon color
- `shadow`: Shadow color
- `loader`: Loading indicator color

#### Layout
- `icon`: The image to display
- `baseRadius`: Base radius of the button
- `iconSize`: Size of the icon
- `frameMultiplierWidth/Height`: Frame size multipliers
- `backgroundFrameSize`: Background gradient frame size

#### Effects
Contains sub-configurations for:
- **InnerPulse**: Circle count, spacing, opacity, animation delays
- **Ripples**: Count, max offset, opacity, line width, timing
- **Loader**: Appearance, rotation, styling
- **Shimmer**: Timing, radius, visibility, blur
- **Button**: Scale effects, press animations, rotation
- **Shadow**: Opacity, radius, offsets for different states

## Animation Behavior

### Audio Level Response
- Button and icon scale based on `audioLevel` (0.0 to 1.0)
- Inner pulse rings scale with staggered delays
- Shimmer effect opacity increases with audio level

### Listening State
When `isListening` is true:
- Inner pulse rings appear
- Background gradient starts rotating
- Ripple waves begin expanding from button radius
- Shimmer effect starts after configured delay

### Loading State
When `isLoading` is true:
- Loading ring appears around the button
- Button becomes non-interactive
- Press effects are disabled

### Ripple Wave Behavior
- Each wave captures the button radius at the moment it starts
- Waves expand independently from their captured start radius
- Multiple waves can be active simultaneously with staggered timing

## Requirements

- iOS 16.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Dependencies

- [ColorfulX](https://github.com/Lakr233/ColorfulX) - For multicolor gradient backgrounds
- [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX) - For enhanced SwiftUI utilities

## Performance Considerations

- Audio level updates are throttled to ~60fps to prevent excessive redraws
- Animations use optimized SwiftUI animation modifiers
- Timers are properly invalidated when stopping animations
- Memory usage is minimal with efficient state management

## Accessibility

The button supports:
- VoiceOver navigation
- Haptic feedback for interactions
- Proper button semantics
- Dynamic type scaling (through SwiftUI automatic support)

## Thread Safety

All animations and state updates are performed on the main thread using proper SwiftUI state management.

## License

This project is available under the MIT license. See the LICENSE file for more info.

## Author

Created by Mikhail Kogan

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
