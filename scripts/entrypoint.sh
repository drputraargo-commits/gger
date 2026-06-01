#!/bin/bash

set -e  # Exit on error

echo "=== SageMaker Neo Compilation Job Started ==="
echo "Job Name: $SAGEMAKER_JOB_NAME"
echo "Current Time: $(date)"

# ============ PREPROCESSING ============
echo -e "\n📋 Step 1: Running Preprocessing..."
source /opt/scripts/preprocess.sh

if [ $? -eq 0 ]; then
    echo "✅ Preprocessing completed successfully"
else
    echo "❌ Preprocessing failed"
    exit 1
fi

# ============ COMPILATION ============
echo -e "\n🔧 Step 2: Running Model Compilation with Neo..."

python3 << 'EOF'
import os
import json
import boto3
from sagemaker.tensorflow.model import TensorFlowModel
from sagemaker.model import Model

# Read compilation config
with open('/opt/app/compilation_config.json', 'r') as f:
    config = json.load(f)

print("Compilation Config:", config)

# Initialize SageMaker session
import sagemaker
session = sagemaker.Session()
role = os.environ.get('SAGEMAKER_ROLE_ARN', 'arn:aws:iam::' + 
    boto3.client('sts').get_caller_identity()['Account'] + ':role/SageMakerRole')

# Model input config
input_model = config['input_model']
framework = config['framework']
framework_version = config['framework_version']
target_device = config['target_device']
output_path = config['output_path']
input_shape = config['input_shape']

print(f"Model: {input_model}")
print(f"Framework: {framework} {framework_version}")
print(f"Target Device: {target_device}")

# Compilation job name
job_name = f"neo-compilation-{int(time.time())}"

# Run compilation
if framework.upper() == "TENSORFLOW":
    model = TensorFlowModel(
        model_data=input_model,
        framework_version=framework_version,
        role=role,
        sagemaker_session=session
    )
elif framework.upper() == "PYTORCH":
    # Adjust for PyTorch if needed
    pass

# Compile model
compiled_model_data = model.compile(
    target_instance_family=target_device,
    input_shape=json.loads(input_shape),
    output_path=output_path,
    framework=framework.lower(),
    framework_version=framework_version,
    job_name=job_name
)

print(f"✅ Compilation completed!")
print(f"Output location: {compiled_model_data}")

EOF

if [ $? -eq 0 ]; then
    echo "✅ Compilation job submitted successfully"
else
    echo "❌ Compilation failed"
    exit 1
fi

# ============ POSTPROCESSING ============
echo -e "\n📤 Step 3: Running Postprocessing..."
source /opt/scripts/postprocess.sh

if [ $? -eq 0 ]; then
    echo "✅ Postprocessing completed successfully"
else
    echo "❌ Postprocessing failed"
    exit 1
fi

echo -e "\n=== ✅ All steps completed successfully! ==="
echo "Completion Time: $(date)"
