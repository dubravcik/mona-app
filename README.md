# Words (VoicePolyglot)

A voice-only language app for a toddler who can't read yet. No text on screen,
no menus, no scores. She taps one big picture, hears a word, says it back, and
the app plays a soft chime if she got it. It teaches English, Spanish,
Mandarin, and Japanese at once, cycling through the same 30 objects in all
four, and quietly repeats whichever words she's been missing. It's built to
run fully offline on an old iPad.

## Why a native iOS app

Offline, on-device speech recognition on an iPad is only reliably available
through Apple's `Speech` framework — no web browser on iOS offers that. So
this is a SwiftUI app, not a web page.

## Project layout

```
VoicePolyglot/
  project.yml        # XcodeGen spec — generates the .xcodeproj (not committed)
  Info.plist
  Sources/
    App/             # App entry point + permission gating
    Models/          # WordItem, the 30-word library, Language enum
    Services/        # audio playback, speech recognition, progress, tones
    ViewModels/       # GameViewModel — the state machine for one round
    Views/           # PlayView — the entire on-screen experience
```

## Building it

Requires a Mac with Xcode, and [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
cd VoicePolyglot
xcodegen generate
open VoicePolyglot.xcodeproj
```

In Xcode: pick your Apple ID / team under Signing & Capabilities (or set
`DEVELOPMENT_TEAM` in `project.yml`), plug in the iPad, and Run.

### One-time setup per iPad (needs internet, once)

On-device speech recognition requires iOS to have already downloaded the
dictation model for each language. On the iPad, before going fully offline:

1. Settings → General → Keyboard → Keyboards → Add New Keyboard, add
   Spanish, Chinese (Simplified, Pinyin), and Japanese (Romaji), and open
   each keyboard briefly.
2. Settings → Siri & Search → Language, briefly switch through Spanish,
   Chinese, and Japanese and back to English — this triggers iOS to fetch
   each language's on-device speech model.

After that, the app works with the iPad in Airplane Mode.

## Adding your own voice recordings

Record short clips of yourself or your wife saying a word, named
`<lang>_<wordId>.m4a`, e.g. `en_apple.m4a`, `es_apple.m4a` (language codes:
`en`, `es`, `zh`, `ja`; word ids are the English names in
`Sources/Models/WordLibrary.swift`, e.g. `apple`, `dog`, `tree`...).

Drop them into the iPad's app Documents folder under `Recordings/` (via the
Files app, with "Word" enabled for file sharing) — no rebuild needed, the app
checks there first. Any word/language without a recording automatically
falls back to on-device speech synthesis, so you only need to record the
words you actually want in your own voice.

## Using real photos instead of the default emoji

By default each object is shown as a big emoji (zero setup required). To use
a real photo instead, add an image named after the word id (e.g. `apple.jpg`)
to the Xcode asset catalog or bundle — `PlayView` prefers a matching image
over the emoji automatically.

## How the learning logic works

- **Language rotation**: each round advances English → Spanish → Mandarin →
  Japanese → English...
- **Word selection**: within a language, words she's never been tried on or
  has been missing lately are picked more often than ones she already knows
  (`Services/ProgressStore.swift`, `Services/RotationEngine.swift`).
- **Progress persistence**: attempt/success counts per word+language are
  saved to a JSON file on-device (`Documents/progress.json`) and survive app
  restarts.
- **Feedback**: a bright ascending chime for a correct answer, a soft neutral
  tone otherwise — synthesized at runtime, no sound files, no visible score.

## Known limitations / next steps

- Speech-match tolerance (`SpeechRecognitionService.matches`) is a simple
  fuzzy string comparison; it hasn't been tuned against a real 3-year-old's
  pronunciation and may need adjusting per language.
- On-device recognition availability for Mandarin/Japanese can vary by iOS
  version; the app treats "unavailable" as a gentle non-event rather than
  a wrong answer.
- No unit tests yet — this hasn't been run on real hardware or verified in
  Xcode (this project was scaffolded without access to a Mac/Xcode).
