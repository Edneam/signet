#!/usr/bin/env bash
# Manglish/English dictation — push-to-talk pipeline
# usage: ptt.sh start | stop
set -uo pipefail

WHISPER=~/projects/whisper.cpp/build/bin/whisper-cli
MODEL=~/projects/whisper.cpp/models/ggml-base.en.bin
WAV=/tmp/ptt.wav
PIDFILE=/tmp/ptt.rec.pid
LOG=/tmp/ptt.log
OLLAMA=http://localhost:11434/api/generate
GEMMA=gemma4:e2b
# how long ollama keeps gemma in RAM after use. "0" = unload immediately (min memory,
# slow reload each time). "30s" = warm during a dictation burst, frees ~6GB when idle.
KEEP_ALIVE="5m"

log(){ echo "$(date +%H:%M:%S) $*" >> "$LOG"; }
notify(){ notify-send -u low -t 1500 -a "Dictation" "$1" "${2:-}" 2>/dev/null || true; }

case "${1:-}" in
  toggle)
    # tap once = start, tap again = stop. Reliable on ANY key (press-only).
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      exec "$0" stop
    else
      exec "$0" start
    fi
    ;;
  start)
    [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null && exit 0
    log "START recording"
    notify "🎤 Recording…"
    pw-record --rate 16000 --channels 1 "$WAV" &
    echo $! > "$PIDFILE"
    ;;

  stop)
    [ -f "$PIDFILE" ] || { log "STOP but no pidfile (no active recording)"; exit 0; }
    REC_PID=$(cat "$PIDFILE"); rm -f "$PIDFILE"
    kill -INT "$REC_PID" 2>/dev/null
    for _ in $(seq 1 15); do kill -0 "$REC_PID" 2>/dev/null || break; sleep 0.05; done

    [ -s "$WAV" ] || { log "STOP no wav"; notify "No audio"; exit 0; }
    SZ=$(stat -c%s "$WAV"); log "STOP wav size=$SZ"
    [ "$SZ" -lt 12000 ] && { log "too short, skip"; notify "Too short"; exit 0; }

    # denoise + bandpass + normalize for cleaner ASR on noisy mics
    CLEANWAV=/tmp/ptt_clean.wav
    ffmpeg -y -i "$WAV" -af "highpass=f=100,lowpass=f=8000,afftdn=nf=-25,dynaudnorm=f=200" -ar 16000 -ac 1 "$CLEANWAV" 2>/dev/null
    [ -s "$CLEANWAV" ] || CLEANWAV="$WAV"

    # personal dictionary: bias whisper + correct misheard names to exact spellings
    DICT=~/projects/manglish/dictionary.txt
    NAMES=""
    [ -f "$DICT" ] && NAMES=$(grep -vE '^\s*$|^#' "$DICT" | paste -sd ', ')

    notify "✍️  Transcribing…"
    RAW=$("$WHISPER" -m "$MODEL" -l en -nt ${NAMES:+--prompt "$NAMES"} -f "$CLEANWAV" -t 12 2>/dev/null | tr '\n' ' ' | sed 's/^ *//; s/ *$//')
    log "RAW: $RAW"
    [ -z "$RAW" ] && { notify "Nothing heard"; exit 0; }
    # drop whisper's silence/noise hallucinations
    JUNK=$(printf '%s' "$RAW" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:][:space:]')
    case "$JUNK" in
      ""|you|thankyou|thanksforwatching|thanks|okay|ok|bye|blankaudio|youyou|so) \
        log "junk/silence -> skip"; notify "Nothing heard"; exit 0 ;;
    esac

    # personal dictionary: correct misheard names/terms to exact spellings
    SYS="You clean up dictated speech. Remove fillers (um, uh, like, you know) and false starts/repeated words. Keep the exact meaning, capitalization and punctuation. Never add, reword, translate, or explain. Output ONLY the cleaned text and nothing else."
    [ -n "$NAMES" ] && SYS="$SYS Known names/terms — if a word closely matches one of these phonetically, correct it to this exact spelling: $NAMES."

    CLEAN=$(curl -s --max-time 60 "$OLLAMA" -d "$(jq -n --arg t "$RAW" --arg m "$GEMMA" --arg k "$KEEP_ALIVE" --arg sys "$SYS" \
      '{model:$m, think:false, stream:false, keep_alive:$k,
        options:{temperature:0, num_predict:300, stop:["\nInput:","Input:"]},
        messages:[
          {role:"system",content:$sys},
          {role:"user",content:$t}
        ]}')" \
      | jq -r '.message.content // empty' | sed 's/^ *//; s/ *$//')
    [ -z "$CLEAN" ] && CLEAN="$RAW"
    log "CLEAN: $CLEAN"

    # inject — context-aware. Browsers (WhatsApp Web) ignore synthetic typing,
    # so clipboard + Ctrl+V is reliable there. Always copy first as a fallback.
    printf '%s' "$CLEAN" | wl-copy
    CLS=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' | tr '[:upper:]' '[:lower:]')
    log "target class: $CLS"
    sleep 0.1
    case "$CLS" in
      *zen*|*firefox*|*chrom*|*brave*|*navigator*|*mullvad*|*librewolf*|*vivaldi*|*edge*)
        wtype -M ctrl v -m ctrl 2>>"$LOG"; log "pasted Ctrl+V (browser)" ;;
      *kitty*|*foot*|*ghostty*|*alacritty*|*wezterm*|*konsole*|*term*)
        wtype -M ctrl -M shift v -m shift -m ctrl 2>>"$LOG"; log "pasted Ctrl+Shift+V (terminal)" ;;
      *)
        if wtype -d 1 "$CLEAN" 2>>"$LOG"; then log "wtype OK"; else wtype -M ctrl v -m ctrl 2>>"$LOG"; log "fallback Ctrl+V"; fi ;;
    esac
    notify "✅ Done" "$CLEAN"
    ;;

  *) echo "usage: $0 {start|stop}" >&2; exit 1 ;;
esac
