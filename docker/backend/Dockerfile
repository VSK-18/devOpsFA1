FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements if any (none for now)
# Install Flask
RUN pip install flask

# Copy application code
COPY app.py .

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]