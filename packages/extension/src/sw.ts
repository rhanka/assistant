// Service Worker (MV3) — orchestrates sessions and offscreen lifecycle
// NOTE: Built JS will be at packages/extension/src/sw.js then copied to dist

import type { Msg } from "./types/messages.js";

type Session = {
  tabId: number;
  running: boolean;
  lastFrameTs?: number;
};

const sessions = new Map<number, Session>();

async function ensureOffscreen(): Promise<void> {
  // @ts-expect-error - chrome.offscreen types not always present in env
  const has = await chrome.offscreen?.hasDocument?.();
  if (!has) {
    await chrome.offscreen.createDocument({
      url: chrome.runtime.getURL("offscreen.html"),
      reasons: ["BLOBS"],
      justification: "Tab WebP streaming for MTC MVP"
    });
  }
}

async function maybeCloseOffscreen(): Promise<void> {
  if (sessions.size === 0) {
    try {
      await chrome.offscreen.closeDocument();
    } catch (_) { /* ignore */ }
  }
}

chrome.runtime.onMessage.addListener((msg: Msg, sender, sendResponse) => {
  (async () => {
    switch (msg.kind) {
      case "StartCapture": {
        await ensureOffscreen();
        const streamId = await chrome.tabCapture.getMediaStreamId({
          targetTabId: msg.tabId
        });
        sessions.set(msg.tabId, { tabId: msg.tabId, running: true });
        // Ask offscreen to start consuming the streamId for this tab
        await chrome.runtime.sendMessage({
          kind: "ConsumeStream",
          tabId: msg.tabId,
          streamId,
          quality: msg.quality ?? 0.6,
          fps: msg.fps ?? 2
        } as Msg);
        sendResponse({ ok: true });
        break;
      }
      case "StopCapture": {
        await chrome.runtime.sendMessage({ kind: "StopStream", tabId: msg.tabId } as Msg);
        sessions.delete(msg.tabId);
        await maybeCloseOffscreen();
        sendResponse({ ok: true });
        break;
      }
      case "FrameAck": {
        const s = sessions.get(msg.tabId);
        if (s) s.lastFrameTs = Date.now();
        break;
      }
      case "Click":
      case "DblClick":
      case "Scroll":
      case "Key": {
        // Forward input to the target tab's content-script
        await chrome.tabs.sendMessage(msg.tabId, msg);
        sendResponse({ ok: true });
        break;
      }
      default:
        break;
    }
  })();
  // Return true to indicate async sendResponse
  return true;
});

// Optional: bring a tab to the foreground
chrome.runtime.onMessage.addListener((msg: Msg) => {
  if (msg.kind === "FocusTab") {
    chrome.tabs.update(msg.tabId, { active: true });
  }
});
