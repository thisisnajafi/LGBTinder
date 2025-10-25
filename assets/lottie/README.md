# Lottie Animations

This directory contains Lottie animation files (.json) for the LGBTinder app.

## Required Animation Files

### Loading Animations
- `loading.json` - General loading spinner
- `loading_hearts.json` - Loading with animated hearts
- `loading_rainbow.json` - Rainbow-themed loading animation

### Success & Celebration
- `success.json` - Success checkmark animation
- `celebration.json` - Confetti/celebration animation
- `match_celebration.json` - Special animation for matches
- `heart_burst.json` - Hearts bursting animation

### Profile & Verification
- `profile_complete.json` - Profile completion celebration
- `verification_success.json` - Verification approved animation
- `photo_upload.json` - Photo upload progress animation

### Empty States
- `empty_matches.json` - No matches found
- `empty_chat.json` - No messages yet
- `empty_notifications.json` - No notifications

### Error States
- `error.json` - General error animation
- `network_error.json` - Network connection error
- `something_wrong.json` - Something went wrong

### Interactive Elements
- `swipe_left.json` - Swipe left hint animation
- `swipe_right.json` - Swipe right hint animation
- `like_animation.json` - Heart like animation
- `super_like_animation.json` - Super like star animation

### Premium Features
- `premium_badge.json` - Premium membership badge
- `unlock_feature.json` - Feature unlock animation
- `boost_profile.json` - Profile boost animation

## Animation Guidelines

- Format: Lottie JSON (.json)
- Size: Keep under 200KB per file
- Duration: 1-3 seconds for most animations
- Loop: Configure per use case
- Colors: Should match app theme (LGBT rainbow palette)

## Lottie Sources

You can find free Lottie animations from:
- [LottieFiles.com](https://lottiefiles.com/) - Largest collection
- [Icons8 Lottie](https://icons8.com/lottie-animations)
- [Lottielab](https://www.lottielab.com/)

## Creating Custom Animations

Tools for creating Lottie animations:
- Adobe After Effects with Bodymovin plugin
- Lottielab (Online editor)
- Haiku Animator
- Rive (alternative format)

## License

Ensure all animations are either:
- Created by you
- Licensed for commercial use
- Properly attributed if required
- Free from copyright restrictions

## Integration

Animations are loaded using the `lottie` package:
```dart
Lottie.asset('assets/lottie/animation_name.json')
```

See `lib/components/animations/lottie_animations.dart` for pre-configured animations.

