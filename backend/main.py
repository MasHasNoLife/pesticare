import os
import io
import json
from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import torch
from PIL import Image
from transformers import CLIPProcessor, CLIPModel
from pinecone import Pinecone
from google import genai
from google.genai import types

# Load environment variables from .env file
load_dotenv()

app = FastAPI(title="PestiCare Backend API")

# Allow CORS for local testing/Flutter Web if needed
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Initialize Globals ---
device = "cuda" if torch.cuda.is_available() else "cpu"
clip_model = None
clip_processor = None
pinecone_index = None

# Using gemini-1.5-pro or gemini-2.0-flash as the standard capable models
# For speed usually gemini-1.5-flash is preferred.
gemini_client = None

@app.on_event("startup")
def startup_event():
    global clip_model, clip_processor, pinecone_index, gemini_client
    
    print("Initializing Pinecone...")
    pinecone_key = os.environ.get("PINECONE_API_KEY")
    if pinecone_key:
        pc = Pinecone(api_key=pinecone_key)
        index_name = os.environ.get("PINECONE_INDEX_NAME", "pesticare-disease-embeddings")
        pinecone_index = pc.Index(index_name)
    else:
        print("WARNING: PINECONE_API_KEY not found.")

    print("Initializing Gemini...")
    gemini_key = os.environ.get("GEMINI_API_KEY")
    if gemini_key:
        # The new SDK uses Client() explicitly.
        gemini_client = genai.Client(api_key=gemini_key)
    else:
        print("WARNING: GEMINI_API_KEY not found.")

    print(f"Loading CLIP model on {device}...")
    model_id = "openai/clip-vit-large-patch14"
    try:
        clip_model = CLIPModel.from_pretrained(model_id).to(device)
        clip_processor = CLIPProcessor.from_pretrained(model_id)
        print("Models loaded successfully.")
    except Exception as e:
        print(f"Failed to load CLIP model: {e}")

@app.get("/")
def read_root():
    return {"status": "PestiCare Backend is running!"}

@app.post("/analyze")
async def analyze_image(file: UploadFile = File(...)):
    if not clip_model or not pinecone_index or not gemini_client:
        raise HTTPException(status_code=503, detail="Server not fully initialized.")

    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")
    
    contents = await file.read()
    try:
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image format: {e}")
        
    # --- Step 1: Generate Embedding ---
    try:
        inputs = clip_processor(images=image, return_tensors="pt").to(device)
        with torch.no_grad():
            image_features = clip_model.get_image_features(**inputs)
            if not isinstance(image_features, torch.Tensor):
                if hasattr(image_features, 'pooler_output'):
                    image_features = image_features.pooler_output
                elif hasattr(image_features, 'image_embeds'):
                    image_features = image_features.image_embeds
                else:
                    image_features = image_features[0]
            
            # Normalize
            image_features = image_features / image_features.norm(dim=-1, keepdim=True)
            embedding_vector = image_features.cpu().numpy()[0].tolist()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating embedding: {e}")
        
    # --- Step 2: Query Pinecone ---
    try:
        search_result = pinecone_index.query(
            vector=embedding_vector,
            top_k=1,
            include_metadata=True
        )
        
        if not search_result.matches:
            raise HTTPException(status_code=404, detail="No similar diseases found in the database.")
            
        top_match = search_result.matches[0]
        metadata = top_match.metadata
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error querying Pinecone: {e}")
        
    # --- Step 3: Call Gemini ---
    # According to phase 2 spec:
    system_prompt = f"""
    You are an expert Agronomist. I am providing an image of a leaf and the retrieved technical data from our database.

    Retrieved Data: {metadata}

    Your Task:
    1. Verify if the symptoms in the image align with the retrieved data.
    2. Extract the 'Active Ingredient' and 'Application Rate' from the pesticide guide.
    3. Provide a clear, 3-step instruction for the farmer in simple language.

    Return the result strictly as JSON for the Flutter UI.
    Required schema:
    {{
      "crop": "string",
      "disease": "string",
      "confidence": "number (0-1, e.g., 0.95)",
      "pesticide": "string (Active Ingredient)",
      "dosage": "string (Application Rate)",
      "instructions": "string (1. 2. 3. steps)"
    }}
    """
    
    try:
        # Using the new google-genai SDK format
        response = gemini_client.models.generate_content(
            model='gemini-2.5-flash',
            contents=[
                system_prompt, 
                types.Part.from_bytes(data=contents, mime_type=file.content_type)
            ],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
            )
        )
        
        # Clean output to ensure pure JSON
        result_text = response.text.strip()
        parsed_json = json.loads(result_text)
        
        return parsed_json
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"Gemini returned invalid JSON: {response.text}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing with Gemini: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
