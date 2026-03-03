import os
import json
import torch
from PIL import Image
from transformers import CLIPProcessor, CLIPModel
from tqdm import tqdm

def main():
    print("Loading CLIP model (openai/clip-vit-large-patch14)...")
    model_id = "openai/clip-vit-large-patch14"
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Using device: {device}")
    
    try:
        model = CLIPModel.from_pretrained(model_id).to(device)
        processor = CLIPProcessor.from_pretrained(model_id)
        print("Model loaded successfully.")
    except Exception as e:
        print(f"Error loading model: {e}")
        return

    base_dir = r"c:\fyp\pesticare\dataset"
    output_file = "embeddings.jsonl"
    
    processed_ids = set()
    print("Clearing previous embeddings.jsonl to restart from scratch.")
    with open(output_file, 'w') as f:
        pass # Create/clear file
    
    # Iterate through dataset
    if not os.path.exists(base_dir):
        print(f"Dataset directory not found: {base_dir}")
        return

    processed_this_run = 0
    for crop in os.listdir(base_dir):
        crop_path = os.path.join(base_dir, crop)
        if not os.path.isdir(crop_path):
            continue
            
        for disease in os.listdir(crop_path):
            disease_path = os.path.join(crop_path, disease)
            if not os.path.isdir(disease_path):
                continue
                
            print(f"Processing {crop} - {disease}...")
            image_files = [f for f in os.listdir(disease_path) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
            
            for img_file in tqdm(image_files, desc=f"{crop}/{disease}"):
                vector_id = f"{crop}_{disease.replace(' ', '_')}_{img_file}".replace(".", "_")
                
                # Skip if already processed
                if vector_id in processed_ids:
                    continue
                    
                img_path = os.path.join(disease_path, img_file)
                try:
                    image = Image.open(img_path).convert("RGB")
                    inputs = processor(images=image, return_tensors="pt").to(device)
                    
                    with torch.no_grad():
                        image_features = model.get_image_features(**inputs)
                        if not isinstance(image_features, torch.Tensor):
                            if hasattr(image_features, 'pooler_output'):
                                image_features = image_features.pooler_output
                            elif hasattr(image_features, 'image_embeds'):
                                image_features = image_features.image_embeds
                            else:
                                image_features = image_features[0]
                        
                    # Normalize the features for cosine similarity
                    image_features = image_features / image_features.norm(dim=-1, keepdim=True)
                    embedding_vector = image_features.cpu().numpy()[0].tolist()
                    
                    record = {
                        "id": vector_id,
                        "values": embedding_vector,
                        "metadata": {
                            "crop": crop,
                            "disease": disease,
                            "description": f"An observation from the dataset showing a {crop} crop affected by {disease}.",
                            "file_name": img_file,
                            "path": img_path
                        }
                    }
                    
                    # Append immediately to avoid data loss on crash
                    with open(output_file, 'a') as f:
                        f.write(json.dumps(record) + '\n')
                        
                    processed_ids.add(vector_id)
                    processed_this_run += 1
                    
                except Exception as e:
                    print(f"Error processing {img_path}: {e}")
                    
    print(f"Embedding generation complete! Processed {processed_this_run} new images in this run.")

if __name__ == "__main__":
    main()
