from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="AI Service", version="0.1.0")

class SummarizeBody(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/")
def root():
    return {"message": "AI Service is running"}

@app.post("/summarize")
def summarize(body: SummarizeBody):
    # Validate input
    if not body.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    # Stub: return the first 120 chars
    txt = body.text.strip()
    summary = txt[:120] + ("..." if len(txt) > 120 else "")
    
    return {
        "summary": summary,
        "length": len(txt)
    }
