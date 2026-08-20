# Words — browser version

Same idea as the native `VoicePolyglot` iPad app (tap a picture, hear a word,
say it back, hear a chime — no text, menus, or scores), but as a plain web
page. This version trades the offline requirement for simplicity: it uses
the browser's built-in (cloud-based) speech recognition, so **it needs an
internet connection to check what the child said**. Speech output (playing
the word) works offline once the page is loaded.

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
  iPad stuck on an older iOS version may not support it at all — the app
  degrades to always playing the gentle "try again" tone in that case
  (`app.js`'s `unavailable` outcome), never a wrong-answer buzz.
- Recognition quality/latency depends on network conditions, since it's
  processed in the cloud (unlike the native app's on-device recognition).
- Voice availability for `speechSynthesis` (especially Mandarin/Japanese)
  varies by device/OS version.

## Files

- `words.js` — the 30-word vocabulary list (same data as the native app).
- `app.js` — game state machine: rotation, speech in/out, progress,
  chimes.
- `index.html` / `style.css` — the entire on-screen UI (one big picture).
- `recordings/` — drop your own voice clips here (see its README).
- `manifest.webmanifest` — makes "Add to Home Screen" behave like a real app.

Progress (which words the child knows) is stored in the browser's
`localStorage`, per-device — clearing Safari's site data resets it.
