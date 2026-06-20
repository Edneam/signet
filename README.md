# Signet

Local, private **voice dictation + AI commands for Hyprland**. Hold a key, speak, and clean text lands wherever your cursor is — terminal, browser, WhatsApp Web, editor. Nothing leaves your machine. No cloud, no API keys, no subscription, no word limits.

Named for the *signet* of *Fourth Wing*'s Scribe Quadrant — a power channeled from your core, and the seal that presses your mark onto the page.

```
hold a key → record → denoise → transcribe (whisper.cpp) → Gemma → inject at cursor
```

## Modes (one key each, hold-to-talk)

| Key | Mode | What it does |
|---|---|---|
| **F9** | Dictate | Speak → clean, punctuated text at your cursor (fillers removed, names fixed, tone-matched) |
| **F10** | Command | Select text, hold F10, speak an instruction ("make this a bullet list", "make it formal", "shorten this") → it rewrites the selection |
| **F11** | Translate | Speak any language → it types the `English` (configurable) translation |

Plus **snippets**: say a cue ("my email") → it expands to canned text, instantly.

## Why it's different
Open-source dictation tools stop at raw transcription. Signet adds the **cleanup + AI command layer** that makes tools like Wispr Flow feel magic — and it's **free, unlimited, and 100% local**. Wispr gates unlimited words and AI commands behind a subscription; Signet gives them away because there's no metering.

- **STT:** NVIDIA **Parakeet V3** (int8, ONNX, CPU-optimized) via a tiny warm server — ~3x real-time, excellent accuracy, automatic language detection. whisper.cpp `base.en` is a built-in fallback (`STT_ENGINE=whisper`).
- **Brain:** Gemma 4 `e2b` via Ollama — auto-cleanup (fillers, **grammar fix**, punctuation, **number/date formatting**, **auto-bullets when listing**), commands, translation; warm-on-keypress
- **Injection:** Ctrl+V for browsers (WhatsApp Web), direct typing for terminals/native; **saves & restores your clipboard**
- **~3s fast mode / ~6s with full polish**, fully on-device. Subtle sound cues. Graceful when Ollama is down.

## Install (Arch / Hyprland)

```bash
# from source
git clone https://github.com/Edneam/signet
sudo install -Dm755 signet/signet /usr/bin/signet
# AUR (planned): paru -S signet-voice
```
Deps: `whisper.cpp ollama wtype wl-clipboard pipewire ffmpeg jq curl libnotify`.

## Setup

```bash
signet setup     # downloads whisper fallback model, pulls gemma4:e2b, unmutes mic, generates cues, prints binds
signet doctor    # verifies everything
```

### Parakeet STT (default engine — fast, recommended)
Parakeet runs in a lightweight ONNX venv (no PyTorch). One-time install:
```bash
uv venv ~/.local/share/signet/asr
uv pip install --python ~/.local/share/signet/asr "onnx-asr[cpu,hub]"
~/.local/share/signet/asr/bin/python - <<'PY'
from huggingface_hub import snapshot_download
snapshot_download("istupakov/parakeet-tdt-0.6b-v3-onnx",
    local_dir="$HOME/.local/share/signet/models/parakeet-v3",
    allow_patterns=["*int8*","*.json","*.txt","vocab*","config*"])
PY
```
(Prefer whisper instead? Set `STT_ENGINE=whisper` in config — no Parakeet install needed.)

Add to `~/.config/hypr/hyprland.conf`:
```ini
exec-once = signet warm                  # preload Parakeet + Gemma at login (no cold start)
bind  = , F9,  exec, signet start
bindr = , F9,  exec, signet stop
bind  = , F10, exec, signet start command
bindr = , F10, exec, signet stop
bind  = , F11, exec, signet start translate
bindr = , F11, exec, signet stop
```
Push-to-talk keys must be **non-modifiers** (F-keys). For single-tap, bind `signet toggle`.

## Config — `~/.config/signet/config`
```sh
STT_ENGINE="parakeet"     # parakeet (fast, auto-language) | whisper
GEMMA="gemma4:e2b"
KEEP_ALIVE="30m"          # keep Gemma warm; "-1" = never unload (no cold starts, more RAM)
CLEANUP=1                 # 1 = Gemma polish ; 0 = fast mode (STT only, ~half time)
TONE="auto"               # auto | none | email | slack | code | casual | formal
TARGET_LANG="English"     # translate mode target
PASTE_MODE="auto"         # auto | paste | clipboard | stdout
WTYPE_DELAY=12            # ms between keys when typing directly
THREADS=8
```
- **Dictionary:** `~/.config/signet/dictionary.txt` — names/terms to spell correctly (one per line).
- **Snippets:** `~/.config/signet/snippets` — `cue = expansion` lines.

## Commands
`signet start [dictate|command|translate] · stop · toggle · warm · setup · doctor · status · config · version`

## Notes & limits
- Hyprland/Wayland only for injection.
- English-focused (translate handles other languages in → English out).
- First dictation after idle pays a one-time model load; warm-on-keypress hides most of it.

## License
Apache-2.0
