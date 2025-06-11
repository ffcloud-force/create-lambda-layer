# AWS Lambda Layer Builder

A Docker-based tool for building Python Lambda layers with the correct Linux dependencies, compatible with both ARM64 (Apple Silicon) and x86_64 development machines.

## What This Does

This project creates AWS Lambda layers containing Python packages that are properly compiled for the AWS Lambda runtime environment (Linux x86_64). It ensures that binary dependencies work correctly when deployed to Lambda, regardless of your local development machine's architecture.

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ffcloud-force/create-lambda-layer.git
cd create-lambda-layer
```

### 2. Make the Script Executable

```bash
chmod +x create_layer.sh
```

## Prerequisites

- Docker installed and running
- Basic familiarity with AWS Lambda layers
- Python requirements.txt file with your dependencies

## Project Structure
lambda_layer/
├── Dockerfile # Docker configuration for building layers
├── create_layer.sh # Automated build script
├── requirements.txt # Python dependencies to include in layer
└── layers/ # Output directory (created automatically)
└── your-layer.zip # Generated layer file

## Quick Start

1. **Add your dependencies** to `requirements.txt`:
   ```
   requests>=2.32.4
   numpy>=1.24.0
   boto3>=1.26.0
   ```

2. **Update the layer name** in `create_layer.sh` (line 7):
   ```bash
   LAYER_NAME="your-layer-name"
   ```

3. **Run the build script**:
   ```bash
   ./create_layer.sh
   ```

4. **Find your layer** in the `layers/` directory:
   ```
   layers/your-layer-name.zip
   ```

## Architecture Compatibility

### Why Platform Specification Matters

- **AWS Lambda runs on**: Linux x86_64 (AMD64)
- **Your Mac might be**: ARM64 (Apple Silicon M1/M2/M3/M4)
- **Solution**: Cross-compile using `--platform linux/amd64`

This ensures that:
- ✅ Binary dependencies work in Lambda
- ✅ C extensions are compiled correctly
- ✅ Shared libraries match Lambda's environment
- ✅ No architecture mismatch errors

### For Different Development Machines

The build process automatically handles cross-compilation:
- **ARM64 Macs**: Uses `--platform linux/amd64` to build for Lambda
- **x86_64 machines**: Builds natively for the same architecture as Lambda
- **Result**: Same compatible layer regardless of your dev machine

## Detailed Usage

### Customizing Dependencies

Edit `requirements.txt` with your specific package versions:
```
# Web requests
requests>=2.32.4

# Data processing
pandas>=2.0.0
numpy>=1.24.0

# AWS services
boto3>=1.26.0
botocore>=1.29.0

# Database
psycopg2-binary>=2.9.0
```

### Customizing Layer Name

In `create_layer.sh`, change line 7:
```bash
LAYER_NAME="my-custom-layer"
```

### Manual Docker Commands

If you prefer manual control:

```bash
# Build the image
docker build --platform linux/amd64 -t lambda-layer .

# Create the layer
docker run --rm --platform linux/amd64 --entrypoint="" \
  -v "$(pwd):/app" lambda-layer \
  sh -c "cd /opt && zip -r9 /app/my-layer.zip ."

# Clean up
docker rmi lambda-layer
```

## AWS Deployment

### Upload to AWS Lambda

1. **Via AWS Console**:
   - Go to Lambda → Layers → Create layer
   - Upload the zip file from `layers/`
   - Set compatible runtimes (Python 3.11, 3.12, etc.)

2. **Via AWS CLI**:
   ```bash
   aws lambda publish-layer-version \
     --layer-name my-python-layer \
     --zip-file fileb://layers/my-layer.zip \
     --compatible-runtimes python3.11 python3.12
   ```

### Use in Lambda Function

Add the layer ARN to your Lambda function:
```python
# In your Lambda function, imports will work automatically
import requests
import numpy as np
import pandas as pd
```

## Troubleshooting

### "entrypoint requires the handler name"
**Solution**: The script uses `--entrypoint=""` to override Lambda's default entrypoint.

### "command not found: yum"
**Solution**: The Dockerfile uses Python 3.11 base image which includes `yum`. Newer versions might need `microdnf`.

### Empty layers folder
**Possible causes**:
- Requirements.txt is empty or invalid
- Docker build failed (check output)
- Permission issues with volume mounting

**Debug steps**:
```bash
# Test the container interactively
docker run --rm -it --platform linux/amd64 \
  --entrypoint="" -v "$(pwd):/app" lambda-layer /bin/bash

# Inside container, check what was installed
ls -la /opt/python/
```

### Package compatibility issues
**For packages with C extensions** (numpy, pandas, psycopg2, etc.):
- Always use `--platform linux/amd64`
- Consider using `-binary` versions when available (e.g., `psycopg2-binary`)
- Check package documentation for Lambda-specific instructions

## Tips and Best Practices

### Layer Size Optimization
- Keep layers under 50MB when unzipped for better cold start performance
- Split large dependency sets into multiple layers
- Use `pip install --no-deps` if you want to exclude transitive dependencies

### Version Pinning
- Pin exact versions in production: `requests==2.32.4`
- Use `>=` for development flexibility
- Test layers thoroughly before deploying to production

### Multiple Layers Strategy
For large projects, consider splitting dependencies:
```bash
# Layer 1: Core utilities
LAYER_NAME="core-utils"  # requests, boto3

# Layer 2: Data processing
LAYER_NAME="data-processing"  # pandas, numpy

# Layer 3: ML libraries
LAYER_NAME="ml-libs"  # scikit-learn, tensorflow
```

## Contributing

1. Fork the repository
2. Make your changes
3. Test with different package combinations
4. Submit a pull request

## License

This project is open source and available under the MIT License.