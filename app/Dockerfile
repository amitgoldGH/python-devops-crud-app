# Select image
FROM python:3.9-slim

# Set work dir
WORKDIR /

#Copy requirements first for layered caching
COPY ./app/requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the python flask app files
COPY ./app /app

# Expose port for running the web app
EXPOSE 5000

#Run the flask app with python command "python app.py"
CMD ["python", "-m", "app.app"]
