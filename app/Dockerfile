# Select image
FROM python:3.9-slim

# Set work dir
WORKDIR /app

#Copy requirements first for layered caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the python flask app files
COPY . .

# Expose port for running the web app
EXPOSE 5000

#Run the flask app with python command "python app.py"
CMD ["python", "app.py"]
