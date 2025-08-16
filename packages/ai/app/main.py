from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="AI Service", version="0.1.0")

class SummarizeBody(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"ok": True}

@app.post("/summarize")
def summarize(body: SummarizeBody):
    # Stub: return the first 120 chars
    txt = body.text.strip()
    return {"summary": txt[:120] + ("..." if len(txt) > 120 else "")}
