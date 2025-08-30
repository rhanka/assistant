// Content Script — replays inputs in the page
import type { Msg } from "./types/messages.js";

function dispatchClick(x: number, y: number, dbl = false) {
  const el = document.elementFromPoint(x, y) as HTMLElement | null;
  if (!el) return;
  el.scrollIntoView({ block: "center", inline: "center" });
  const opts = { bubbles: true, cancelable: true, clientX: x, clientY: y };
  el.dispatchEvent(new MouseEvent("mousedown", { ...opts, button: 0, buttons: 1 }));
  el.dispatchEvent(new MouseEvent("mouseup",   { ...opts, button: 0, buttons: 0 }));
  if (dbl) {
    el.dispatchEvent(new MouseEvent("dblclick", { ...opts, button: 0, detail: 2 }));
  } else {
    el.click();
  }
}

function dispatchScroll(dy: number) {
  window.scrollBy({ top: dy, behavior: "instant" as any });
}

function dispatchKey(key: string) {
  const target = (document.activeElement || document.body) as HTMLElement;
  target.dispatchEvent(new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true }));
  target.dispatchEvent(new KeyboardEvent("keyup",   { key, bubbles: true, cancelable: true }));
}

chrome.runtime.onMessage.addListener((msg: Msg) => {
  switch (msg.kind) {
    case "Click":     dispatchClick(msg.x, msg.y, false); break;
    case "DblClick":  dispatchClick(msg.x, msg.y, true);  break;
    case "Scroll":    dispatchScroll(msg.dy ?? 0);        break;
    case "Key":       dispatchKey(msg.key);               break;
    default: break;
  }
});
