#!/bin/bash

echo "Starting postprocessing..."

# Run Python postprocessing
python3 /opt/src/postprocess_model.py \
    --input /opt/app/model_compiled \
    --output /opt/app/final_model

# Compress output
echo "Compressing compiled model..."
tar -czf /opt/app/final_model.tar.gz -C /opt/app final_model/

# Upload to S3
OUTPUT_S3_PATH="${OUTPUT_S3_PATH:-s3://my-bucket/compiled-models/}"
echo "Uploading to: $OUTPUT_S3_PATH"
aws s3 cp /opt/app/final_model.tar.gz "$OUTPUT_S3_PATH"

echo "✅ Postprocessing done!"
return 0
