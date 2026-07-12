# PestiCare Backend

FastAPI inference server implementing the diagnosis pipeline: **CLIP embedding → Pinecone retrieval → Gemini verification**.

## How it works

`POST /analyze` receives a leaf image and target language, then:

1. **Embed** — the image is encoded with `openai/clip-vit-large-patch14` (768-dim, L2-normalized). Runs on CUDA when available, otherwise CPU.
2. **Retrieve** — the embedding queries the Pinecone index (cosine similarity, `top_k=1`) for the closest disease record and its treatment metadata.
3. **Verify & generate** — Gemini 2.5 Flash gets the *original image* plus the retrieved metadata, checks that the visual symptoms actually match, and returns a strict-JSON diagnosis (disease, confidence, pesticide, dosage, instructions, local equivalent) translated into the requested language.

Grounding Gemini in retrieved data instead of asking it to diagnose freely keeps answers consistent with the curated dataset.

## Setup

```bash
python -m venv venv && source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                               # fill in your keys
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Environment variables

| Variable              | Description                                    |
|-----------------------|------------------------------------------------|
| `PINECONE_API_KEY`    | Pinecone API key                               |
| `PINECONE_INDEX_NAME` | Index name (default `pesticare-disease-embeddings`) |
| `GEMINI_API_KEY`      | Google Gemini API key                          |

The index must be populated first — see [`../ml_pipeline/`](../ml_pipeline/).

## Endpoints

| Method | Path       | Description                                        |
|--------|------------|----------------------------------------------------|
| GET    | `/`        | Health check                                       |
| POST   | `/analyze` | Multipart `file` (image) + `language` (`en`/`ur`) → diagnosis JSON |

Interactive docs at `http://localhost:8000/docs` once running.

## Smoke test

With the server running:

```bash
python test_request.py
```
