# FitQuest

**AI-powered adaptive fitness & nutrition — a Flutter app backed by Firebase.**

FitQuest builds adaptive workout plans, answers training questions through an
AI coach, scans food for nutrition, and tracks your progress — all synced to
Firebase.

## Features

- **Adaptive workout plans** tuned to the user's goals and progress
- **AI coach chat** — multi-model assistant via OpenRouter (Gemini, GPT-4o-mini,
  DeepSeek, Claude Haiku, Llama 3.3)
- **Food scan** — nutrition estimation powered by Google Gemini
- **Progress tracking** with history and insights
- **Accounts** — email/password and Google sign-in (Firebase Auth)
- **Realtime sync** via Cloud Firestore + Realtime Database

## Tech stack

| Layer | Tech |
|---|---|
| App | Flutter / Dart (`>=3.0.0 <4.0.0`) |
| Backend | Firebase — Auth, Cloud Firestore, Realtime Database |
| AI | OpenRouter (chat/coach), Google Gemini (food scan) |

## Getting started

```bash
flutter pub get
flutter run --dart-define=OPENROUTER_API_KEY=your_openrouter_key
```

### API keys & configuration

- **OpenRouter key** is **not** bundled in the app. Supply it at build/run time:

  ```bash
  flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
  ```

  Users can also enter their own key in the app's AI model settings.
- **Firebase** config lives in `lib/firebase_options.dart` and
  `android/app/google-services.json`. Firebase web/Android API keys are not
  secrets — access is enforced by the Firestore / Realtime Database security
  rules in `firebase/`.

## Project layout

    lib/core/services/     Firebase, OpenRouter, auth, and other services
    lib/features/          app screens (auth, chatbot/coach, progress, …)
    lib/models/            data models (workout plans, etc.)
    lib/providers/         app state
    firebase/              Firestore + Realtime Database security rules
    test/                  widget & integration tests

## License

Released under the [MIT License](LICENSE).
