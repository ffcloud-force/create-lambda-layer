# AWS Lambda Layer Builder

A Docker-based tool for building Python Lambda layers with the correct Linux dependencies, compatible with both ARM64 (Apple Silicon) and x86_64 development machines.

## What This Does

Creates AWS Lambda layers containing Python packages that are properly compiled for the AWS Lambda runtime environment (Linux x86_64). Ensures binary dependencies work correctly when deployed to Lambda, regardless of your local development machine's architecture.

## Prerequisites

- Docker installed and running
- Python requirements.txt file with your dependencies

## Project Structure
```
lambda_layer/
├── Dockerfile           # Docker configuration for building layers
├── create_layer.sh     # Automated build script
├── requirements.txt    # Python dependencies to include in layer
└── layers/            # Output directory (created automatically)
    └── your-layer.zip # Generated layer file
```

## Quick Start

### 1. Get the Code

```bash
git clone https://github.com/ffcloud-force/create-lambda-layer.git
cd create-lambda-layer
chmod +x create_layer.sh
```

### 2. Configure Your Layer

**Set Python Version** (in `Dockerfile`, line 1):
```dockerfile
FROM public.ecr.aws/lambda/python:3.11
```
Change `3.11` to your preferred version (`3.8`, `3.9`, `3.10`, `3.11`, `3.12`)

[View all available Python versions →](https://gallery.ecr.aws/lambda/python)

**Set Layer Name** (in `create_layer.sh`, line 7):
```bash
LAYER_NAME="your-layer-name"
```

**Add Dependencies** (in `requirements.txt`):
```
requests>=2.32.4
numpy>=1.24.0
boto3>=1.26.0
```

### 2. Build Your Layer

Run the build script:
```bash
./create_layer.sh
```

### 3. Deploy

Find your layer in `layers/your-layer-name.zip` and upload to AWS Lambda.

## Key Customization Options

| What to Customize | Where | Example |
|-------------------|-------|---------|
| **Python Version** | `Dockerfile` line 1 | `FROM public.ecr.aws/lambda/python:3.12` |
| **Layer Name** | `create_layer.sh` line 7 | `LAYER_NAME="my-custom-layer"` |
| **Dependencies** | `requirements.txt` | `pandas>=2.0.0` |
| **Package Versions** | `requirements.txt` | `requests==2.32.4` (exact) vs `requests>=2.32.4` (minimum) |

## AWS Deployment

### Via AWS Console
1. Go to Lambda → Layers → Create layer
2. Upload the zip file from `layers/`
3. Set compatible runtimes to match your Python version

### Via AWS CLI
```bash
aws lambda publish-layer-version \
  --layer-name my-python-layer \
  --zip-file fileb://layers/my-layer.zip \
  --compatible-runtimes python3.11 python3.12
```

## Architecture Compatibility

This tool automatically handles cross-compilation:
- **AWS Lambda**: Runs on Linux x86_64
- **Your Mac**: Might be ARM64 (Apple Silicon)
- **Solution**: Uses `--platform linux/amd64` for compatibility

Result: Your layer works in Lambda regardless of your development machine.

## Troubleshooting

**Empty layers folder**: Check that `requirements.txt` has valid packages and Docker build succeeded.

**Import errors in Lambda**: Ensure Python version in Dockerfile matches your Lambda function's runtime.

**Package compatibility issues**: For packages with C extensions (numpy, pandas), the cross-compilation ensures they work in Lambda.

## Tips

- Keep layers under 50MB for better performance
- Pin exact versions for production: `requests==2.32.4`
- Test layers thoroughly before production deployment
- Consider splitting large dependency sets into multiple layers

## License

MIT License