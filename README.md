# Scriptorium

Local, private **voice dictation for Hyprland**. Hold a key, speak, and clean text lands wherever your cursor is — terminal, browser, WhatsApp Web, editor. Nothing leaves your machine. No cloud, no API keys, no subscription.

Named for the Scribe Quadrant's scriptorium in *Fourth Wing* — the room where scribes turn speech into record.

```
hold F9 → record → denoise → transcribe (whisper.cpp) → clean up (Gemma) → inject at cursor
```

## Why it's different
Most open-source dictation tools stop at raw transcription. Scriptorium adds the **cleanup layer** that makes tools like Wispr Flow feel magic — fillers removed, punctuation fixed, your names spelled right — running **entirely on your CPU**.

- **STT:** whisper.cpp `small.en` (strong on Indian English)
- **Cleanup:** Gemma 4 `e2b` via Ollama — strips `um/uh/like`, fixes punctuation, applies a personal dictionary for names. Never re-words.
- **Smart injection:** Ctrl+V for browsers (WhatsApp Web), Ctrl+Shift+V for terminals, direct typing for native apps. **Saves and restores your clipboard.**
- **~2–4s warm**, fully on-device. Subtle sound cues. Graceful when Ollama is down.

## Install (Arch / Hyprland)

```bash
# AUR (coming soon)
# paru -S scriptorium

# from source
git clone https://github.com/Edneam/scriptorium
sudo install -Dm755 scriptorium/scriptorium /usr/bin/scriptorium
```

Dependencies: `whisper.cpp ollama wtype wl-clipboard pipewire ffmpeg jq curl libnotify` (Hyprland for the keybinds).

## First-run setup

```bash
scriptorium setup     # downloads the model, pulls gemma4:e2b, unmutes mic, generates cues
scriptorium doctor    # verifies everything; tells you how to fix anything missing
```

Then add the push-to-talk bind to `~/.config/hypr/hyprland.conf` (or a sourced file):

```ini
bind  = , F9, exec, scriptorium start
bindr = , F9, exec, scriptorium stop
```

Reload Hyprland (`hyprctl reload`). **Hold F9, speak, release** — cleaned text appears at your cursor.

> A push-to-talk key must be a **non-modifier** (F-keys, etc.). Modifiers like Alt don't fire a release event in Hyprland. For a single-tap toggle instead, bind `scriptorium toggle`.

## Commands

| Command | What it does |
|---|---|
| `scriptorium start` / `stop` | record / transcribe+inject (bind to key press/release) |
| `scriptorium toggle` | start if idle, else stop (single-tap key) |
| `scriptorium warm` | preload Gemma so the first dictation isn't cold |
| `scriptorium setup` | first-run configuration |
| `scriptorium doctor` | check dependencies and config |
| `scriptorium status` | show config + recent activity |

## Configuration

`~/.config/scriptorium/config` (created by `setup`):

```sh
GEMMA="gemma4:e2b"        # cleanup model (ollama tag)
KEEP_ALIVE="5m"           # how long Gemma stays in RAM (memory vs. speed)
LANG_CODE="en"
PASTE_MODE="auto"         # auto | paste | clipboard | stdout
SOUND=1                   # subtle start/stop cue
MIC="@DEFAULT_AUDIO_SOURCE@"
ON_OLLAMA_DOWN="warn-raw" # warn-raw | abort
THREADS=12
```

**Personal dictionary** — add names/terms (one per line) to `~/.config/scriptorium/dictionary.txt`; Scriptorium fixes phonetic mishears to those exact spellings (e.g. a misheard name → the right one).

`PASTE_MODE=stdout` makes it scriptable: `scriptorium toggle` then pipe the text anywhere.

## Paths (XDG)

| | |
|---|---|
| config | `~/.config/scriptorium/` |
| model | `~/.local/share/scriptorium/models/` |
| logs | `~/.local/state/scriptorium/scriptorium.log` |
| runtime | `$XDG_RUNTIME_DIR/scriptorium/` |

## Notes & limits

- Hyprland/Wayland only for injection (uses `wtype`, `wl-clipboard`, `hyprctl`).
- English (incl. Indian accent) is the focus. Malayalam/Manglish needs a fine-tuned model + more compute than a CPU laptop offers — parked for now.
- First dictation after idle pays a one-time model load; `scriptorium warm` (or bind it to login) avoids it.

## License

Apache-2.0
