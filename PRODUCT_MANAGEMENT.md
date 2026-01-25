# Product Management

## General description of the project
Hitrace is a browser-based, real-time 1v1 reaction game for casual mobile players focused on social play. Players hit glowing tiles on a grid faster than an opponent, either via quick matchmaking or by inviting a friend to a private room. The app is implemented in Crystal using Crumble/Crumble Turbo with a SQLite-backed model layer, includes a PWA manifest, and serves static assets (fonts, icons, screenshots).

## Current set of features
- Quick match queue that pairs two waiting players into a game.
- “Play with a friend” rooms with shareable join link, ready-up flow, and room cleanup on disconnect.
- Room invite access page includes an explicit “Join” button before entering the room.
- Room invite page includes copy-to-clipboard for the invite link.
- Real-time game grid with timed target visibility, per-player color styling, and score tracking.
- Game summary screen with win/draw/abort messaging and “play again”/“back to room” actions.
- Pre-game latency check and simple latency compensation via client/server time sync; targets appear with a delay to align players.
- Leaderboard of top 5 by total wins (persisted).
- Optional player name set on home screen (defaults to “Anonymous”).
- Legal/Privacy notice pages and legal menu in UI.
- PWA manifest/icons/screenshots; empty service worker placeholder.
- Discord link and Google AdSense ad slot in layout.

## Issues on the PM scope to be tackled
- Retention: the game does not feel engaging enough for players to return without being prompted.
- No solo play: players cannot play alone, making it hard to play casually or practice.
- No community/critical mass: there is no pool of random opponents, so matchmaking is often empty.
- Monetization blocker: ad providers rejected the site for ad placement due to insufficient content.
- Account recovery gap: users lose access if cookies are deleted; no recovery path.
- Fairness/consistency under concurrency: hit registration and game creation lack explicit transactions/locking (risk of double hits or race conditions).
- Matchmaking robustness: waiting player cleanup and connection checks are time-based and may be brittle on flaky connections.
- Test coverage gap for time-based target rendering (spec marked pending after HIT-31).

## Roadmap of already planned features/changes
- Measure reaction time for each hit and show it in the game summary to increase competitiveness. (Ticket: HIT-54)
- Add transactional safety around game creation and hit registration (noted TODOs in code). (Ticket: HIT-55)
- Rich shareable invite previews. (Ticket: HIT-56)
  Context: Inviting friends is a primary growth loop, but shared links look bland and the landing lacks a clear CTA, hurting conversion and contributing to the low‑content perception by ad providers.
  Description: Add Open Graph and Twitter card metadata so room links render a preview (title, short description, thumbnail/screenshot). Create a focused invite landing page with a “Join game” CTA, a brief “How it works” blurb, and a small gameplay preview.
  Acceptance criteria:
  - Room invite URLs render a rich preview in major platforms (Discord, iMessage, Twitter/X, Slack) with correct title, description, and image.
  - The invite landing page has a visible “Join game” CTA above the fold on mobile and desktop.
  - The landing page includes a lightweight preview (static image or short loop) and a 1–2 sentence explanation.
  - No regressions in existing room join flow.
- Account binding & recovery: data model + token workflow (MVP: email magic link).
  Context: Players currently lose their identity if cookies are cleared; we need a low‑friction recovery path without forcing sign‑up.
  Description: Implement the server-side data model and token workflow for a recovery method. MVP assumes email magic‑link recovery: store a hashed email + recovery identity, generate short‑lived one‑time tokens, and validate them to restore a player identity. Include rate‑limits and clear error handling.
  Acceptance criteria:
  - A recovery identity can be created and linked to an existing player profile.
  - Recovery email is stored in a privacy‑safe way (hashed/normalized) with minimal PII.
  - One‑time tokens are time‑boxed and single‑use; expired/used tokens are rejected.
  - Rate limiting exists for token issuance (per IP and per identity).
  - Clear failure responses for invalid/expired tokens and unknown identities.
  - No changes required to play for unbound users.
- Account binding & recovery: opt‑in bind UI + consent.
  Context: Users need a clear, optional way to bind their account without feeling forced into sign‑up.
  Description: Add a “Bind account” entry on the home/ID page that explains the benefit and collects the recovery method details (MVP: email). Include explicit consent copy about what’s stored and why.
  Acceptance criteria:
  - Home/ID page includes a visible “Bind account” entry point within an Account section that also surfaces recovery actions.
  - The bind flow explains data use and is explicitly opt‑in.
  - Input validation and helpful error states for invalid email.
  - Success state confirms the bind action and next steps.
  - The game remains fully playable without binding.
- Account binding & recovery: recover flow UI.
  Context: Users need a straightforward way to restore identity after cookie loss or new device.
  Description: Add a “Recover account” entry on the home/ID page with a recovery form (MVP: email). Send a magic link and handle success/failure states to restore display name and stats.
  Acceptance criteria:
  - Home/ID page includes a visible “Recover account” entry point within the Account section that also surfaces bind actions.
  - Recovery request sends a magic link to the provided email.
  - Visiting the magic link restores the user’s identity and stats.
  - Clear success, invalid, and expired link states are shown.
  - No regressions in current name/leaderboard flows.
- Account binding & recovery: session mismatch prompt.
  Context: Some users will clear cookies accidentally and won’t notice the recover option.
  Description: Detect a “fresh cookie” state and show a subtle prompt that nudges recovery when the device has a prior bound identity hint (e.g., local storage marker).
  Acceptance criteria:
  - A fresh session triggers a non‑blocking recovery prompt when a prior bound identity hint exists.
  - The prompt is dismissible and does not block gameplay.
  - The prompt links to the “Recover account” flow.
  - No prompt is shown for users who never bound an identity.
- Account binding & recovery: unbind/logout.
  Context: Users need control over their bound recovery identity and a clean way to remove or switch it.
  Description: Provide an “Unbind” or “Log out of recovery” action that severs the recovery method from the current player identity. The flow should be explicit about consequences (e.g., loss of recovery ability) and confirm the action.
  Acceptance criteria:
  - A user can initiate an unbind/logout action from the Account section on the home/ID page (where Bind/Recover are surfaced).
  - The flow explains consequences and requires confirmation.
  - After unbinding, recovery links no longer restore the account unless re‑bound.
  - The game remains playable after unbinding.
  - Clear success and error states are shown.

## Refinement section to finalize feature descriptions
- None yet.

## Backlog of features not planned in the immediate future
- Bot opponents (quick play).
  Provide AI/bot matches when the queue is empty or after a short wait. Bots should mimic human reaction times and miss rates so matches feel plausible. Use bot difficulty tiers that scale with player performance to help retention and reduce empty matchmaking. Goal: ensure players can always get a match and reduce churn when the queue is empty.
- Connection quality indicator.
  Add a visible pre-match connection status (e.g., “Connection OK/Unstable”) based on the existing latency check, with a re-sync option before starting. Goal: make fairness/latency handling transparent and reduce frustration on flaky connections.
- Invite link QR code (shareable).
  Add a QR code generator on the invite landing page so players can quickly share and scan to join on another device. Keep it mobile-first and accessible, with a simple “Download” or “Save” option and a small caption explaining what the QR code does. Goal: reduce friction for in-person sharing and increase invite conversion without adding login steps.
- Onboarding hints (new-user tooltips).
  Show lightweight, one-time tooltips that point to the glowing targets and encourage tapping/clicking quickly. Keep it minimal (1–2 hints) and dismissible, with an option to replay via a help/info link. Goal: reduce confusion for first-time players and improve conversion to first match completion.
- Shareable match recap card.
  Generate a lightweight result card after each match (score, reaction time, win/loss) with one-tap share. Goal: improve retention and light virality, plus add content surface for ad review.
- Skill rating (MMR-lite).
  Track a hidden skill rating (e.g., Elo-like) based on win/loss and reaction-time performance, and use it to bias matchmaking and bot difficulty. Surface only broad tiers (e.g., bronze/silver/gold) or keep it fully hidden. Goal: improve fairness, reduce blowouts, and keep matches engaging.
- How‑to‑play + FAQ hub.
  Build a dedicated content section with a clear “How to play” walkthrough, short GIF/video or annotated screenshots, and a compact FAQ (latency, fairness, supported devices, privacy, troubleshooting, ad info). Keep it lightweight and mobile-first, with links surfaced from the home screen and invite landing page. This adds meaningful content depth for ad‑provider review and improves first‑time comprehension. Include versioned “last updated” stamps to signal maintenance.
- Player profile + match history pages.
  Add a public‑but‑anonymous profile page that shows a player’s display name, lifetime stats, recent match history, personal best reaction time, and streaks. Provide a private “My profile” view for the current user. Keep data minimal and privacy‑safe (no PII). This creates more persistent content for users and ads, and adds reasons to return. Optionally include shareable profile URLs.
- Release notes / updates page.
  Create a simple updates page that logs feature changes in short, user‑friendly entries (date, headline, 1–3 bullets). Link it from the footer or legal menu. Over time this becomes a growing content surface for ad providers and players, and it communicates momentum. Include a lightweight RSS/JSON feed later if needed.
- Rematch with same opponent (one-click).
  After the game summary, offer a “Rematch” option that immediately starts a new game with the same opponent without returning to the room or re‑readying. In rooms, this could optionally auto‑ready both players and start a short countdown (e.g., 3–5 seconds) with a cancel button. For random matchmaking, a rematch should only trigger if both players confirm within a short window; otherwise it falls back to normal queue. Goal: reduce friction between consecutive games and encourage repeated play sessions.
- Rotating arena variants.
  Introduce a small set of alternate grid skins/target animations that rotate daily or weekly. Goal: add freshness for retention and visible content updates for ad providers.
- Solo practice mode.
  Add a single‑player mode that runs the same timed grid without waiting for an opponent. Track score, accuracy, and reaction‑time stats, and show personal bests on the summary screen. Provide a quick “Try again” loop to encourage short practice bursts. Goal: make the game playable any time and let users warm up or play casually when no opponents are available.
- Ghost opponent (asynchronous).
  Let players race against a “ghost” run: their own best run, a friend’s run, or a curated baseline. The ghost can be represented as a timeline of target hits with a visible progress bar or shadow score that updates in real time. This preserves the competitive feel without requiring a live opponent. Goal: supply competition and bragging rights even with low concurrency.
- Daily challenge.
  Introduce a daily seeded grid pattern so everyone plays the same sequence. Show a daily leaderboard (top scores/reaction time) and personal rank. Reset daily and provide a “share your result” prompt. Goal: create a routine reason to return and a lightweight community touchpoint without requiring real‑time opponents.
- Light progression.
  Add light‑weight progression such as streaks, levels, or badges based on daily plays, total wins, or personal‑best improvements. Keep it shallow and celebratory, not grindy. Goal: increase retention by rewarding repeat sessions and improvement.
- Additional recovery methods (passkeys + device transfer).
  After the MVP email magic‑link recovery is proven, add other recovery methods such as passkeys and device‑to‑device transfer. Keep it optional and privacy‑safe, with a clear choice of methods and the ability to switch or add a backup method. Goal: reduce reliance on email and improve security/usability for repeat players.
- Seasonal leaderboard resets.
  Introduce a monthly (or bi‑weekly) season with a fresh leaderboard while retaining lifetime stats. Show the current season’s start/end dates, the user’s season rank, and a small “last season results” recap. Optionally add lightweight badges for top‑tier placement without heavy rewards. Goal: create recurring reasons to return, provide a fairer on‑ramp for new players, and add content depth for ad‑review (regular updates, visible cadence).

## Ideas already rejected
- Queue transparency & presence (players online / queue counts, wait estimates).
- Anti-cheat measures (telemetry/replay validation).

## Open questions for the team
1) None right now. Add questions here as they come up.
