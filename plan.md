# Social Circle Manager - Front-End Build Plan (Flutter)

This document outlines a phased approach to building the Flutter front-end for the Social Circle Manager (SCM) application, referencing the features (F#) and design requirements (D#) from the PRD. The plan prioritizes modularity and leverages the specified UI libraries (`shadcn_ui`, `hugeicons`).

**Core Technologies & Libraries:**

* **Framework:** Flutter (NFR1)
* **UI Component Library:** `shadcn_ui` Flutter package (D2)
* **Icons:** `hugeicons` package (D1)
* **State Management:** Provider, Riverpod, or BLoC/Cubit (NFR13.1) - *To be decided early.*
* **Backend Service:** Supabase for authentication, database, storage, and real-time subscriptions
* **Permissions:** `permission_handler` (D2)
* **Calendar:** `device_calendar` (D2)
* **Charting:** `fl_chart`, `graphic`, or similar (D2) - *To be selected based on compatibility and themeability.*
* **Navigation:** Flutter's built-in Navigator or a package like `go_router`.
* **Analytics/Crash Reporting:** Firebase Analytics/Crashlytics or Sentry (NFR7)
* **Remote Config:** Firebase Remote Config (NFR9)
* **Network State:** `connectivity_plus` for monitoring network connectivity
* **Secure Storage:** `flutter_secure_storage` for storing sensitive information
* **Animations:** `flutter_animate` for custom animations (D2)
* **Text Animations:** `pretty_animated_text` for selective emphasis (D4)
* **Internationalization:** Flutter's `intl` package for future localization support (NFR14)

**Modular Structure (Conceptual):**

* `core`: Project setup, theme, routing, base widgets, utilities, network, error handling.
* `auth`: Onboarding, login, signup, profile setup, permissions.
* `circles`: Circle listing, creation, details (dashboard), member management.
* `events`: Event listing, planning flow, details, calendar integration, reminders.
* `chat`: Circle & event chat UI and logic.
* `billing`: Bill splitting UI and logic.
* `explore`: Search/discovery UI and logic.
* `profile`: User profile view, settings management.
* `shared_components`: Reusable UI elements (e.g., themed cards, loading indicators).
* `offline`: Offline data management, synchronization logic.
* `tutorials`: In-app tutorials and guidance components.

---

## Phase 0: Project Setup & Foundation

**Goal:** Establish the core project structure, dependencies, theming, and basic navigation shell.

1.  **Initialize Flutter Project:** Create a new Flutter project (NFR1).
2.  **Dependency Integration:**
    * Add `shadcn_ui`, `hugeicons`, state management package, `permission_handler`, `device_calendar`, navigation package, analytics/crash reporting SDKs, `supabase_flutter`, `connectivity_plus`, `flutter_secure_storage`, `flutter_animate`, `pretty_animated_text`, Firebase SDK for Remote Config (D2, NFR7, NFR9, NFR13.6).
3.  **Core Theme Setup (D1, D2):**
    * Configure `shadcn_ui` theme provider with the specified color palette (Primary Blue, Secondary Purple, Accent Peach/Terracotta, Neutrals, System States).
    * Set up typography using `shadcn_ui` theme settings (Inter font).
    * Define spacing scale based on `shadcn_ui`.
4.  **State Management Setup (NFR13.1):**
    * Implement the chosen state management solution across the project structure.
5.  **Navigation & Routing (F2.1):**
    * Set up the basic app router/navigator.
    * Implement the main layout shell (`Scaffold`) containing the Bottom Navigation Bar (`NavigationBar` styled minimally, using `hugeicons`). Define the 4 main sections: Circles, Events, Explore, Profile.
6.  **Project Structure & Linting (NFR13.2, NFR13.9):**
    * Organize directories based on the modular structure (e.g., `lib/features/auth`, `lib/core`, `lib/shared`).
    * Configure `analysis_options.yaml` with appropriate linting rules (e.g., `flutter_lints` or stricter).
7.  **Supabase Integration:**
    * Set up Supabase initialization in the app startup.
    * Configure authentication routes and session handling.
    * Create basic database service classes for core app entities (users, circles, events).
8.  **Network & Error Handling Foundation (NFR10):**
    * Implement connectivity monitoring using `connectivity_plus`.
    * Create base error handling utilities (error models, formatters, UI components).
    * Set up error boundaries for critical app sections to prevent full app crashes.
9.  **Internationalization Foundation (NFR14):**
    * Set up the `intl` package and basic structure for localized strings.
    * Create a base class for accessing localized text throughout the app.
10. **Firebase Remote Config Setup (NFR9):**
    * Initialize the Firebase Remote Config service.
    * Define default values for configurable parameters.

---

## Phase 1: Authentication & Onboarding

**Goal:** Implement user sign-up, login, initial profile setup, and necessary permission requests.

1.  **Onboarding Screens (F1.1, D3-Onboarding):**
    * Build swipeable intro screens (`PageView`) explaining value propositions. Use `shadcn_ui` components for layout and buttons.
2.  **Authentication Screens (F1.2, D3-Auth):**
    * Create Login, Sign Up, and Password Recovery screens using `shadcn_ui` `Input` and `Button` components.
    * Integrate with Supabase Auth for Email/Password, Phone (OTP), and Google Sign-in options. 
    * Handle loading and error states (NFR10, D4) with appropriate visual feedback.
3.  **Profile Setup (F1.3):**
    * Create screen for entering First Name, Last Name, and uploading/taking a Profile Picture (`shadcn_ui` `Avatar`).
    * Implement Supabase Storage integration for profile image uploads.
4.  **Permission Requests (F1.4, D2, D3-Onboarding, NFR12):**
    * Implement sequential permission request flows using `permission_handler`.
    * Use `shadcn_ui` `Dialog` or dedicated screens to clearly explain *why* each permission (Contacts, Calendar, Notifications) is needed. Provide clear "Grant" and "Skip/Deny" options (`shadcn_ui` `Button`).
    * Ensure graceful degradation if permissions are denied (NFR5).
    * Store permission states securely and make accessible in settings (F8.5).
5.  **Calendar Integration Prompt (F1.5, F8.3, D2, D3-Onboarding):**
    * Prompt user to connect device calendar(s) using `device_calendar` (after permission F1.4.2).
    * Allow selection of specific calendars. Use `shadcn_ui` `Checkbox` or `RadioGroup`.
    * Provide an option to skip/configure later in Settings.
6.  **Contact Info & Preferences (F1.6, F1.7):**
    * Create inputs (`shadcn_ui` `Input`) for Phone/Email *after* permissions/calendar setup.
    * Implement multi-select list (`shadcn_ui` `Checkbox` group or similar) for personal interests.
7.  **In-App Tutorial System (F1.8, D4):**
    * Create reusable tooltip and overlay components for guiding first-time users.
    * Implement a framework to track tutorial progress and display appropriate guidance.
    * Ensure all tooltips have clear dismiss options and respect user preferences.

---

## Phase 2: Core Navigation & Profile/Settings

**Goal:** Flesh out the main navigation sections and implement user profile viewing and settings management.

1.  **Bottom Navigation Implementation (F2.1):**
    * Connect the Bottom Navigation Bar items to their respective screen placeholders/modules. Ensure active state indication uses Primary Blue tint (D1).
    * Implement proper BuildContext handling in navigation (NFR13.7).
2.  **Profile Screen (F2.1, F8.1, D3-Profile):**
    * Build the user profile view: Display `Avatar`, Name.
    * Add navigation items (e.g., using styled `ListTile` or `shadcn_ui` `Button` ghost variant) to access different settings sections.
    * Implement real-time profile data synchronization with Supabase.
3.  **Settings Screen Structure (F8, D3-Settings):**
    * Create the main Settings screen (`ListView`).
    * Implement navigation to sub-sections for different settings categories.
4.  **Implement Settings Options (F8.1-F8.8, D3-Settings):**
    * **Edit Profile (F8.1):** Link to the profile setup flow (Phase 1).
    * **Manage Notifications (F8.2):** Use `shadcn_ui` `Switch` (Primary Blue active color) to toggle settings (requires F1.4.3 permission).
    * **Manage Calendar Integration (F8.3):** Allow linking/unlinking, selecting calendars (re-uses F1.5 logic).
    * **Manage Contact Syncing (F8.4):** Use `Switch` (requires F1.4.1 permission).
    * **Privacy Settings (F8.5):** Implement controls for LLM data usage, permission management, and data retention preferences. Include widgets to request permissions again if previously denied.
    * **Help/Support, Feedback/Bug Report (F8.6, F8.8):** Implement structured feedback form with optional screenshot attachment and submission to backend.
    * **Logout, Delete Account (F8.7):** Implement functionality with confirmation dialogs (`shadcn_ui` `AlertDialog`). Connect to Supabase Auth logout and account deletion endpoints.

---

## Phase 3: Social Circle Management & Offline Foundations

**Goal:** Implement the ability to create, view, and manage social circles and their members, plus basic offline capability.

1.  **Network State Monitoring (F9.3, NFR10):**
    * Implement app-wide network state indicator using `connectivity_plus`.
    * Create visual indicators for offline mode and sync status.
2.  **Offline Data Storage (F9.1, F9.2):**
    * Implement local storage solution for caching key app data.
    * Set up data synchronization mechanisms for offline-to-online transitions.
3.  **Circles List Screen (F2.1, D3-Home):**
    * Display a list of the user's social circles using `shadcn_ui` `Card`.
    * Add a "Create Circle" button (`shadcn_ui` `Button` icon variant or FAB, Primary Blue).
    * Handle empty state. Use `shadcn_ui` `Skeleton` for loading (D4).
    * Support offline viewing of cached circles data.
4.  **Create Circle Flow (F3.1):**
    * Implement screen/dialog (`shadcn_ui` `Dialog`/`Sheet`) to input Circle Name, optional description/photo.
    * Connect to Supabase database for circle creation.
    * Support offline creation with queued sync (F9.2).
5.  **Add Members Flow (F3.2):**
    * Implement member addition UI:
        * Integrate with Contacts (using granted permission F1.4.1/F8.4).
        * Search functionality (requires Supabase backend).
        * Generate invite link.
        * Display pending invites.
    * Use `shadcn_ui` `Input`, `ListView`, `Avatar`.
6.  **Circle Details Screen Shell (F3.3, D3-Circle Details):**
    * Build the main layout for viewing a single circle (`Scaffold`, `AppBar`).
    * Include sections/tabs for Dashboard, Members, Event History, Chat access.
7.  **Implement Detail Sections (F3.3.1 - F3.3.5, F3.4, F3.5, D3-Circle Details):**
    * **Member List (F3.3.2):** Display members using `ListView`, `Avatar`, `Text`.
    * **Member Management (F3.5):** Add options to remove members or leave the circle (with confirmation `AlertDialog`).
    * **Group Preferences (F3.4, F3.3.5):** Implement UI for admin to set shared interests (similar to F1.7) and for members to view them.
    * **Circle Event History (F3.3.3):** Placeholder `ListView` - will be populated in Phase 9.
    * **Group Analytics Dashboard (F3.3.1):** Placeholder section - will be implemented in Phase 9.
    * **Access to Circle Chat (F3.3.4):** Add a clear button/entry point (`shadcn_ui` `Button`, Primary Blue) - will link to Chat module in Phase 6.
8.  **Conflict Resolution (F9.4):**
    * Implement conflict detection and resolution strategy for simultaneous edits.
    * Create UI for resolving conflicts when they occur.

---

## Phase 4: Event Listing & Basic Details

**Goal:** Display upcoming and past events, and show the details of a confirmed event.

1.  **Events Screen (F2.1, D3-Home):**
    * Implement the "Events" tab structure (Upcoming/Past) using `shadcn_ui` `Tabs` (Primary Blue indicator).
    * Display lists of events using `shadcn_ui` `Card`. Handle empty states.
    * Support offline viewing of cached events.
2.  **Event Details Screen Structure (F5.1, D3-Event Details):**
    * Build the screen to show finalized event info.
    * Display Name, Date, Time, Location (potentially integrate `google_maps_flutter` for a preview).
    * Display Attendees list with RSVP status (`shadcn_ui` `Badge`, maybe Accent color for "Going").
    * Add placeholder button/link for Event-Specific Chat (F5.1) - links to Phase 6.
    * Add placeholder button for Bill Splitting (F6.1) - links to Phase 7.
3.  **Add to Calendar (F5.2):**
    * Implement functionality to add the event to the user's device calendar.
    * May require requesting write permission for the calendar if not bundled with read permission (F1.4.2). Use `device_calendar`.
4.  **Event Reminders (F5.4):**
    * Implement reminder settings for events with customizable timing options.
    * Connect to local notifications system (requires F1.4.3 permission).
    * Ensure reminders work even when app is not foregrounded.
5.  **Error Handling for Events (NFR10):**
    * Implement specific error states for common events-related issues.
    * Create UI components for graceful degradation during connectivity problems.

---

## Phase 5: Event Planning & Suggestions

**Goal:** Implement the workflow for suggesting, planning, and confirming events within a circle.

1.  **Initiate Event Suggestion (F4.1):**
    * Add entry point within a Circle Details screen to start planning an event.
2.  **Input Constraints UI (F4.2, D3-Event Planning):**
    * Build UI (`shadcn_ui` `Dialog` or `Sheet`) for inputs:
        * Time: Use `shadcn_ui` `DatePicker`. Integrate read-only calendar data (F1.5/F8.3) to show user availability.
        * Budget: Use `shadcn_ui` `Select` or `RadioGroup`.
        * Vibe/Type: Use `shadcn_ui` `Input` or tags.
3.  **Member Preference Gathering (F4.3):**
    * Implement UI elements (e.g., interactive prompts within the planning flow or linked from notifications) to collect availability/preferences from members.
    * Connect to Supabase for real-time preference updates.
4.  **LLM Recommendation Display (F4.4, D3-Event Planning, D1):**
    * Integrate with backend API to fetch LLM suggestions based on inputs (F4.2, F4.3, potentially chat context F4.4.1).
    * Display suggested options using `shadcn_ui` `Card`, subtly tinted with Secondary Purple. Show relevance/reasoning if provided by backend. Handle loading state (`CircularProgressIndicator` styled Purple - D4).
    * Implement clear consent mechanisms for using chat data (NFR11).
5.  **Voting System UI (F4.5, D3-Event Planning):**
    * Present recommendations with options for members to vote (`shadcn_ui` `RadioGroup` or `Checkbox` within cards).
    * Implement real-time vote updates using Supabase subscriptions.
6.  **Event Confirmation (F4.6):**
    * Implement logic for the organizer to finalize the event based on votes/decision.
    * On confirmation, create the event record and navigate/link to the Event Details screen (Phase 4).
    * Support offline event confirmation with sync queuing.

---

## Phase 6: Chat Implementation

**Goal:** Build the chat interface for both circles and specific events.

1.  **Core Chat UI Component (F5.3, D3-Chat Screens):**
    * Build a reusable chat screen widget: Message list (`ListView`), text input field (`shadcn_ui` `Input`), send button (`shadcn_ui` `Button` Primary Blue).
    * Style message bubbles (Neutral backgrounds, user's bubbles potentially tinted Primary Blue).
    * Implement proper BuildContext handling for chat screen (NFR13.7).
2.  **Circle Chat (F5.3.1):**
    * Integrate the chat UI component.
    * Connect to Supabase real-time subscriptions for live chat functionality.
    * Fetch/display persistent chat history for the specific circle.
    * Connect the entry point from Circle Details (F3.3.4).
    * Implement offline message queuing and status indicators.
3.  **Event-Specific Chat (F5.3.2):**
    * Integrate the chat UI component.
    * Fetch/display chat history specifically for the confirmed event attendees.
    * Connect the entry point from Event Details (F5.1).
    * Connect to Supabase real-time subscriptions.
    * Implement offline message queuing.
4.  **Chat Privacy Controls (NFR11):**
    * Implement UI elements to inform users about and control chat data usage for LLM recommendations.
    * Create clear visual indicators when chat data might be used for suggestions.

---

## Phase 7: Bill Splitting

**Goal:** Implement the functionality to split bills after an event.

1.  **Initiate Split Flow (F6.1):**
    * Add entry point (e.g., button) on the Event Details screen (Phase 4).
2.  **Enter Details UI (F6.2, D3-Bill Splitting):**
    * Create UI (`shadcn_ui` `Dialog` or `Sheet`) to enter Total Amount and Description (`shadcn_ui` `Input`).
3.  **Assign Shares UI (F6.3, D3-Bill Splitting):**
    * Display list of event attendees (`ListView`, `Avatar`, `Text`).
    * Default to equal split. Provide options to adjust amounts per person (`shadcn_ui` `Input`).
4.  **Track Payments UI (F6.4, D3-Bill Splitting):**
    * Display who owes whom based on the split.
    * Add a mechanism to "Mark as Paid" (`shadcn_ui` `Switch` or `Button`, maybe Accent color).
    * Connect to Supabase to persist split details and payment status.
    * Support offline payment tracking with synchronization.
5.  **Payment Reminders (F6.5):**
    * Integrate with notification system (requires F1.4.3 permission) for payment reminders.
    * Allow customizing reminder frequency and message.

---

## Phase 8: Explore & Search

**Goal:** Implement the discovery features for event ideas and manual searching.

1.  **Explore Screen Structure (F2.1, D3-Home):**
    * Build the basic layout for the "Explore/Search" tab.
2.  **LLM Idea Display (F7.1):**
    * Integrate with backend to fetch LLM-generated event ideas based on user/group preferences.
    * Display ideas using `shadcn_ui` `Card` grid or list. Potentially highlight with Purple tint (D1).
    * Use `pretty_animated_text` selectively for emphasis on key recommendations.
3.  **Manual Search UI (F7.2, D3-Home):**
    * Add a search bar (`shadcn_ui` `Input` search style).
    * Implement filter options (location, type, budget, date) potentially using `shadcn_ui` `Sheet` or `Popover` containing `Select`, `DatePicker`, etc.
    * Connect to Supabase for search queries.
4.  **Search Results Display:**
    * Display search results (fetched from backend) using `shadcn_ui` `Card` list/grid.
    * Implement graceful error states and loading indicators.
5.  **Offline Search Support:**
    * Enable basic search functionality against cached data when offline.
    * Clearly indicate limited search capabilities in offline mode.

---

## Phase 9: Analytics & Refinements

**Goal:** Implement the group analytics dashboard, populate event history, refine UI/UX, and perform final checks.

1.  **Group Analytics Dashboard (F3.3.1, D2, D3-Circle Details):**
    * Integrate the chosen charting library into the Circle Details screen.
    * Connect to Supabase to fetch analytics data.
    * Display key stats (total events, frequency, common types, budget) using appropriate charts (bar, line, pie).
    * Theme the charts to match the app's palette (Primary Blue, Accent highlights - D1). Use `shadcn_ui` `Skeleton` for loading states (D4).
    * Use `flutter_animate` for subtle chart animations.
2.  **Populate Circle Event History (F3.3.3):**
    * Fetch and display the list of past events specific to the circle on the Circle Details screen, using the `ListView` placeholder from Phase 3.
3.  **UI/UX Refinements (D4):**
    * Implement subtle screen transitions and component animations (leveraging `shadcn_ui`, `flutter_animate` and Flutter built-ins).
    * Ensure consistent loading states (`Skeleton`, styled `CircularProgressIndicator`).
    * Implement user feedback mechanisms (`shadcn_ui` `Toast`/`Sonner` equivalent).
    * Review input validation states.
    * Ensure all tutorial elements (F1.8) work correctly across the app.
4.  **Remote Configuration Integration (NFR9):**
    * Connect Firebase Remote Config to relevant app parameters.
    * Test dynamic behavior changes via remote updates.
5.  **Frontend Analytics & Monitoring (NFR7):**
    * Integrate basic event tracking (screen views, key actions) using Firebase Analytics or similar.
    * Ensure crash reporting (Firebase Crashlytics/Sentry) is active.
    * Implement internal performance monitoring for analytics calculations.
6.  **Comprehensive Error Handling (NFR10):**
    * Review all error paths throughout the application.
    * Ensure consistent error presentation using standardized components.
    * Test error boundaries to prevent app crashes.
7.  **Internationalization Preparation (NFR14):**
    * Verify all user-facing strings are properly externalized.
    * Set up the scaffolding for future language additions.
8.  **Testing & Quality Assurance (NFR13.5, NFR6, NFR2):**
    * Write unit tests for business logic and widget tests for key UI components.
    * Perform manual testing across different device sizes/orientations.
    * Conduct accessibility review (screen readers, font scaling, contrast ratios).
    * Test offline functionality extensively.
    * Profile the app for performance bottlenecks and optimize (widget builds, async operations). Ensure smooth 60fps+ animations (NFR2).
    * Conduct security audit of data storage and transmission (NFR4).

---

This plan provides a structured approach. Each phase builds upon the previous ones, allowing for incremental development and testing. Remember to adhere to Flutter best practices (NFR13) throughout the development process.
