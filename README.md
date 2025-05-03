# Social Circle Manager

A Flutter application to simplify organizing social events by intelligently connecting friends, understanding their preferences, and streamlining the planning process.

## Current Status

See [progress.md](./progress.md) for detailed information about the current development status and next steps.

## Project Structure

This application follows a modular, feature-first organization:

```
lib/
  ├── core/                  # Core application setup, theme, routing, utilities
  │   └── theme/             # Application theming
  ├── features/              # Feature modules
  │   ├── auth/              # Authentication (login, signup, onboarding)
  │   ├── circles/           # Social circles management
  │   ├── events/            # Event planning and management
  │   ├── chat/              # Chat functionality
  │   ├── billing/           # Bill splitting
  │   ├── explore/           # Discovery and search
  │   └── profile/           # User profile management
  ├── shared_components/     # Reusable UI components
  ├── offline/               # Offline data management
  └── tutorials/             # In-app tutorials and guidance
```

## Design System

This application follows a consistent design system with these key elements:

- **Color Palette:**
  - Primary (Blue #4A90E2): Core UI elements, navigation, primary actions
  - Secondary (Purple #7B1FA2): AI/LLM-related elements
  - Accent (Peach #E07A5F): Call-to-action, highlights
  - System colors for success, warning, error, and info states

- **Typography:**
  - Uses Inter font family via shadcn_ui theme
  - Maintains consistent text hierarchy
  - Supports dynamic text sizes for accessibility

- **Component Library:**
  - Using shadcn_ui v0.25.0 as the primary UI component library
  - Custom branded components based on shadcn_ui primitives

- **Iconography:**
  - Using hugeicons v0.0.11 for consistent iconography
  - Stroke-based icons with consistent sizing

- **Animations:**
  - Subtle, purposeful animations using flutter_animate
  - Text animations using pretty_animated_text

## Setup Instructions

1. Ensure Flutter is installed and configured properly
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Configure Firebase:
   - Create a Firebase project
   - Add Android and iOS apps to the project
   - Download and add the configuration files
5. Configure Supabase:
   - Create a Supabase project
   - Update the URL and anon key in the code
6. Run the application: `flutter run`

## Dependencies

This project uses the following key dependencies:

- UI Components: `shadcn_ui` v0.25.0
- Icons: `hugeicons` v0.0.11
- Animations: `flutter_animate` and `pretty_animated_text` v2.0.0
- State Management: `provider`
- Backend: `supabase_flutter`
- Analytics: Firebase services
- Network State: `connectivity_plus`
- Secure Storage: `flutter_secure_storage`
- And more specified in pubspec.yaml

## Development Workflow

- Follow the feature-first organization
- Maintain code style and linting rules
- Use the specified libraries for consistency
- Follow the established design system
- Update progress.md as features are completed 