import torch
from PIL import Image
from transformers import CLIPProcessor, CLIPModel

device = "cpu"
model_id = "openai/clip-vit-large-patch14"
clip_model = CLIPModel.from_pretrained(model_id).to(device)
clip_processor = CLIPProcessor.from_pretrained(model_id)

image = Image.new('RGB', (100, 100), color = 'red')
inputs = clip_processor(images=image, return_tensors="pt").to(device)

with torch.no_grad():
    image_features = clip_model.get_image_features(**inputs)
    print("Type:", type(image_features))
    print("Attributes:", dir(image_features))
    if hasattr(image_features, 'image_embeds'):
        print("image_embeds shape:", image_features.image_embeds.shape)
    elif hasattr(image_features, 'pooler_output'):
        print("pooler_output shape:", image_features.pooler_output.shape)
    
    # Try the old way with simple model(**inputs) if there's text
    # But we don't have text. Let's see what visual_projection is.
    print("clip_model type:", type(clip_model))
