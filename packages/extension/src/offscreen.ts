// Offscreen Document — consumes streamId, encodes WebP frames, sends to Manager
import type { Msg } from "./types/messages.js";

type StreamState = {
  tabId: number;
  stream: MediaStream;
  video: HTMLVideoElement;
  canvas: HTMLCanvasElement;
  ctx: CanvasRenderingContext2D;
  timer?: number;
  fps: number;
  quality: number;
  seq: number;
};

const states = new Map<number, StreamState>();

async function start(tabId: number, streamId: string, fps: number, quality: number) {
  // @ts-expect-error: mandatory constraints are Chromium-specific
  const stream = await navigator.mediaDevices.getUserMedia({
    video: { mandatory: { chromeMediaSource: "tab", chromeMediaSourceId: streamId } },
    audio: false
  } as any);

  const video = document.createElement("video");
  video.srcObject = stream;
  await video.play();

  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d", { willReadFrequently: false })!;
  const st: StreamState = { tabId, stream, video, canvas, ctx, fps, quality, seq: 0 };
  states.set(tabId, st);

  const tick = async () => {
    if (video.videoWidth === 0 || video.videoHeight === 0) return;
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    const blob: Blob = await new Promise((res) => canvas.toBlob((b) => res(b!), "image/webp", quality));
    const dataUrl = await blobToDataUrl(blob);
    const msg: Msg = {
      kind: "Frame",
      tabId,
      seq: st.seq++,
      mime: "image/webp",
      dataUrl,
      ts: Date.now()
    };
    await chrome.runtime.sendMessage(msg);
  };

  st.timer = self.setInterval(tick, Math.max(1000 / fps, 50));
}

async function stop(tabId: number) {
  const st = states.get(tabId);
  if (!st) return;
  if (st.timer) clearInterval(st.timer);
  st.stream.getTracks().forEach(t => t.stop());
  states.delete(tabId);
}

function blobToDataUrl(blob: Blob): Promise<string> {
  return new Promise((res) => {
    const r = new FileReader();
    r.onload = () => res(String(r.result));
    r.readAsDataURL(blob);
  });
}

chrome.runtime.onMessage.addListener((msg: Msg) => {
  if (msg.kind === "ConsumeStream") {
    start(msg.tabId, msg.streamId, msg.fps, msg.quality);
  } else if (msg.kind === "StopStream") {
    stop(msg.tabId);
  }
});
