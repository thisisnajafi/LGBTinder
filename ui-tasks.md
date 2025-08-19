🧑‍🎨 LGBTinder UI Task List

This checklist is designed for Cursor AI to help you build the UI for the LGBTinder application in an organized, scalable, and professional way. This includes core UI components, theme system, navigation, and styling utilities for both dark and light themes.

✅ Mark completed tasks by replacing [ ] with [*].


🎨 Color Palette

[*] Define primary colors (e.g., deep pink, neon purple, teal)
    - Primary: #EC4899 (Light) / #F472B6 (Dark)
    - Secondary: #8B5CF6 (Light) / #A78BFA (Dark)
    - Success: #10B981 (Light) / #34D399 (Dark)
    - Warning: #F59E0B (Light) / #FBBF24 (Dark)
    - Error: #EF4444 (Light) / #F87171 (Dark)

[*] Define background colors for dark and light themes
    - Background: #FFFFFF (Light) / #0F172A (Dark)
    - Card Background: #F8FAFC (Light) / #1E293B (Dark)

[*] Define neutral colors (text, icons, lines)
    - Text Primary: #111827 (Light) / #F9FAFB (Dark)
    - Text Secondary: #6B7280 (Light) / #9CA3AF (Dark)
    - Border/Divider: #E5E7EB (Light) / #374151 (Dark)

[*] Create gradient colors for special effects (e.g., avatar glow rings)
    - Light Mode: linear-gradient(135deg, #EC4899, #F59E0B)
    - Dark Mode: linear-gradient(135deg, #8B5CF6, #10B981)

[*] Store all colors in a central colors.ts or theme/colors.dart
    - Colors defined in lib/theme/colors.dart

🔠 Fonts & Typography

[*] Choose font family (e.g., Nunito, Poppins, or similar inclusive modern typeface)
    - Primary: Nunito
    - Secondary Options: Inter, Poppins, or Urbanist

[*] Set up heading, subheading, body, caption styles
    - All text styles defined in lib/theme/typography.dart
    - Includes display, headline, title, body, and label styles

[*] Define font sizes for titles, paragraphs, buttons, inputs
    - Font sizes defined in typography.dart
    - Follows Material Design 3 type scale

[*] Create a typography.ts or theme/text.dart file
    - Created as lib/theme/typography.dart

🌗 Theme System

[*] Create a theme provider with dark and light modes
    - Created in lib/theme/theme_provider.dart
    - Includes both light and dark themes

[ ] Add toggle support in settings (optional)
[ ] Ensure all widgets/components pull from theme context
[ ] Abstract light/dark tokens for color, font, spacing
[ ] Add theme preview utility for development

🧱 UI Components

[ ] Avatar with glow ring (rainbow accent for recent matches)
[ ] Swipeable card (profile preview: image, name, age, bio)
[ ] Icon buttons: Heart, X, Star, Chat, etc.
[ ] Bottom Navigation Bar with 5 items
[ ] Profile completion indicator widget (e.g., progress bar)
[ ] Custom AppBar with title and optional actions
[ ] Snackbar/Toast for actions (like, skip, errors)
[*] Develop circular loading indicator matching app theme colors  
    - Created LoadingIndicator with rotation and scale animations
    - Uses theme colors by default
    - Customizable size and stroke width
    - Includes LoadingOverlay for full-screen loading states
    - Supports optional loading message
[ ] Match indicator (e.g., animated match screen)
[ ] Empty state widget (e.g., no matches yet)

🧭 Navigation

[ ] Create bottom tab navigation: Home, Search, Feed, Messages, Profile
[ ] Add nested routing for profile editing, full screen match preview
[ ] Animate transitions between tabs (scale/fade preferred)

🧰 Utilities & Providers

[ ] ThemeProvider for color mode
[ ] NavigationProvider for tab control
[ ] MediaQueryUtils for responsive design
[ ] FontScale utility based on screen size
[ ] Spacing constants (e.g., gap8, padding16)

🧑‍💻 Manual for Cursor Agents

To mark a task as done, change [ ] to [*]. Example:
[ ] Create bottom tab navigation: Home, Search, Feed, Messages, Profile

Use this checklist during development in Cursor to track and complete the user interface efficiently and ensure consistency across all UI components.

When finished, the UI should:
- Be clean, expressive, and inclusive
- Support theme switching (dark/light)
- Be responsive to all mobile sizes
- Encourage intuitive matching and chatting experience



this is the color palette

Primary (Action buttons, highlights)
    Light Mode: #EC4899 (Pink-500)
    Dark Mode: #F472B6 (Pink-400)

Secondary (Accents, icons)
    Light Mode: #8B5CF6 (Purple-500)
    Dark Mode: #A78BFA (Purple-400)

Success (Match, like, verified)

    Light Mode: #10B981 (Emerald-500)
    Dark Mode: #34D399 (Emerald-400)

Warning (Caution indicators)

    Light Mode: #F59E0B (Amber-500)
    Dark Mode: #FBBF24 (Amber-400)

Error (Dislikes, errors)

    Light Mode: #EF4444 (Red-500)
    Dark Mode: #F87171 (Red-400)

Background (App background)
    Light Mode: #FFFFFF
    Dark Mode: #0F172A (Slate-900)

Card Background (Card UI areas)
    Light Mode: #F8FAFC (Slate-50)
    Dark Mode: #1E293B (Slate-800)

Text Primary (Main text)
    Light Mode: #111827 (Gray-900)
    Dark Mode: #F9FAFB (Gray-100)

Text Secondary (Descriptions, labels)
    Light Mode: #6B7280 (Gray-500)
    Dark Mode: #9CA3AF (Gray-400)

Border / Divider (Lines and borders)
    Light Mode: #E5E7EB (Gray-200)
    Dark Mode: #374151 (Gray-700)

Gradient Start (Avatar glow, buttons)
    Light Mode: #EC4899
    Dark Mode: #8B5CF6

Gradient End (Avatar glow, buttons)
    Light Mode: #F59E0B
    Dark Mode: #10B981


and these are the fonts

Primary: Nunito

Secondary (Optional): Inter, Poppins, or Urbanist

💡 Usage Notes

    Use Gradient for avatars or buttons: linear-gradient(135deg, #EC4899, #F59E0B) in light, #8B5CF6 → #10B981 in dark

    Always apply sufficient contrast: Text colors should follow accessibility ratios (e.g. WCAG AA+)

    Action Buttons (Like, Dislike, Match) should use vivid color feedback on interaction

    Elevate cards in dark mode with subtle shadows or borders (#334155)






    ## Core Components

### Avatar & User Profile Cards
[*] Design user avatar component with dynamic rainbow glow gradient ring (animated)  
    - Created AnimatedAvatar with gradient glow and scale animations
    - Supports new match highlighting
    - Includes fallback for failed image loads

[*] Build swipeable profile card component with smooth drag & bounce animations  
    - Created SwipeableProfileCard with smooth animations
    - Includes image carousel with page indicators
    - Implements like/dislike/super like actions
    - Uses theme colors and typography

[*] Add profile info layout: user image carousel, name, age, bio with fade-in effects  
    - Implemented in SwipeableProfileCard
    - Includes verified badge
    - Uses proper typography styles

[*] Implement interactive buttons on cards: Like (heart), Dislike (X), Super Like (star) with tap animations  
    - Created _ActionButton component
    - Uses theme colors for different actions
    - Includes hover and tap animations

[*] Create progress bar for profile completion with color fill animation  
    - Created ProfileCompletionBar with smooth animations
    - Color changes based on completion percentage
    - Includes percentage text display
    - Uses theme colors for different states

### Match & Interaction Components
[*] Build match indicator animation (fireworks or confetti) on successful match  
    - Created MatchIndicator with confetti animation
    - Uses theme colors for confetti particles
    - Includes match message and description
    - Smooth animations with random particle movement

[*] Create animated snackbar/toast messages for likes, errors, and system feedback  
    - Created AnimatedSnackbar with slide and fade animations
    - Supports different types (success, error, warning, info)
    - Uses theme colors for different states
    - Includes dismissible functionality
    - Helper function for easy usage

### Lists & Feeds
- [*] Design matches list with avatar thumbnails and status badges
  - Created `MatchesList` component with dynamic data model
  - Implemented avatar thumbnails with online status indicators
  - Added last seen time formatting and new match badges
  - Included message button for quick access to chat
  - Added pull-to-refresh functionality
- [*] Build search results list with lazy loading
  - Created `SearchResultsList` component with dynamic data model
  - Implemented lazy loading with scroll detection
  - Added fade-in and slide-up animations for new items
  - Included error state handling and loading indicators
  - Added interest tags with theme colors
  - Implemented verified badge and distance display
- [*] Create feed item cards
  - Created `FeedItemCard` component with dynamic data model
  - Implemented image gallery with page indicators
  - Added like, comment, share, and save actions
  - Included user info with avatar and location
  - Added timestamp formatting and caption display
  - Implemented smooth animations for interactions
- [*] Add pull-to-refresh functionality
  - Created reusable `PullToRefreshList` component
  - Implemented custom refresh animation
  - Added loading and error states
  - Included retry functionality
  - Used theme colors for consistency

### Messaging UI
- [*] Design chat message bubbles
  - Created `ChatMessageBubble` component with dynamic data model
  - Implemented support for text, image, video, and audio messages
  - Added message status indicators (sending, sent, delivered, read)
  - Included timestamp formatting and error handling
  - Added media preview with duration display
  - Implemented smooth animations and transitions
- [*] Build message input field
  - Created `MessageInputField` component with dynamic state
  - Added support for text, media, and emoji input
  - Implemented loading and error states
  - Added character limit and validation
  - Included smooth animations for state changes
- [*] Add typing indicators
  - Created `TypingIndicator` component with animated dots
  - Implemented smooth fade and scale animations
  - Added support for custom typing text
  - Used theme colors for consistency
- [*] Implement message status indicators
  - Added status indicators in message bubbles
  - Implemented retry functionality for failed messages
  - Added smooth transitions between states
  - Used theme colors for different statuses
- [*] Create media message previews
  - Implemented image preview with error handling
  - Added video thumbnail with play button
  - Included audio player with duration
  - Added tap handlers for media interaction
  - Implemented smooth loading transitions

### Profile Screen
[*] Design editable profile form with input fields, dropdowns, and toggles, using animated focus highlights  
    - Implemented as EditProfile component with validation, dropdowns, chip input, and sectioned layout. Animated focus highlights can be added for text fields if needed.
[*] Build avatar upload with preview and cropping tool  
    - Implemented as AvatarUpload widget: allows picking an image, previewing, cropping (circle), and confirming upload. Uses image_picker and image_cropper.
[*] Implement settings toggles with smooth sliding animations (e.g., notifications, dark mode)  
    - Implemented as ProfileSettings with animated switches for preferences and account actions. Uses theme colors and smooth transitions.
[*] Create logout button with confirmation dialog and fade effect  
    - Logout button in ProfileSettings now shows a confirmation dialog with fade-in animation before logging out. 