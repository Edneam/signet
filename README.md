# Scriptorium

Local, private voice dictation for Linux. Hold a key, speak, and clean text lands wherever your cursor is — terminal, browser, WhatsApp Web, editor. Nothing leaves your machine.

Named for the Scribe Quadrant's scriptorium in *Fourth Wing* — the room where scribes turn speech into record.

## How it works

```
hold F9 → record (PipeWire) → denoise (ffmpeg) → transcribe (whisper.cpp)
        → clean up (Gemma 4 via Ollama) → inject at cursor (wtype / clipboard paste)
```

- **STT:** whisper.cpp `base.en` (≈0% WER on Indian English in testing, ~1.2s)
- **Cleanup:** Gemma 4 `e2b` via Ollama chat API — strips fillers (um, uh, like), fixes punctuation, applies a personal dictionary for names. Never re-words.
- **Injection:** context-aware — Ctrl+V paste for browsers (WhatsApp Web), Ctrl+Shift+V for terminals, direct typing for native apps. Always copies to clipboard as a fallback.
- **Latency:** ~2.2s warm.
- **Privacy:** fully on-device. No cloud, no API keys.

## Requirements

- Hyprland (Wayland) — uses `wtype`, `wl-copy`, `hyprctl`
- `whisper.cpp` built with a `base.en` model
- `ollama` with `gemma4:e2b` (or `e4b`) pulled
- `pw-record` (PipeWire), `ffmpeg`, `jq`, `curl`

## Usage

Hold **F9**, speak, release. Cleaned text appears at the cursor.

Add names/terms it should spell correctly to `dictionary.txt` (one per line).

## Config

Edit the variables at the top of `ptt.sh`:
- `MODEL` — whisper model path
- `GEMMA` — Ollama model tag
- `KEEP_ALIVE` — how long Ollama keeps the model warm (memory vs. speed)

## Status

English (incl. Indian accent) works well. Malayalam/Manglish support is in progress
(vanilla Whisper translates Malayalam to English; needs a Malayalam-fine-tuned model).

## License

Apache-2.0
