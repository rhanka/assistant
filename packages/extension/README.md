# Assistant — Multi-Tab Control (MTC) — Extension (MVP)

This MV3 extension streams a target tab as **WebP** frames (2–8 fps) to a Manager page and replays basic inputs (click/scroll/keyboard).

## Build & Load
- `npm install`
- `npm run build`
- Load **Unpacked** extension from `packages/extension/dist/` in Chrome/Edge.

## Notes
- Minimal permissions. `debugger` is optional for a future “Power Mode”.
- No WebRTC in this PR; see `docs/ROADMAP-mtc-webrtc.md`.
- Works on Chromium-based browsers (Chrome, Edge).
