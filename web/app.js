// Voice-only picture-word game: tap the picture, hear the word, say it back,
// hear a chime. No text, menus, or scores are ever shown on screen.
// This "online" build uses the browser's cloud speech recognition, so it
// needs an internet connection (unlike the offline native iPad build).

const STORAGE_KEY = "vp_progress_v1";
const LISTEN_TIMEOUT_MS = 4500;

const state = {
  languageIndex: 0,
  currentWord: null,
  phase: "idle", // idle | prompting | listening | feedback
  lastWordId: null,
};

// ---------- progress persistence (localStorage, per-device) ----------

function loadProgress() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {};
  } catch {
    return {};
  }
}

function saveProgress(progress) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
}

function recordAttempt(wordId, langId, correct) {
  const progress = loadProgress();
  const key = `${langId}_${wordId}`;
  const stat = progress[key] || { attempts: 0, correct: 0 };
  stat.attempts += 1;
  if (correct) stat.correct += 1;
  progress[key] = stat;
  saveProgress(progress);
}

function weightFor(wordId, langId) {
  const progress = loadProgress();
  const stat = progress[`${langId}_${wordId}`];
  if (!stat || stat.attempts === 0) return 3.0; // unseen: prioritize introducing it
  const successRate = stat.correct / stat.attempts;
  return 3.0 - successRate * 2.6; // well-known words come up less often
}

// ---------- word/language rotation ----------

function currentLanguage() {
  return LANGUAGES[state.languageIndex];
}

function pickWord(langId, excludeId) {
  const candidates = WORDS.filter((w) => w.id !== excludeId);
  const pool = candidates.length ? candidates : WORDS;
  const weights = pool.map((w) => weightFor(w.id, langId));
  const total = weights.reduce((a, b) => a + b, 0);
  let pick = Math.random() * total;
  for (let i = 0; i < pool.length; i++) {
    if (pick < weights[i]) return pool[i];
    pick -= weights[i];
  }
  return pool[pool.length - 1];
}

function advanceRound() {
  state.languageIndex = (state.languageIndex + 1) % LANGUAGES.length;
  state.currentWord = pickWord(currentLanguage().id, state.lastWordId);
  state.lastWordId = state.currentWord.id;
  state.phase = "idle";
  render();
}

// ---------- audio: word prompt (own recording, else speech synthesis) ----------

function speakWord(word, lang, onDone) {
  const recordingSrc = `recordings/${lang.id}_${word.id}.mp3`;
  const audio = new Audio(recordingSrc);
  let usedRecording = true;

  audio.addEventListener("ended", onDone, { once: true });
  audio.addEventListener(
    "error",
    () => {
      usedRecording = false;
      speakSynthesized(word[lang.id], lang.locale, onDone);
    },
    { once: true }
  );

  audio.play().catch(() => {
    if (usedRecording) {
      usedRecording = false;
      speakSynthesized(word[lang.id], lang.locale, onDone);
    }
  });
}

function speakSynthesized(text, locale, onDone) {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = locale;
  utterance.rate = 0.9;
  utterance.onend = onDone;
  utterance.onerror = onDone;
  speechSynthesis.cancel();
  speechSynthesis.speak(utterance);
}

// ---------- audio: success / try-again chimes (Web Audio, no sound files) ----------

const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

function playTone(frequencies, noteDuration) {
  let t = audioCtx.currentTime;
  frequencies.forEach((freq) => {
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.frequency.value = freq;
    osc.connect(gain);
    gain.connect(audioCtx.destination);
    gain.gain.setValueAtTime(0, t);
    gain.gain.linearRampToValueAtTime(0.25, t + 0.01);
    gain.gain.linearRampToValueAtTime(0, t + noteDuration);
    osc.start(t);
    osc.stop(t + noteDuration);
    t += noteDuration;
  });
}

function playSuccess() {
  playTone([523.25, 659.25, 783.99], 0.12); // bright C-E-G
}

function playTryAgain() {
  playTone([392.0, 349.23], 0.18); // soft G-F, no shame
}

// ---------- speech recognition (cloud-based; requires internet + HTTPS) ----------

const SpeechRecognitionImpl = window.SpeechRecognition || window.webkitSpeechRecognition;

function listenFor(expectedWord, locale, onOutcome) {
  if (!SpeechRecognitionImpl) {
    onOutcome("unavailable");
    return;
  }

  const recognizer = new SpeechRecognitionImpl();
  recognizer.lang = locale;
  recognizer.interimResults = false;
  recognizer.maxAlternatives = 1;

  let finished = false;
  const finish = (outcome) => {
    if (finished) return;
    finished = true;
    clearTimeout(timeoutId);
    try {
      recognizer.stop();
    } catch {}
    onOutcome(outcome);
  };

  recognizer.onresult = (event) => {
    const heard = event.results[0]?.[0]?.transcript || "";
    finish(matches(heard, expectedWord) ? "matched" : "notMatched");
  };
  recognizer.onerror = () => finish("notMatched");
  recognizer.onend = () => finish("notMatched");

  const timeoutId = setTimeout(() => finish("notMatched"), LISTEN_TIMEOUT_MS);

  try {
    recognizer.start();
  } catch {
    finish("unavailable");
  }
}

function normalize(text) {
  return text
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "") // strip diacritics
    .toLowerCase()
    .trim();
}

function levenshtein(a, b) {
  if (!a.length) return b.length;
  if (!b.length) return a.length;
  const prev = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    let cur = [i];
    for (let j = 1; j <= b.length; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      cur[j] = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost);
    }
    prev.splice(0, prev.length, ...cur);
  }
  return prev[b.length];
}

function matches(heard, expected) {
  const h = normalize(heard);
  const e = normalize(expected);
  if (!h) return false;
  if (h === e) return true;
  if (h.includes(e) || e.includes(h)) return true;
  return levenshtein(h, e) <= 1;
}

// ---------- game loop ----------

function tapPicture() {
  if (state.phase !== "idle") return;
  state.phase = "prompting";
  render();

  const word = state.currentWord;
  const lang = currentLanguage();

  speakWord(word, lang, () => {
    state.phase = "listening";
    render();
    listenFor(word[lang.id], lang.locale, (outcome) => {
      state.phase = "feedback";
      render();

      if (outcome === "matched") {
        recordAttempt(word.id, lang.id, true);
        playSuccess();
      } else if (outcome === "notMatched") {
        recordAttempt(word.id, lang.id, false);
        playTryAgain();
      } else {
        playTryAgain(); // don't penalize a device/browser limitation
      }

      setTimeout(advanceRound, 1200);
    });
  });
}

// ---------- rendering ----------

const pictureEl = document.getElementById("picture");
const stageEl = document.getElementById("stage");
const tapTargetEl = document.getElementById("tap-target");

function render() {
  const lang = currentLanguage();
  stageEl.style.backgroundColor = lang.bg;
  pictureEl.textContent = state.currentWord.emoji;
  tapTargetEl.classList.toggle("listening", state.phase === "listening");
  tapTargetEl.disabled = state.phase !== "idle";
}

function init() {
  state.currentWord = pickWord(currentLanguage().id, null);
  state.lastWordId = state.currentWord.id;
  render();
  tapTargetEl.addEventListener("click", () => {
    audioCtx.resume();
    tapPicture();
  });
}

init();
