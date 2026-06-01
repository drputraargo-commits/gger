#!/bin/bash

echo "Starting model preprocessing..."

# Download model from S3 jika ada
MODEL_S3_PATH="${MODEL_S3_PATH:-s3://my-bucket/models/model.tar.gz}"
LOCAL_MODEL_PATH="/opt/app/model.tar.gz"

if [ ! -z "$MODEL_S3_PATH" ]; then
    echo "Downloading model from: $MODEL_S3_PATH"
    aws s3 cp "$MODEL_S3_PATH" "$LOCAL_MODEL_PATH"
fi

# Extract model
echo "Extracting model..."
cd /opt/app
tar -xzf model.tar.gz -C .

# Run Python preprocessing
echo "Running Python preprocessing scripts..."
python3 /opt/src/preprocess_model.py \
    --input /opt/app/model \
    --output /opt/app/model_processed \
    --config /opt/app/compilation_config.json

echo "✅ Preprocessing done!"
return 0
