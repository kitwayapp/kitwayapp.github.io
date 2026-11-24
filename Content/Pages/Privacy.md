---
id: "privacy"
title: "Kitway Privacy Policy"
slug: "privacy"
legalDocument: true
---

Version of 2026-11-24.

---

Kitway is an iPhone app that plans a day out. This policy explains what data the app
handles and why.

**Who is responsible:** Oleksandr Solokha, oleksandr.solokha@gmail.com.

## The short version

- Kitway has no advertising and does not track you across other companies' apps and websites.
- You do not create an account. The app signs you in anonymously.
- Your plans and memories stay on your iPhone. Memories also go to your own iCloud.
  Kitway has no server of its own and does not see them.
- Kitway does not store your current position.
- You can export all your data and delete all your data in the app.

## Data on your device

Kitway keeps your data on your iPhone:

- **Plans and trips:** the city, the day, the places of each plan, which places you visited and when,
  and the mood and note you added to a place. Plans are not synced.
- **Memories:** the finished days, with the visited places, their coordinates, the stickers you earned,
  and your notes and moods. A memory also keeps the details of each place from the plan and, when one was
  found, a photo of the place from Wikimedia Commons with its author and licence. Memories are synced through
  your private iCloud database (see below).
- **Photos in memories** are references to photos in your library. Kitway does not copy or upload them.
  It keeps only the identifiers that iOS gives to find the photo again.
- **Voice notes** are transcribed on your iPhone. Kitway keeps only the text, never the audio.
- **Your traveller profile:** what you chose in onboarding (trip mode, budget, transport, interests,
  company) and, if you chose "At home, something new", your home city.
- **In the iOS Keychain:** the anonymous sign-in session of Firebase; a mark that you finished onboarding;
  and the number of Free plans you made this month (only the year, the month and a count).
- **Small settings** in the app's preferences, for example whether you share usage data.

<!-- Code: `Packages/Storage/Sources/Storage/KitwaySchemaV1.swift`, `Packages/Storage/Sources/Storage/FreePlan/`,
`Packages/VoiceNotes/Sources/VoiceNotes/SpeechVoiceRecorder.swift`. -->

### iCloud

Memories are synced with your private iCloud database through Apple's CloudKit. Apple stores them under
your Apple Account; Kitway cannot read them. If you turn iCloud off for Kitway, memories stay on this iPhone.
<!-- Decision: `docs/decisions/0028-memory-storage-and-apple-data.md`. -->

## Data that leaves your device

### Anonymous account

When the app starts, it signs in to Google's Firebase Authentication anonymously and
receives a random account identifier. The identifier is not tied to your name, email or
phone number; Kitway does not ask for them. Kitway stores nothing on a server with this
identifier.

<!-- Code: `App/Sources/Firebase/FirebaseAuthSession.swift`, `Packages/Core/Sources/Core/SessionStore.swift`. -->

### Plan generation

To make a plan, the app sends a request to Google's Gemini model through Firebase AI Logic. The request
contains the city and its region, the day and the hours of the plan, the time zone, the trip mode, the
budget, the transport, your interests, who comes with you, whether the day starts and ends at an airport,
the weather of those hours and the language of the plan. For a day of a trip it also contains the names of the places of the earlier days. The request
does not contain your coordinates, your notes, your memories or your photos. The request carries the
anonymous account identifier and the App Check token (see below). Google processes the request to answer it.
<!-- Code: `Packages/PlanEngine/Sources/PlanEngine/Generation/PlanPrompt.swift`. -->

### Location

Kitway asks for your location only while you use the app. It uses one position to find the city you are in,
to show the weather and to time the day. The position goes to Apple (maps and weather) for that request.
It does not go to Google: plan generation gets the city and its region only. Kitway does not store your position and
does not put it into analytics. You can choose a city by hand instead.
<!-- Code: `Packages/Places/Sources/Places/CoreLocationProvider.swift`. -->

### App integrity check

The app uses Firebase App Check with Apple's App Attest to confirm that requests come from
a genuine copy of Kitway on a genuine device. This involves a cryptographic attestation
issued by Apple and verified by Google; it does not contain personal information.
<!-- Code: `App/Sources/Firebase/FirebaseBootstrap.swift`. -->

### Technical data handled by Google

Firebase is provided by Google. According to Google's documentation, it may
process technical data such as the IP address and device information to provide and secure
the service, and it collects diagnostic data that is not linked to you. Google acts as a
processor of this data on our behalf. See the Firebase privacy information at
`https://firebase.google.com/support/privacy`.

### Analytics

Kitway counts how the app is used through Google Analytics for Firebase. For example: a day
was finished; how many places were visited (0 to 3); which answer you gave to the ticket
question. Distances and times are sent only as ranges, such as "3–6 km".

Kitway never adds a place, a city, a country, coordinates, links, notes, a mood, photos or
your account identifier to events. Kitway does not use the advertising identifier and does not
track you across other apps. Google receives your IP address with each upload and may
derive an approximate region from it.

Analytics is on by default. You can turn it off in the app: Kitway → Settings → Privacy & permissions →
"Share usage data". The same switch turns off crash reports.
<!-- Code: the event list — `Packages/Core/Sources/Core/Analytics/AnalyticsEvent.swift`; sending and the switch —
`App/Sources/Firebase/FirebaseAnalyticsSink.swift`; advertising signals, IDFV and automatic screen views are off
in `App/Info.plist`. -->

### Crash reports

When Kitway crashes, it sends a crash report through Firebase Crashlytics, which is provided by Google. The
report contains where in the app the crash happened, the device model, the iOS and app versions, and a random
identifier of this installation. Kitway never adds text, a place, coordinates, notes or your account
identifier to a report.

Crash reports follow the "Share usage data" switch. While it is off, Kitway sends no crash reports and
deletes the reports it did not send, so turning the switch on later never sends a crash from that time.
<!-- Code: `App/Sources/Firebase/FirebaseAnalyticsSink.swift`. Decision: `docs/decisions/0059-crashlytics-follows-usage-switch.md`. -->

### Place photos

To show a photo of a place, Kitway asks Wikipedia, Wikidata and Wikimedia Commons, which are run by the
Wikimedia Foundation. A request contains the title of the place's article, the coordinates of the place and the
language of the plan. It does not contain your position, your account identifier, your notes or your photos.
Wikimedia receives your IP address with each request. See the Wikimedia privacy policy at
`https://foundation.wikimedia.org/wiki/Policy:Privacy_policy`.
<!-- Code: `Packages/Places/Sources/Places/WikipediaPhotoSource.swift`. -->

### Maps, weather and purchases

- **Apple Maps and WeatherKit** answer requests for places, routes and weather. Apple receives the place or
  the position of the request.
- **Purchases** (Premium and the Trip Pass) are processed by Apple. Kitway does not receive your payment
  details. Your purchases belong to your Apple Account.

## Export your data

Kitway → Settings → Privacy & permissions → Your data → "Export my data" makes one ZIP archive: a JSON file
with your plans, trips, memories (with their notes and moods) and your traveller profile, and the Wikimedia
place photos that your memories keep. You can save or share it. The archive holds the places and dates of your
days, so share it only with people you trust. It does not contain your own photos or their identifiers.
<!-- Code: `Packages/Storage/Sources/Storage/UserDataExport.swift`. -->

## Delete your data

Kitway → Settings → Privacy & permissions → Your data → "Delete all data" deletes:

- your anonymous account in Firebase Authentication;
- your plans, trips, memories and traveller profile on this iPhone;
- your memories in iCloud, at the next sync, and so also on your other devices;
- the onboarding mark and the app's own records of your days (for example a pending ticket question);
- the analytics identifier of this installation, so that later events are not joined to earlier ones;
- the crash reports that were not sent yet.

After that Kitway starts again as on a new install, with a new anonymous account. The deletion needs an
internet connection. If it cannot reach the server, nothing is deleted and you can try again. If only a part
of the data on the iPhone was deleted, "Try again" finishes it.

These stay:

- the number of Free plans you made this month. It is a count with no identifier, and it keeps the monthly
  Free limit;
- Premium and the Trip Pass, because they belong to your Apple Account;
- your "Share usage data" choice;
- analytics events that were already sent. They do not contain your account identifier, and Google keeps them
  for the retention period of Google Analytics.

<!-- Code: `Packages/Core/Sources/Core/UserData/FreshStart.swift`. Decision: `docs/decisions/0035-delete-all-data-and-export.md`. -->

### When you remove the app

Removing the app deletes the plans, memories and settings stored in the app on this iPhone. It does not delete:

- your memories in iCloud;
- the anonymous account in Firebase Authentication;
- 3 items in the iOS Keychain, which iOS keeps after an app is removed: the Firebase sign-in session, the
  onboarding mark (so that Kitway can greet you back) and the number of Free plans this month.

When you install Kitway again, the app signs out of the old account on its first launch and gets a new one.
The old account holds only its random identifier, because Kitway stores nothing with it. To delete everything, use "Delete all data"
before you remove the app: it deletes the account, your data and the onboarding mark. The Free plan count
stays. To have an old account deleted, write to oleksandr.solokha@gmail.com.

## Your choices and rights

- **Location, photos and microphone:** you can refuse or revoke access in iOS Settings at any time.
- **Analytics and crash reports:** you can turn them off in the app (see above).
- **Export and deletion:** in the app (see above).
- If you are in the EU, the EEA, the UK or Ukraine, you have the right to access, correct,
  delete and export your personal data, to object to its processing and to complain to your
  data protection authority.

## Children

Kitway is not directed at children under 13.

## This website

This website, kitwayapp.github.io, is hosted by GitHub Pages. It sets no cookies, has no analytics and loads
nothing from other websites. GitHub receives your IP address to deliver the pages and keeps it in its logs for
security; see the GitHub Privacy Statement at
`https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement`. The site keeps your
choice of language and of light or dark theme in your browser's local storage; this choice never leaves your
browser.

## Changes

We will update this policy when the app's behaviour changes and state the date at the top.
