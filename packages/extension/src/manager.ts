import type { Msg } from "./types/messages.js";

const $ = <T extends HTMLElement>(sel: string) => document.querySelector(sel) as T;

const elTabId   = $("#tabId")  as HTMLInputElement;
const elPreview = $("#preview") as HTMLImageElement;
const elStatus  = $("#status")  as HTMLSpanElement;
const elMeta    = $("#meta")    as HTMLSpanElement;
const elFps     = $("#fps")     as HTMLInputElement;
const elQual    = $("#quality") as HTMLInputElement;

$("#btnPick")!.addEventListener("click", async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (tab?.id) elTabId.value = String(tab.id);
});

$("#btnFocus")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "FocusTab", tabId } as Msg);
});

$("#btnStart")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  const fps = Number(elFps.value || 2);
  const quality = Number(elQual.value || 0.6);
  await chrome.runtime.sendMessage({ kind: "StartCapture", tabId, fps, quality } as Msg);
  elStatus.textContent = `capturing (fps=${fps}, q=${quality})`;
});

$("#btnStop")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "StopCapture", tabId } as Msg);
  elStatus.textContent = "idle";
  elPreview.src = "";
  elMeta.textContent = "—";
});

// Simple demo input controls (send to content-script)
$("#btnClick")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "Click", tabId, x: 200, y: 200 } as Msg);
});
$("#btnDblClick")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "DblClick", tabId, x: 200, y: 200 } as Msg);
});
$("#btnScrollDown")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "Scroll", tabId, dy: 300 } as Msg);
});
$("#btnScrollUp")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "Scroll", tabId, dy: -300 } as Msg);
});
$("#btnKey")!.addEventListener("click", async () => {
  const tabId = Number(elTabId.value);
  const key = (document.querySelector("#keyText") as HTMLInputElement).value || "Enter";
  if (!tabId) return;
  await chrome.runtime.sendMessage({ kind: "Key", tabId, key } as Msg);
});

// Receive frames from offscreen
chrome.runtime.onMessage.addListener((msg: Msg) => {
  if (msg.kind === "Frame") {
    elPreview.src = msg.dataUrl;
    elMeta.textContent = `seq=${msg.seq} ts=${new Date(msg.ts).toLocaleTimeString()} mime=${msg.mime}`;
    // Acknowledge back (optional)
    chrome.runtime.sendMessage({ kind: "FrameAck", tabId: msg.tabId, seq: msg.seq } as Msg);
  }
});
