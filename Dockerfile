FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy project files (tests excluded via .dockerignore)
COPY . .

# Install dependencies only (not the package itself) so the app runs from /app
RUN pip install --no-cache-dir flask waitress

# Set Flask app environment variable
ENV FLASK_APP=flaskr

# Initialize the database
RUN flask init-db

# Expose the default Flask port
EXPOSE 5000

CMD ["waitress-serve", "--host=0.0.0.0", "--port=5000", "--call", "flaskr:create_app"]
