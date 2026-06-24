# ♞ Speed Chess Trainer

A Flutter app that helps you get **better at speed chess**. Spar against a
configurable computer opponent — including a roster of historic chess legends
with personality profiles estimated from their real playing styles — ask for
hints, customise your clocks and themes, and rewind every game to learn from it.

The app builds for **iOS / Android** and for the **web**, so it can be hosted on
**Vercel** (see [Deploying to Vercel](#deploying-to-vercel)).

---

## Features

- **2D top-down board** with tap-to-move, legal-move dots, last-move and
  in-check highlighting, board coordinates and pawn-promotion selection.
- **Configurable computer opponent** built on a self-contained negamax engine
  (alpha-beta pruning + material / piece-square-table evaluation). No external
  engine binary required, so it runs anywhere — including the web.
- **Ask for a suggestion (hint):** the engine highlights the best move it can
  find, so you can learn its idea and then try to beat it.
- **Difficulty levels** (Beginner → Master) with tunable search depth, think
  time and blunder rate.
- **Personalities** — every opponent has three sliders you can fine-tune:
  - **Aggression** — how much it values attacks, captures and king pressure.
  - **Risk taking** — willingness to enter sharp / speculative lines.
  - **Carelessness** — how often it makes a human-like mistake.
- **Historic chess legends** with estimated personality configurations
  (Tal, Morphy, Capablanca, Petrosian, Fischer, Kasparov, Karpov, Carlsen,
  Nakamura, Lasker — plus the deliberately blunder-prone "Careless Carl").
- **Speed-chess clocks:** Bullet / Blitz / Rapid presets *and* a fully custom
  base-time + increment control. Low-time warning with tenths-of-a-second.
- **Move history with full rewind:** step through every move, jump to any ply,
  or return to the live position.
- **Themes:** light / dark / system app themes, eight accent colours and six
  board palettes (Tournament Green, Walnut Wood, Ocean Blue, Slate Grey,
  Midnight, Candy).
- **Persistent settings** via `shared_preferences`.

---

## Running locally

Prerequisites: [Flutter](https://docs.flutter.dev/get-started/install) 3.27+.

```bash
flutter pub get

# Mobile (with a device/emulator attached)
flutter run

# Web
flutter run -d chrome
```

Run the tests:

```bash
flutter test
```

---

## Deploying to Vercel

Flutter compiles to a static web bundle, which Vercel can host. Because
Vercel's build image doesn't ship Flutter, [`vercel_build.sh`](./vercel_build.sh)
fetches a pinned stable SDK at build time and produces `build/web`.

The repo already includes [`vercel.json`](./vercel.json):

```json
{
  "buildCommand": "bash vercel_build.sh",
  "outputDirectory": "build/web",
  "framework": null,
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

To deploy:

1. Push this repository to GitHub.
2. In Vercel, **New Project → Import** the repo. Leave the framework preset as
   *Other* — `vercel.json` supplies the build command and output directory.
3. Deploy. The first build is slower because it clones the Flutter SDK;
   subsequent builds reuse the cached `.flutter-sdk` directory where possible.

> Tip: you can pin a specific Flutter version by setting the `FLUTTER_VERSION`
> environment variable in the Vercel project (defaults to `stable`).

Alternatively, build locally and deploy the static output directly:

```bash
flutter build web --release
vercel deploy --prebuilt build/web   # or drag-and-drop build/web in the dashboard
```

---

## Project structure

```
lib/
  main.dart                 App entry point, providers & MaterialApp theming
  engine/
    chess_ai.dart           Negamax + alpha-beta engine, PSTs, personality bias
  models/
    personality.dart        Aggression / risk / carelessness / strength
    opponent.dart           Difficulty levels + historic-player roster
    time_control.dart       Bullet/Blitz/Rapid presets + custom
    board_theme.dart        Board colour palettes
  state/
    settings_provider.dart  Persisted preferences (theme, board, time, opponent)
    game_provider.dart      Board, clocks, move history/rewind, AI orchestration
  screens/
    home_screen.dart        Quick-start: opponent, time, side, tips
    game_screen.dart        Board, clocks, captured pieces, controls, history
    opponent_select_screen.dart   Pick & customise opponents
    settings_screen.dart    Time, themes, board, gameplay toggles
  widgets/
    chess_board_widget.dart 2D board, selection, highlights, promotion
    clock_widget.dart       Countdown clock
    move_history.dart       Tappable move list with rewind
    captured_pieces.dart    Captured pieces + material advantage
  utils/
    piece_glyphs.dart       Unicode piece glyphs (no image assets needed)
  theme/
    app_themes.dart         Light/dark ThemeData from a seed colour
web/                        Web bootstrap (index.html, manifest.json)
vercel.json, vercel_build.sh   Vercel hosting config
```

---

## How the engine & personalities work

The engine runs a shallow **negamax search with alpha-beta pruning** over a
classic evaluation (material values + piece-square tables). On top of the raw
search, each opponent's `Personality` shapes **move selection**:

- **Aggression** adds king-tropism to the evaluation (pieces are rewarded for
  crowding the enemy king) and bonuses for captures and checks.
- **Risk taking** widens the pool of near-best moves the engine will randomly
  pick from, producing livelier, less predictable play.
- **Carelessness** is the probability of deliberately choosing a worse move —
  a simple model of human error that makes lower levels beatable and gives
  "Careless Carl" his charm.
- **Search depth** and **think time** set raw strength and pace (kept shallow so
  it stays responsive on phones and in the browser).

> **Disclaimer on historic players:** the personality numbers are *subjective
> estimates* meant to evoke each champion's well-known style (e.g. Tal's
> sacrifices, Petrosian's prophylaxis, Capablanca's clean technique). They are
> for fun and training flavour — not a literal model of any individual's play.
