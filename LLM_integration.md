# LLM Integration for Event Matching

This document walks you through adding an AI-powered event-matching workflow to your Social Circle Manager app. You’ll:

1. Inspect your Supabase schema  
2. Create two new tables for match sessions & recommendations  
3. Build a Supabase Edge Function that fetches data, calls the LLM, and persists results  
4. Deploy the function  
5. Invoke it from Flutter and wire it into your existing screens  

---

## 1. Inspect Your Supabase Schema

Use the Supabase CLI to generate Dart types and confirm which tables/columns exist:

```bash
# Install & log in if you haven’t already
supabase login

# Generate Dart models for your public schema
supabase gen types dart \
  --project-id <YOUR_PROJECT_REF> \
  --schema public \
  > lib/models/supabase_types.dart
```

Open `lib/models/supabase_types.dart` and verify you have (at minimum) these tables and columns:

• **user_profiles**  
  • id (uuid PK)  
  • updated_at (timestamptz)  
  • email (text)  
  • full_name (text)  
  • avatar_url (text)

• **circles**  
  • id (uuid PK)  
  • name, description (text)  
  • preferred_days, preferred_times, common_activities (text[])  
  • hex_color (text)  
  • created_by (uuid), created_at, updated_at (timestamptz)

• **circle_members**  
  • circle_id (uuid → circles.id)  
  • user_id (uuid → user_profiles.id)

• **events**  
  • id (uuid PK)  
  • circle_id (uuid → circles.id)  
  • created_by_user_id (uuid → user_profiles.id)  
  • title, description (text)  
  • start_time, end_time (timestamptz)  
  • location (text)  
  • created_at, updated_at (timestamptz)

• **event_attendees**  
  • event_id, user_id (uuids)  
  • rsvp_status (enum)  
  • status (text)  
  • created_at, updated_at (timestamptz)

• **interests**, **circle_interests**  
  • (your existing interest tables)

---

## 2. Create Matching Tables

Run these SQL statements in Supabase → SQL editor:

```sql
-- 1) Record each matching session
create table if not exists event_matching_sessions (
  id             uuid          primary key default gen_random_uuid(),
  circle_id      uuid          not null references circles(id),
  event_preferences text       not null,
  budget         text          not null,
  availability   text          not null,
  created_by     uuid          default auth.uid(),
  created_at     timestamptz   default now()
);

-- 2) Store recommendations per session
create table if not exists event_matching_recommendations (
  id                         uuid     primary key default gen_random_uuid(),
  session_id                 uuid     not null references event_matching_sessions(id),
  event_id                   uuid     not null references events(id),
  score_total                numeric  not null,
  score_constraint_time      numeric  not null,
  score_constraint_location  numeric  not null,
  score_constraint_other     numeric  not null,
  score_preference           numeric  not null,
  created_at                 timestamptz default now()
);
```

---

## 3. Build the Edge Function

Create a new function at `supabase/functions/match_events/index.ts`:

```typescript
import { serve } from "std/server";
import { createClient } from "@supabase/supabase-js";
import OpenAI from "openai";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY")! });

serve(async (req) => {
  const { circle_id, event_preferences, budget, availability } = await req.json();

  // A) Create session
  const { data: session, error: sessionErr } = await supabase
    .from("event_matching_sessions")
    .insert({ circle_id, event_preferences, budget, availability })
    .select("*")
    .single();
  if (sessionErr || !session) throw sessionErr;

  // B) Fetch circle members & user profiles
  const { data: members } = await supabase
    .from("circle_members")
    .select("user_id")
    .eq("circle_id", circle_id);
  const userIds = members?.map((m) => m.user_id) ?? [];
  const { data: users } = await supabase
    .from("user_profiles")
    .select("*")
    .in("id", userIds);

  // C) Fetch events for this circle
  const { data: events } = await supabase
    .from("events")
    .select("*")
    .eq("circle_id", circle_id);

  // D) Call LLM
  const messages = [
    { role: "system", content: "You are an AI assistant specialized in personalized event evaluation. ..." },
    {
      role: "user",
      content: JSON.stringify({ events, users, event_preferences, budget, availability }),
    },
  ];
  const chat = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages,
  });
  const recs = JSON.parse(chat.choices[0].message.content as string);

  // E) Persist recommendations
  const toInsert = recs.map((r: any) => ({
    session_id: session.id,
    event_id: r.event_id,
    score_total: r.score_total,
    score_constraint_time: r.score_constraint_time,
    score_constraint_location: r.score_constraint_location,
    score_constraint_other: r.score_constraint_other,
    score_preference: r.score_preference,
  }));
  await supabase.from("event_matching_recommendations").insert(toInsert);

  // F) Return top‐n
  return new Response(JSON.stringify({ session_id: session.id, recommendations: recs }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

---

## 4. Deploy the Edge Function

```bash
cd supabase/functions/match_events
supabase functions deploy match_events
```

---

## 5. Invoke from Flutter

In `create_event_match_screen.dart`, replace your mock `_handleSubmit()` with:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/event_recommendation_model.dart';

final supabase = Supabase.instance.client;

Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.saveAndValidate()) return;

  final payload = {
    'circle_id': _selectedCircle!.id,
    'event_preferences': _eventPreferencesController.text,
    'budget': _selectedBudget,
    'availability': _availabilityPreferencesController.text,
  };

  final resp = await supabase.functions.invoke(
    'match_events',
    payload: payload,
  );

  if (resp.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${resp.error!.message}')),
    );
    return;
  }

  final data = resp.data as Map<String, dynamic>;
  final recs = (data['recommendations'] as List)
      .map((m) => EventRecommendation.fromMap(m))
      .toList();

  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => EventMatchingScreen(
        circle: _selectedCircle!,
        eventPreferences: payload,
        recommendations: recs,
      ),
    ),
  );
}
```

Add a matching constructor to `EventMatchingScreen`:

```dart
final List<EventRecommendation> recommendations;

EventMatchingScreen({
  required this.circle,
  required this.eventPreferences,
  this.recommendations = const [],
});
```

And in `event_matching_screen.dart`, remove the mock loader and display `widget.recommendations`.

---

## 6. Final Checks & Testing

1. **Schema validation**: Confirm your tables and columns match exactly.  
2. **Edge Function**: Test in Supabase UI with sample payload.  
3. **Flutter**: Run on device, input preferences, tap “Suggest Events” → verify recommendations appear.  
4. **Persistence**: Query `event_matching_sessions` & `event_matching_recommendations` in Supabase to confirm data logged.  

You now have a fully integrated, server-driven, LLM-powered event matching flow with Supabase Edge Functions!