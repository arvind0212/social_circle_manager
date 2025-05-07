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
            *   Ensured `common_activities` is `TEXT[]` (or type adjusted if previously different).
            *   RLS: Enabled. Users can select all circles, insert new ones, update/delete circles they administer.
        *   `circle_members`: Junction table for users and circles.
            *   RLS: Enabled. Policies updated significantly to resolve "infinite recursion" errors and correctly implement visibility:
                *   Users can see their own membership records.
                *   Members can see other members of circles they have `joined` (using a `SECURITY DEFINER` helper function `public.is_active_member_of_circle(uuid, uuid)`).
                *   Admins can see all members of their circles.
                *   Other policies for insert/update/delete remain.
        *   `interests`, `circle_interests`, `events`, `event_attendees`: Initial setup with RLS policies as previously defined.
    *   **Triggers:**
        *   `on_auth_user_created` calls `public.handle_new_user()` for `user_profiles`.
        *   `handle_updated_at` trigger on relevant tables.
        *   `on_circle_created_add_admin_member` calls `public.handle_new_circle_admin_membership()` after a new circle is inserted to automatically add the creator as an admin member in `circle_members`.
    *   **SQL Functions:**
        *   `public.handle_new_user()`: For populating `user_profiles` on new auth user.
        *   `public.is_active_member_of_circle(uuid, uuid)`: `SECURITY DEFINER` function to check if a user is a joined member of a circle, used in `circle_members` RLS to prevent recursion.
        *   `public.get_circles_for_user_with_details()`: `SECURITY DEFINER` RPC function to fetch all circles a user is a joined member of, including an accurate `member_count` for each.
        *   `public.handle_new_circle_admin_membership()`: For automatically adding the circle creator as an admin member.

3.  **Mock Data Population:**
    *   Four users (Alice, Bob, Charlie, Diana) created.
    *   SQL script (`populate_mock_data.sql`) executed for initial data.
    *   Avatar URLs for mock users were updated from PlaceKitten to `picsum.photos` to resolve image loading issues.
    *   Verified and corrected Diana's membership for "Bookworm Club" to ensure she is a 'joined' member (pending actual addition of this record). *Correction: This step is pending; Diana is currently only a member of "Weekend Trailblazers".*

4.  **Flutter App Integration (Initial Setup & Models):**
    *   `supabase_flutter` package integrated.
    *   `main.dart` configured; Supabase client initialized.
    *   Dart models (`Circle`, `Event`, `CircleMember`, `CircleCreationData`, etc.) refactored for Supabase schema compatibility, including `fromJson`/`toJson` and `toMap` methods.

5.  **Flutter App Integration (Authentication & Data Fetching - Significantly Advanced):**
    *   Static mock data removed.
    *   `LoginScreen`: Uses `Supabase.instance.client.auth.signInWithPassword()` for authentication.
    *   **`CircleService`:**
        *   `getCircles()`: Rewritten to call the `public.get_circles_for_user_with_details()` RPC function. This ensures it fetches *only* circles the logged-in user is a member of and provides an accurate `member_count`.
        *   `getCircleById()`: Fetches detailed data for a single circle. RLS policies now correctly allow fetching of all members and their profiles for circles the user has access to.
        *   `createCircle()`: Implemented to insert new circle data into the `circles` table. Admin membership is now handled by a server-side trigger.
    *   **`CirclesScreen` & `CreateCircleDialog`:**
        *   `CirclesScreen` now correctly lists *only* circles the logged-in user is a member of, including newly created ones.
        *   Displays accurate member counts on `CircleCard`s for these circles.
        *   Description on `CircleCard` now allows for two lines.
        *   `CreateCircleDialog` successfully collects data using `CircleCreationProvider` and calls `CircleService.createCircle()`.
        *   Toast notifications implemented for success/failure using `ShadToaster`.
        *   Corrected `ShadButton` and `ShadToast` API usage.
    *   **`CircleDetailScreen`:**
        *   Successfully fetches and displays detailed circle information.
        *   Correctly shows all members of the circle.
        *   Member avatars are now displayed (using `picsum.photos` placeholders).
        *   Member names are displayed below their avatars.
    *   **RLS & Debugging:** Successfully diagnosed and resolved complex RLS issues, including "infinite recursion" errors and problems with data visibility for nested resources and aggregate counts. Resolved schema mismatch errors during circle creation (missing columns, malformed array literals).

6.  **Flutter App Integration (Profile Page - View & Edit):**
    *   **`ProfileScreen.dart` Integration:**
        *   Successfully fetches and displays the logged-in user's `full_name`, `email` (read-only), and `avatar_url` from the `user_profiles` table.
        *   Logout functionality implemented using `Supabase.instance.client.auth.signOut()`.
        *   Account Deletion:
            *   Confirmation dialog implemented using `ShadDialog`.
            *   Calls the `public.delete_current_user()` SQL function to remove records from `user_profiles` and `auth.users`.
            *   User is signed out upon successful deletion.
    *   **`EditProfileScreen.dart` Integration:**
        *   Allows users to update their `full_name`.
        *   Avatar Management:
            *   Users can pick a new avatar image from the gallery (`image_picker`).
            *   The selected image is uploaded to Supabase Storage in the `user_avatars` bucket (path: `public/<user_id>/<filename>`).
            *   The `avatar_url` in the `user_profiles` table is updated with the public URL of the newly uploaded image.
        *   Email is displayed as read-only.
        *   User feedback (success/error messages) provided using `ShadToaster`.
    *   **SQL Function Enhancement:**
        *   `public.delete_current_user()`: New `SECURITY DEFINER` function created to securely handle the deletion of a user's data from `user_profiles` and their corresponding entry in `auth.users`.
    *   **UI & Theming Fixes:**
        *   Corrected `ShadToast` API usage to `ShadToaster.of(context).show(ShadToast(...))` and utilized `ShadToast.destructive()` constructor.
        *   Adjusted `ShadcnUI` theme color usage from incorrect `onPrimary` to `primaryForeground` for text/icons on primary backgrounds.

## Next Steps to Complete Integration:

1.  **Data Verification & Mock Data Finalization:**
    *   Ensure Diana is added as a 'joined' member to "Bookworm Club" so she sees two circles as intended by original mock data plan.
    *   Review all mock data for consistency and completeness.

2.  **Image Handling & Display (Robust Solution):**
    *   **Supabase Storage:**
        *   Create `user_avatars` bucket with appropriate access policies (public read for `public/*`, authenticated write for `public/<user_id>/*`). *(Partially addressed by profile edit, but policies need formal setup and verification)*.
        *   Create `circle_images` bucket with appropriate access policies.
        *   Update mock data to use actual Supabase Storage URLs for `image_url` (circles) and ensure `avatar_url` (users) are consistently managed via uploads.
    *   Ensure `Image.network` error builders in `CircleCard` and `CircleDetailScreen` (for circle header image) are robust or show appropriate placeholders.

3.  **Complete CRUD Operations for Circles:**
    *   **Create Circle:** UI and `CircleService.createCircle()`.
    *   **Update Circle:** UI and `CircleService.updateCircle()`.
    *   **Delete Circle:** Admin functionality and `CircleService.deleteCircle()`.
    *   **Manage Members:** Join/Request to Join, Approve/Reject, Leave/Remove functionality in UI and service.
    *   **Manage Interests:** Add/remove interests for a circle.

4.  **Complete CRUD Operations for Events:**
    *   **Create Event:** UI and `EventService.createEvent()`.
    *   **Update/Delete Event.**
    *   **RSVP to Events.**

5.  **User Profile Management:**
    *   Allow users to update their `full_name` and `avatar_url` (linking to Supabase Storage uploads). *(Largely completed)*
    *   Consider adding other profile fields (e.g., bio, phone - if schema is extended).

6.  **Real-time Functionality (Supabase Realtime):**
    *   Subscribe to changes for live updates in the UI.

7.  **Error Handling and User Feedback:**
    *   Implement comprehensive error handling and user feedback mechanisms.

8.  **Offline Support (Optional but Recommended).**

9.  **Refine RLS Policies (General Review):**
    *   Thoroughly test all RLS policies for tables not yet covered by CRUD operations.

10. **Testing:**
    *   Write unit, widget, and integration tests.

11. **Code Refinement & Optimization:**
    *   Clean up debug prints.
    *   Optimize queries and model parsing further if needed.

This list provides a roadmap for completing the Supabase integration. Prioritization will depend on the application's core feature requirements. 