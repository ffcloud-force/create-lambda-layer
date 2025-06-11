# Use the official AWS Lambda Python runtime as the base image
FROM public.ecr.aws/lambda/python:3.11

# Set the working directory in the container
WORKDIR /app

# Install zip utility
RUN yum install -y zip && yum clean all

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the Python packages listed in requirements.txt
RUN pip install -r requirements.txt -t /opt/python/

# Override the default entrypoint and set the CMD
ENTRYPOINT []
CMD ["sh", "-c", "cd /opt && zip -r9 /app/requests-layer.zip ."]