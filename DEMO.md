# Signet — Gemma 4 Day demo cheat-sheet

PRE-FLIGHT (run once before you present):
  signet warm     # loads Parakeet + Gemma 4
  signet doctor   # all green?
Open a TEXT EDITOR (gnome-text-editor / obsidian) — NOT a terminal (terminal = code mode, no bullets).

ONE-LINER:
  "Signet is Wispr Flow, but free, open-source, and fully local — Gemma 4 does all the
   thinking on a CPU laptop. Your voice never leaves the machine. No cloud, no subscription."

WHY GEMMA 4: Parakeet just hears you. **Gemma 4 (e2b) is the brain** — it fixes grammar,
auto-formats lists, formats numbers/dates, matches tone to the app, edits on command, and
translates. All on-device, on a Ryzen CPU, no GPU. That's Gemma 4's on-device promise, live.

------- LIVE DEMO (hold F9, speak, release) -------

1) MESSY -> CLEAN (grammar + fillers)
   say: "um so me and him was gonna ship it tomorrow you know but we was late"
   -> "He and I were going to ship it tomorrow, but we were late."

2) AUTO-BULLETS (the wow)
   say: "i need to buy milk eggs bread and coffee tomorrow"
   -> a bullet list, with "tomorrow" on its own line

3) NUMBERS / DATES / MONEY
   say: "lets meet at three pm on june twenty it costs twenty dollars"
   -> "Let's meet at 3 PM on June 20, and it costs $20."

4) COMMAND MODE (Gemma edits selected text) — select a sentence first, hold F10
   selected: "hey i think we should maybe do this"   say: "make this formal"

5) TRANSLATE — hold F11
   say (any language): "hola, como estas"  -> English

6) UNDO — tap Super+Backspace right after a dictation -> removes it

7) THE MIC-DROP: turn OFF wifi, repeat demo #1. Still works. 100% local.

CLOSE: "Free, unlimited, open-source (github.com/Edneam/signet), runs on any Linux laptop.
        Gemma 4 made on-device voice actually good."
