# PestiCare ML Pipeline

Offline pipeline that builds the vector index the backend searches at inference time.

## 1. Prepare the dataset

Arrange labelled leaf images as:

```
dataset/
├── Cotton/
│   ├── Bacterial Blight/
│   │   ├── img001.jpg
│   │   └── ...
│   └── Curl Virus/
├── Wheat/
│   └── ...
└── Rice/
    └── ...
```

## 2. Generate embeddings

```bash
pip install -r requirements.txt
python generate_embeddings.py
# custom dataset location:
DATASET_DIR=/path/to/dataset python generate_embeddings.py
```

Each image is encoded with CLIP ViT-L/14 into a 768-dim normalized vector and appended to `embeddings.jsonl` together with crop/disease metadata. Records are written incrementally, so a crash doesn't lose completed work.

> `embeddings.jsonl` is gitignored — it is large and fully regenerable from the dataset.

## 3. Upload to Pinecone

```bash
export PINECONE_API_KEY=your-pinecone-key
# optional: export PINECONE_INDEX_NAME=pesticare-disease-embeddings
python upload_to_pinecone.py
```

Creates the serverless index (AWS `us-east-1`, cosine metric, dim 768) if it doesn't exist and upserts all records in batches of 100.
