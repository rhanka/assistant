export type Msg =
  | { kind: "StartCapture"; tabId: number; fps?: number; quality?: number }
  | { kind: "StopCapture"; tabId: number }
  | { kind: "ConsumeStream"; tabId: number; streamId: string; fps: number; quality: number }
  | { kind: "StopStream"; tabId: number }
  | { kind: "Frame"; tabId: number; seq: number; mime: "image/webp"; dataUrl: string; ts: number }
  | { kind: "FrameAck"; tabId: number; seq: number }
  | { kind: "Click"; tabId: number; x: number; y: number }
  | { kind: "DblClick"; tabId: number; x: number; y: number }
  | { kind: "Scroll"; tabId: number; dx?: number; dy?: number }
  | { kind: "Key"; tabId: number; key: string }
  | { kind: "FocusTab"; tabId: number };
