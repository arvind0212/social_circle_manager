# **Social Circle Manager \- Product & Design Requirements (Flutter)**

## **1\. Introduction & Vision**

* **Product:** Social Circle Manager (SCM)  
* **Vision:** To simplify organizing social events by intelligently connecting friends, understanding their preferences, and streamlining the planning process from idea to execution using a modern, minimalist interface with insightful group analytics.  
* **Goal:** Become the go-to app for small groups looking to spend quality time together effortlessly, powered by smart recommendations, seamless coordination, group insights, and a delightful user experience.
* **Backend Technology:** Supabase for authentication, database, real-time subscriptions, and storage.

## **2\. Target Audience**

* Socially active individuals (Millennials, Gen Z primarily) belonging to multiple friend groups.  
* Users who find group planning (scheduling, activity decisions, expense management) cumbersome.  
* Users interested in understanding their social group's activity patterns.  
* Tech-savvy users appreciating clean, modern interfaces (shadcn/ui aesthetic) and efficient workflows.

## **3\. Key Features & Functionality (F)**

* **F1: Onboarding & Profile Management**  
  * **F1.1:** Swipeable intro screens explaining core value propositions (effortless planning, smart recommendations, circle management, privacy focus).  
  * **F1.2:** User Authentication: Email/Password, Phone (OTP), Google Sign-in via Supabase Auth. Password recovery.  
  * **F1.3:** Profile Setup: First Name, Last Name, Profile Picture (upload/camera).  
  * **F1.4:** **Permission Requests:** Sequentially request necessary permissions with clear explanations for *why* each is needed:  
    * **F1.4.1:** Contacts Access (for adding circle members easily).  
    * **F1.4.2:** Calendar Access (Read-only, for checking availability during event planning).  
    * **F1.4.3:** Notifications (for event reminders, chat messages, invites).  
    * *Note:* App should function gracefully if permissions are denied, potentially limiting related features.  
  * **F1.5:** **Calendar Integration:**  
    * **F1.5.1:** Prompt user to connect their device calendar(s).  
    * **F1.5.2:** Allow selection of specific calendars (e.g., Personal, Work) to use for availability checks. Clearly state this is read-only access.  
    * **F1.5.3:** Option to skip and configure later via Settings (F8.3).  
  * **F1.6:** Contact Information (Editable): Phone Number, Email. (Address optional/removed). Entered *after* permissions/calendar setup.  
  * **F1.7:** Personal Interest Preferences: Multi-select list (Movies, Books, Running, Fitness, Cafes, Pubs, Wine, Clubbing, Hiking, Games, Music, Art, etc. \- expandable).  
  * **F1.8:** Simple In-App Tutorial/Hints: Subtle guidance (tooltips, overlays) for key first-time actions after onboarding completes.  
* **F2: Home Screen / Core Navigation**  
  * **F2.1:** Bottom Navigation Bar (4 sections):  
    * Social Circles  
    * Events (Upcoming/Past \- All Circles)  
    * Explore/Search  
    * Profile  
* **F3: Social Circle Management**  
  * **F3.1:** Create Circle (Name, optional description/photo).  
  * **F3.2:** Add Members: Contact integration (using granted permission F1.4.1), search, invite link, pending invites.  
  * **F3.3:** View Circle Details (**Dashboard View**):  
    * **F3.3.1:** **Group Analytics Dashboard:** Overview section displaying key stats like total events organized, frequency of meetups, common event types, average budget range used, etc. (visualized simply).  
    * **F3.3.2:** Member List: View members of the circle.  
    * **F3.3.3:** Circle Event History: List of past events specifically for this circle.  
    * **F3.3.4:** Access to Circle Chat: Entry point to the main chat for this circle.  
    * **F3.3.5:** Group Preferences Summary: View the set group interests.  
  * **F3.4:** Set Group Preferences: Circle admin sets shared interests influencing recommendations and analytics.  
  * **F3.5:** Member Management: Remove members, leave circle.  
* **F4: Event Planning & Suggestion**  
  * **F4.1:** Initiate Event Suggestion (within a specific circle).  
  * **F4.2:** Input Constraints:  
    * Time: Date ranges/specific dates. Use integrated calendars (from F1.5 / F8.3) to show user's availability. *Advanced:* Integrate members' calendars (requires their permission) for overlap.  
    * Budget: Approx. per person (e.g., $, $$, $$$ or range).  
    * Vibe/Type (Optional): Free text/tags.  
  * **F4.3:** Member Preference Gathering: Notify members, collect availability/preferences via interactive prompts or messages.  
  * **F4.4:** LLM-Powered Event Recommendation: Backend processes constraints, availability (from calendars), individual/group preferences. Suggests concrete options (venue, time, cost, relevance).  
    * **F4.4.1:** **LLM Chat Input:** Relevant messages from the circle or event chat (e.g., explicit preferences, logistical discussions) can optionally be used as additional context for the LLM (requires careful filtering for relevance and privacy).  
  * **F4.5:** Voting System: Present recommendations, members vote.  
  * **F4.6:** Event Confirmation: Finalize based on votes/organizer decision.  
* **F5: Event Management & Execution**  
  * **F5.1:** Event Details Screen: Finalized info (name, date, time, location/map), attendees (RSVP status), link to **Event-Specific Chat**.  
  * **F5.2:** Calendar Integration (Write): Option to add event to device calendar (write permission, may require separate permission request if not bundled with read).  
  * **F5.3:** In-App Chat:  
    * **F5.3.1:** **Circle Chat:** Persistent chat thread for each Social Circle.  
    * **F5.3.2:** **Event Chat:** Dedicated chat thread specifically for a confirmed event, accessible to attendees (linked from Event Details screen).  
  * **F5.4:** Event Reminders: Push notifications (using granted permission F1.4.3) for upcoming events, with customizable timing options (e.g., 1 day before, 1 hour before).  
* **F6: Bill Splitting**  
  * **F6.1:** Initiate Split (post-event from details screen).  
  * **F6.2:** Enter Total Amount & Description.  
  * **F6.3:** Assign Shares: Default equal split, option to adjust amounts/mark paid.  
  * **F6.4:** Track Payments: Show who owes whom. Manual "Mark as Paid".  
  * **F6.5:** Payment Reminders (Optional): Notifications for outstanding amounts.  
* **F7: Search/Explore**  
  * **F7.1:** View LLM-generated event ideas based on preferences.  
  * **F7.2:** Manual Search: Filter events/venues (location, type, budget, date).  
* **F8: Settings**  
  * **F8.1:** Edit Profile.  
  * **F8.2:** Manage Notifications (toggle specific types, requires F1.4.3 permission).  
  * **F8.3:** Manage Calendar Integration (link/unlink accounts, select active calendars for availability checks \- relates to F1.5).  
  * **F8.4:** Manage Contact Syncing (toggle, requires F1.4.1 permission).  
  * **F8.5:** Privacy Settings (controls for LLM chat analysis, manage permissions, data retention preferences).  
  * **F8.6:** Help/Support Link.  
  * **F8.7:** Logout, Delete Account.  
  * **F8.8:** Send Feedback/Report Bug link.
* **F9: Offline Functionality & Data Synchronization**
  * **F9.1:** Basic offline mode allowing users to view previously loaded data.
  * **F9.2:** Queue actions performed offline for sync when connection is restored.
  * **F9.3:** Clear visual indicators of network/sync status.
  * **F9.4:** Conflict resolution strategy for simultaneous edits.

## **4\. Non-Functional Requirements (NFR)**

* **NFR1: Platform:** iOS, Android (via Flutter).  
* **NFR2: Performance:** Smooth (60fps+), fast load times, responsive UI, efficient backend communication, efficient analytics calculation. Optimize widget builds and minimize unnecessary rendering.  
* **NFR3: Scalability:** Backend handles growth (users, circles, events, chats, analytics data). Efficient LLM integration. Frontend architecture should support feature growth.  
* **NFR4: Security:** Secure auth via Supabase, data encryption (rest/transit), secure PII handling (contacts/calendar/chats), privacy compliance (GDPR, etc.), secure chat data handling. Explicit permission handling. Secure local storage for sensitive data.  
* **NFR5: Usability:** Intuitive, clear hierarchy, minimal cognitive load. Minimalist aesthetic. Clear presentation of analytics. Graceful handling of denied permissions.  
* **NFR6: Accessibility:** Screen reader support, dynamic font sizes, sufficient color contrast (including charts/graphs). Adherence to WCAG AA standards.  
* **NFR7: Analytics & Monitoring:** Basic user engagement analytics (Firebase Analytics/Mixpanel), crash reporting (Firebase Crashlytics/Sentry). *Internal* monitoring of group analytics calculation performance.  
* **NFR8: User Feedback Mechanism:** In-app channel for feedback/bug reports with structured form and optional screenshot attachment.  
* **NFR9: Remote Configuration:** Use Firebase Remote Config for tweaking parameters/feature flags/LLM behavior without app updates.  
* **NFR10: Robust Error Handling:** User-friendly error messages, graceful handling of network/backend issues, clear error reporting. Error boundaries to prevent app crashes. Specific error states for common scenarios (network unavailable, unauthorized, etc.)  
* **NFR11: Data Privacy (Chat):** Clear user consent and controls regarding the use of chat data for LLM recommendations (F4.4.1). Anonymization or strict relevance filtering is crucial.  
* **NFR12: Permission Management:** Clear explanations for permission requests, ability to manage permissions later in settings, app functions reasonably without non-critical permissions.  
* **NFR13: Flutter Development Best Practices:** Adherence to established Flutter best practices is required for maintainability, performance, and code quality. This includes:  
  * **NFR13.1: State Management:** Utilize a clear, scalable state management solution appropriate for the app's complexity (e.g., Provider, Riverpod, BLoC/Cubit, potentially leveraging shadcn\_ui state patterns if applicable). Avoid mixing state management approaches unnecessarily.  
  * **NFR13.2: Code Organization:** Implement a logical and consistent project structure (e.g., feature-first or layer-first).  
  * **NFR13.3: Widget Composition:** Build the UI using small, reusable, and well-defined widgets. Favor composition over inheritance. Use const constructors where possible.  
  * **NFR13.4: Asynchronous Operations:** Handle asynchronous code correctly using async/await and appropriate widgets like FutureBuilder or StreamBuilder. Manage disposal of resources (e.g., StreamSubscriptions).  
  * **NFR13.5: Testing:** Implement a reasonable testing strategy including unit tests for logic, widget tests for UI components, and potentially integration tests for key user flows.  
  * **NFR13.6: Dependency Management:** Keep dependencies up-to-date and manage them effectively via pubspec.yaml. Remove unused dependencies.  
  * **NFR13.7: BuildContext Awareness:** Use BuildContext correctly, understanding widget tree hierarchy and avoiding improper context usage (e.g., across async gaps without checks).  
  * **NFR13.8: Platform Considerations:** While Flutter minimizes platform differences, be mindful of any necessary platform-specific adjustments or UI conventions where appropriate (e.g., back navigation behavior).  
  * **NFR13.9: Code Style & Linting:** Adhere to Dart and Flutter style guides, enforced using analysis options and linting rules (e.g., flutter\_lints or stricter packages).
* **NFR14: Internationalization & Localization:** Structure the app to support multiple languages in the future, using Flutter's intl package and following best practices for string externalization.

## **5\. UI/UX Design Requirements (D)**

* **D1: Overall Aesthetic: Modern Minimalism (shadcn/ui Inspired)**  
  * **Color Palette:** Implement via shadcn\_ui theme provider. Prioritize clarity, trust, and a touch of warmth without overstimulation.  
    * **Primary (Trust & Organization):** A reliable, calming **Blue** (e.g., \#4A90E2 \- friendly UI blue, or \#0F4C81 \- classic blue). Use for core navigation (bottom bar background/active icon tint), headers, primary buttons, key interactive elements.  
    * **Secondary (AI & Intelligence):** A distinct **Purple** (e.g., \#7B1FA2 or \#9C27B0). Use *specifically* for elements related to LLM suggestions (e.g., suggestion cards background tint, AI-related icons, loading indicators for recommendations). Helps visually distinguish AI features.  
    * **Accent (Warmth & Action):** A **Soft Peach** or **Terracotta** (e.g., \#FFDAB9 or \#E07A5F). Use sparingly for positive call-to-action buttons (e.g., "Confirm Event", "Add Expense"), highlights on dashboard widgets, or subtle tags/badges. Provides warmth and draws attention to key actions.  
    * **Neutrals (Clarity & Structure):**  
      * Background: **White** (\#FFFFFF) or very **Light Gray** (\#F5F5F5) for the main canvas to maximize readability and provide a clean base.  
      * Text: **Dark Gray/Charcoal** (\#333333 or \#121212) for optimal readability.  
      * Borders/Dividers: **Light to Medium Gray** (\#E0E0E0 or \#BDBDBD) for subtle separation, consistent with shadcn\_ui's default approach.  
    * **System States:**
      * **Success:** Green (\#4CAF50) for confirmations and completed actions.
      * **Warning:** Amber (\#FFC107) for cautions and important notices.
      * **Error:** Red (\#F44336) for critical errors and failures.
      * **Info:** Light Blue (\#2196F3) for general information and tips.
    * **Accessibility:** Ensure high contrast ratios between text/icons and their backgrounds across all color combinations, adhering to WCAG AA standards at minimum. Test the palette thoroughly.  
  * **Typography:** Clean, readable sans-serif font (e.g., Inter, or package default). Clear typographic hierarchy via shadcn\_ui theme settings.  
  * **Iconography:** **Use hugeicons package.** Consistent, minimalist, line-art style icons throughout the app. Apply Primary or Accent colors to icons where appropriate. Use Purple tint for AI-specific icons.  
  * **Spacing & Layout:** Generous whitespace. Grid-based layouts. Adhere to shadcn\_ui's spacing scale via theming. Focus on balance, alignment, and uncluttered presentation.  
  * **Imagery:** Minimal. Profile/circle avatars (shadcn\_ui's Avatar), map views. No decorative stock photos.  
* **D2: Component Philosophy & Library Usage**  
  * **Primary UI Library: shadcn\_ui Flutter package.** Build the UI primarily by composing and theming components from this library (Button, Input, Card, Dialog, Sheet, Avatar, Tabs, Select, Checkbox, RadioGroup, etc.). Apply the defined color palette via its theme provider.  
  * **Charting Library:** Select a Flutter charting library compatible with the minimalist aesthetic (e.g., fl\_chart, graphic, or potentially simple custom SVG charts) for the analytics dashboard (F3.3.1). Ensure it's themeable to match the app's palette (e.g., using Primary Blue for bars/lines, Accent for highlights).  
  * **Permission Handling:** Use a dedicated Flutter package (e.g., permission\_handler) to manage permission requests and status checking.  
  * **Calendar Integration:** Use relevant Flutter packages (e.g., device\_calendar) to read calendar data after permission is granted.  
  * **Customization:** Heavily utilize shadcn\_ui's theme capabilities. Theme the charting library to match. Build custom widgets only when necessary.  
  * **Animations:** Use subtle, purposeful animations. Leverage built-in Flutter transitions and shadcn\_ui component animations. Use flutter\_animate for custom subtle effects (e.g., animating chart entries).
  * **Supabase SDK:** Use the official Supabase Flutter SDK for authentication, database operations, and real-time functionality.
  * **Animation Text:** Use pretty\_animated\_text very selectively for emphasis in key moments.
  * **Network State:** Use connectivity\_plus to monitor and respond to network state changes.
  * **Secure Storage:** Use flutter\_secure\_storage for storing sensitive information.
* **D3: Key Screen Designs (Conceptual Component Mapping)**  
  * **General:** Use Scaffold, AppBar, Column, Row, ListView, Text as base layout elements. Apply Neutral backgrounds and Dark Gray text.  
  * **Onboarding:** PageView for intro slides. Dedicated screens/dialogs (shadcn\_ui Dialog?) for permission requests (F1.4) and calendar selection (F1.5), explaining the need clearly. Use shadcn\_ui Button (Primary Blue for "Grant", Neutral/Subtle for "Skip/Deny") for actions.  
  * **Auth:** shadcn\_ui Input, shadcn\_ui Button (Primary Blue for main action, secondary/link variants for others).  
  * **Home (Bottom Nav):** NavigationBar (styled minimally, potentially Primary Blue background or icon tint), hugeicons (tinted appropriately).  
    * *Circles List:* shadcn\_ui Card (Neutral background). shadcn\_ui Button (icon variant, Primary Blue) or FAB (Primary Blue) for add.  
    * *Events List:* shadcn\_ui Tabs (Primary Blue indicator). shadcn\_ui Card (Neutral).  
    * *Explore/Search:* shadcn\_ui Input (search style). shadcn\_ui Card grid/list. Filters in shadcn\_ui Sheet or Popover. AI suggestions potentially highlighted with Purple tint.  
    * *Profile:* shadcn\_ui Avatar. Navigation items using styled shadcn\_ui Button (ghost) or ListTile.  
  * **Circle Details (Dashboard View):** Scaffold with AppBar (Primary Blue background?).  
    * *Dashboard Section (F3.3.1):* Charting components themed with Primary Blue, potentially Accent highlights within shadcn\_ui Cards.  
    * *Members List (F3.3.2):* ListView with Row, Avatar, Text.  
    * *Events History (F3.3.3):* ListView of shadcn\_ui Cards.  
    * *Chat Access (F3.3.4):* Clear Button (Primary Blue).  
  * **Event Planning:** shadcn\_ui Dialog or Sheet. shadcn\_ui DatePicker. Input, Select/RadioGroup, Checkbox. Voting via RadioGroup/Checkbox in Cards. LLM Recommendation cards subtly tinted Purple.  
  * **Event Details:** google\_maps\_flutter preview. shadcn\_ui Badge (RSVP \- perhaps Accent color for "Going"?). shadcn\_ui Button (actions \- Primary Blue, maybe Accent for "Add Expense"?).  
  * **Chat Screens (Circle & Event):** Standard chat UI styled with Neutrals, Primary Blue for user's bubbles/send button.  
  * **Bill Splitting:** shadcn\_ui Dialog/Sheet. Input. List with Avatar, Text, Input/Switch. shadcn\_ui Button (Primary Blue for confirm, maybe Accent for "Mark as Paid"?).  
  * **Settings:** ListView. shadcn\_ui Switch (Primary Blue when active). shadcn\_ui Button (ghost/link). shadcn\_ui AlertDialog (confirmations).
  * **Network Status:** Subtle status indicator (e.g., thin bar at top of screen or Toast) for offline mode or sync status.
  * **Error States:** Standardized error displays with appropriate iconography and actions. Use Error color for critical issues.
* **D4: Interactions & Micro-animations**  
  * Smooth, subtle screen transitions (fades, quick slides).  
  * Use shadcn\_ui component animations.  
  * Animate chart entries/updates subtly.  
  * **pretty\_animated\_text:** Use *very selectively* for emphasis (e.g., success confirmations, welcome messages). Avoid in dashboards/data displays.  
  * **Loading States:** shadcn\_ui Skeleton for placeholder loading (especially dashboard stats); styled CircularProgressIndicator (Primary Blue or Purple for AI loading).  
  * **Feedback:** shadcn\_ui Toast or Sonner equivalent for non-intrusive messages. Clear input validation states.
  * **Tutorials:** Subtle overlays and tooltips for first-time user actions, with clear dismiss options.

## **6\. Future Considerations (V2+)**

* Advanced search filters (proximity, amenities).  
* Direct payment integration (Stripe, etc.).  
* Public events feed/discovery.  
* Advanced Group Analytics: Deeper insights, comparative analytics, customizable dashboards.  
* Web version.  
* Exportable analytics/event history.  
* More granular calendar permissions/integrations (e.g., specific event types only).  
* Dark Mode theme option using the defined palette principles.
* Multiple language support leveraging the internationalization foundation.