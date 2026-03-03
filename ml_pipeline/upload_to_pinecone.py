import os
import json
from pinecone import Pinecone, ServerlessSpec
from tqdm import tqdm

# Constants
PINECONE_API_KEY = ""
INDEX_NAME = "pesticare-disease-embeddings"
DIMENSION = 768 # openai/clip-vit-large-patch14 has 768 dimensions

def main():
    print("Initializing Pinecone client...")
    try:
        pc = Pinecone(api_key=PINECONE_API_KEY)
    except Exception as e:
        print(f"Error initializing Pinecone: {e}")
        return
    
    # Check if index exists or create it
    existing_indexes = [index_info["name"] for index_info in pc.list_indexes()]
    if INDEX_NAME not in existing_indexes:
        print(f"Creating index '{INDEX_NAME}'...")
        try:
            pc.create_index(
                name=INDEX_NAME,
                dimension=DIMENSION,
                metric="cosine", # Cosine similarity is typically used for CLIP features
                spec=ServerlessSpec(
                    cloud="aws",
                    region="us-east-1"
                )
            )
            print("Index created.")
        except Exception as e:
            print(f"Error creating index: {e}")
            return
    else:
        print(f"Index '{INDEX_NAME}' already exists.")
        
    index = pc.Index(INDEX_NAME)
    
    # Read embeddings
    input_file = "embeddings.jsonl"
    print(f"Reading embeddings from {input_file}...")
    records = []
    if not os.path.exists(input_file):
        print(f"File not found: {input_file}. Please run generate_embeddings.py first.")
        return
        
    with open(input_file, 'r') as f:
        for line in f:
            records.append(json.loads(line.strip()))
            
    print(f"Loaded {len(records)} records.")
    
    if len(records) == 0:
        print("No records found to upload.")
        return
        
    # Upsert in batches of 100
    batch_size = 100
    print("Upserting records to Pinecone...")
    try:
        for i in tqdm(range(0, len(records), batch_size)):
            batch = records[i:i+batch_size]
            index.upsert(vectors=batch)
        print("Upload complete!")
    except Exception as e:
        print(f"Error upserting vectors: {e}")

if __name__ == "__main__":
    main()
