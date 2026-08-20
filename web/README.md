# Words — browser version

A voice-only language game for a toddler who can't read yet: tap a picture,
hear a word, say it back, hear a chime. No text, menus, or scores anywhere
on screen. Teaches English, Slovak, Czech, and Italian at once, cycling
through the same 30 objects in all four, and quietly repeats whichever
words she's been missing.

This is a plain web page, not a native app — it uses the browser's built-in
(cloud-based) speech recognition, so **it needs an internet connection to
check what the child said**. Speech output (playing the word) works offline
once the page is loaded.

## Running it

This needs to be served over **HTTPS** (or `localhost`) — browsers refuse
microphone access (`getUserMedia`) on a plain `http://` page, so opening
`index.html` directly from disk on the iPad won't work.

Easiest options:
- Push this `web/` folder to GitHub Pages, Netlify, Vercel, or Cloudflare
  Pages (free tier is fine) and open the resulting `https://` URL on the
  iPad.
- For local testing on a Mac: `npx serve web` and open the printed
  `https://` / `localhost` URL in Safari on the iPad (same Wi-Fi network;
  plain `http://<lan-ip>` will not get mic access on iOS).

On the iPad, use **Share → Add to Home Screen** for a full-screen, app-like
experience (uses `manifest.webmanifest`).

## Browser support caveats

- Speech recognition (`SpeechRecognition` / `webkitSpeechRecognition`) is
  supported in Safari 14.5+ (iOS/iPadOS 14.5+) and Chrome. A genuinely old
  iPad stuck on an older iOS version may not support it at all, and
  Slovak/Czech recognition quality is likely to be weaker than
  English/Italian — the app degrades to always playing the gentle "try
  again" tone in that case (`app.js`'s `unavailable` outcome), never a
  wrong-answer buzz.
- Recognition quality/latency depends on network conditions, since it's
  processed in the cloud.
- Voice availability for `speechSynthesis` in Slovak and Czech varies by
  device/OS version and may sound more robotic than English/Italian; using
  your own recordings (see below) sidesteps this entirely.

## Adding your own voice recordings

See [`recordings/README.md`](recordings/README.md) — drop in `.mp3` files
named `<lang>_<wordId>.mp3` and they're preferred automatically over speech
synthesis.

## Files

- `words.js` — the 30-word vocabulary list (English, Slovak, Czech, Italian).
- `app.js` — game state machine: rotation, speech in/out, progress, chimes.
- `index.html` / `style.css` — the entire on-screen UI (one big picture).
- `recordings/` — drop your own voice clips here (see its README).
- `manifest.webmanifest` — makes "Add to Home Screen" behave like a real app.

Progress (which words the child knows) is stored in the browser's
`localStorage`, per-device — clearing Safari's site data resets it.

## How the learning logic works

- **Language rotation**: each round advances English → Slovak → Czech →
  Italian → English...
- **Word selection**: within a language, words she's never been tried on or
  has been missing lately are picked more often than ones she already knows
  (see `weightFor` / `pickWord` in `app.js`).
- **Feedback**: a bright ascending chime for a correct answer, a soft
  neutral tone otherwise — synthesized at runtime via Web Audio, no sound
  files, no visible score.

## Known limitations

- Speech-match tolerance (`matches` in `app.js`) is a simple fuzzy string
  comparison (diacritic-insensitive, allows a 1-character slip); it hasn't
  been tuned against a real 3-year-old's pronunciation, and Slovak/Czech
  diacritics/consonant clusters may need more tolerance than English/Italian.
- Not yet tested in an actual browser/device — this is a first draft.
