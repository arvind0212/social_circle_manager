# Supabase Integration for Social Circle Manager

This document outlines the progress made in integrating Supabase as the backend for the Social Circle Manager Flutter application and lists the remaining tasks to complete the integration.

## Progress So Far:

1.  **Supabase Project Setup:**
    *   A new Supabase project named "Circle" (ID: `qerogpoernbdhruodqpz`) was created under the "Arvind Personal" organization (`mwgiepqgybsgcbjcedjt`).
    *   Free tier confirmed ($0/month).

2.  **Schema Definition & Table Creation:**
    *   Based on existing Flutter models (`Circle`, `Event`, `CircleMember`, `Interest`, etc.), the following SQL tables were defined and created:
        *   `user_profiles`: Stores public user data, linked to `auth.users` via a trigger and a function (`public.handle_new_user()`).
            *   Columns: `id (uuid, pk)`, `updated_at (timestamptz)`, `email (text, unique)`, `full_name (text)`, `avatar_url (text)`.
            *   RLS: Enabled. Policy updated to allow authenticated users to select all profiles (was initially restricted to own profile). Users can update their own profile. Insert/delete handled by trigger.
        *   `circles`: Stores information about social circles.
            *   Added `preferred_days TEXT[]`, `preferred_times TEXT[]` columns.
            *   Ensured `common_activities` is `TEXT[]`.
            *   Added `hex_color TEXT` for circle-specific coloring.
            *   RLS: Enabled. Users can select all circles, insert new ones, update/delete circles they administer.
        *   `circle_members`: Junction table for users and circles.
            *   RLS: Enabled. Policies updated significantly to resolve "infinite recursion" errors and correctly implement visibility.
        *   `events`: Stores event details.
            *   Columns include `id, circle_id, created_by_user_id, title, description, start_time, end_time, location`.
            *   RLS: Enabled. Policies refined to allow users to see events from their circles or events they are attending, using a `SECURITY DEFINER` helper function (`public.is_user_attending_event`) to prevent RLS recursion.
        *   `event_attendees`: Junction table for users and events, storing RSVP status.
            *   Columns include `event_id, user_id, rsvp_status (enum: 'going', 'not_going', 'maybe'), status (text)`.
            *   RLS: Enabled. `INSERT` and `UPDATE` policies for authenticated users (`auth.uid() = user_id`) were simplified and corrected to prevent RLS recursion. `SELECT` policies allow viewing based on circle membership.
        *   `interests`, `circle_interests`: Initial setup with RLS policies as previously defined.
    *   **Triggers:**
        *   `on_auth_user_created` calls `public.handle_new_user()` for `user_profiles`.
        *   `handle_updated_at` trigger on relevant tables (including `event_attendees`).
        *   `on_circle_created_add_admin_member` calls `public.handle_new_circle_admin_membership()`.
    *   **SQL Functions:**
        *   `public.handle_new_user()`: For populating `user_profiles`.
        *   `public.is_active_member_of_circle(uuid, uuid)`: For `circle_members` RLS.
        *   `public.get_circles_for_user_with_details()`: For fetching user's circles with member count.
        *   `public.handle_new_circle_admin_membership()`: For circle creator admin role.
        *   `public.delete_current_user()`: For user account deletion.
        *   `public.get_events_for_user(uuid)`: `SECURITY DEFINER` RPC to fetch events for a user, including circle details, attendee count, and user's RSVP status. Casts `rsvp_status_enum` to `TEXT` for compatibility.
        *   `public.is_user_attending_event(uuid, uuid)`: `SECURITY DEFINER` function to check event attendance, used in `events` RLS policy to prevent recursion.

3.  **Mock Data Population:**
    *   Four users (Alice, Bob, Charlie, Diana) created.
    *   SQL script (`populate_mock_data.sql`) executed for initial data.
    *   Avatar URLs updated to `picsum.photos`.
    *   Mock data for events and event_attendees assumed to be present for testing event screen integration.

4.  **Flutter App Integration (Initial Setup & Models):**
    *   `supabase_flutter` package integrated.
    *   `main.dart` configured; Supabase client initialized.
    *   Dart models (`Circle`, `Event`, `CircleMember`, etc.) refactored. `Event` model updated with `fromJson`, hex color parsing, and `eventCreatorId`.

5.  **Flutter App Integration (Authentication & Data Fetching - Significantly Advanced):**
    *   Static mock data removed for circles and user profiles.
    *   `LoginScreen` uses Supabase auth.
    *   **`CircleService`:** Implemented `getCircles()`, `getCircleById()`, `createCircle()`.
    *   **`CirclesScreen` & `CreateCircleDialog`:** Integrated with `CircleService`.
    *   **`CircleDetailScreen`:** Integrated to show circle details and members.
    *   **`ProfileScreen` & `EditProfileScreen`:** Integrated for viewing/editing user profiles and avatar management via Supabase Storage (`user_avatars` bucket).

6.  **Flutter App Integration (Events - View & RSVP - NEW):**
    *   **`EventService`:** Created with `getEvents()` method calling `public.get_events_for_user` RPC and `updateRsvpStatus()` method to `upsert` data into `event_attendees`.
    *   **`Event` Model:** `fromJson` updated to parse data from `get_events_for_user` RPC, including `circle_name`, `circle_hex_color`, `attendee_count`, `user_rsvp_status`.
    *   **`EventsScreen`:** 
        *   Integrated with `EventService` to fetch and display upcoming and past events for the logged-in user.
        *   Removed mock event data.
        *   Handles loading and error states.
        *   Refreshes event list when an RSVP is updated in an `EventCard` via a callback.
    *   **`EventCard`:**
        *   Displays event details fetched from Supabase.
        *   Implements RSVP functionality (Going, Not Going, Maybe).
        *   Calls `EventService.updateRsvpStatus()` to persist RSVP choice to Supabase.
        *   UI updates locally and triggers a refresh in `EventsScreen`.
    *   **Provider Setup:** `EventService` (dependent on `SupabaseClient`) added to `MultiProvider` in `main.dart` for app-wide access.
    *   **RLS & Debugging (Events & Attendees):** Successfully diagnosed and resolved complex RLS "infinite recursion" errors related to `event_attendees` updates. This involved:
        *   Simplifying `INSERT` and `UPDATE` RLS policies on `event_attendees` for the `authenticated` role.
        *   Modifying the `SELECT` RLS policy on the `events` table to use a `SECURITY DEFINER` function (`public.is_user_attending_event`) to break the recursive RLS evaluation chain.
        *   Ensuring the `get_events_for_user` RPC correctly casts enum types to text for Flutter compatibility.
        *   Resolving `NOT NULL` constraint violations during `upsert` to `event_attendees`.

## Next Steps to Complete Integration:

1.  **Data Verification & Mock Data Finalization:**
    *   Ensure Diana is added as a 'joined' member to "Bookworm Club" so she sees two circles as intended by original mock data plan.
    *   Review all mock data for consistency and completeness, especially for events and various RSVP scenarios to test the `EventsScreen` thoroughly.

2.  **Image Handling & Display (Robust Solution):**
    *   **Supabase Storage:**
        *   Create `circle_images` bucket with appropriate access policies.
        *   Update mock data to use actual Supabase Storage URLs for `image_url` (circles).
    *   Ensure `Image.network` error builders in `CircleCard` and `CircleDetailScreen` (for circle header image) are robust or show appropriate placeholders. *(Partially addressed for user avatars, needs to be extended to circle images)*

3.  **Complete CRUD Operations for Circles:**
    *   **Create Circle:** UI and `CircleService.createCircle()`. *(Largely complete)*
    *   **Update Circle:** UI and `CircleService.updateCircle()`.
    *   **Delete Circle:** Admin functionality and `CircleService.deleteCircle()`.
    *   **Manage Members:** Join/Request to Join, Approve/Reject, Leave/Remove functionality in UI and service.
    *   **Manage Interests:** Add/remove interests for a circle.

4.  **Complete CRUD Operations for Events (Beyond RSVP):**
    *   **Create Event:** UI and `EventService.createEvent()`. This will involve the `EventMatchingScreen` flow.
    *   **Update/Delete Event.** (Needs UI and service methods)

5.  **User Profile Management (Enhancements):**
    *   Consider adding other profile fields (e.g., bio, phone - if schema is extended).

6.  **Real-time Functionality (Supabase Realtime):**
    *   Subscribe to changes for live updates in the UI (e.g., new events, RSVP changes by other users, circle updates).

7.  **Error Handling and User Feedback (Refinement):**
    *   Systematically review and refine error handling and user feedback across all integrated features.

8.  **Offline Support (Optional but Recommended).**

9.  **Refine RLS Policies (General Review):**
    *   Thoroughly test all RLS policies for tables and operations not yet fully covered by CRUD operations (e.g., interests, event creation/deletion RLS).

10. **Testing:**
    *   Write unit, widget, and integration tests for all Supabase-integrated features.

11. **Code Refinement & Optimization:**
    *   Clean up debug prints.
    *   Optimize queries and model parsing further if needed.

This list provides a roadmap for completing the Supabase integration. Prioritization will depend on the application's core feature requirements. 