from celery import Celery
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get RabbitMQ URL from environment
rabbitmq_url = os.getenv('RABBITMQ_URL')

if not rabbitmq_url:
    raise ValueError("RABBITMQ_URL not found in .env file")

# Initialize Celery with RabbitMQ as broker
celery_app = Celery(
    'potsync_pipeline',
    broker=rabbitmq_url,
    backend='rpc://',  # Store results in RabbitMQ
    include=['tasks']  # Import tasks module
)

# Celery configuration
celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='Europe/London',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=600,  # 10 minutes max per task
    worker_prefetch_multiplier=1,  # Process one task at a time
    broker_connection_retry_on_startup=True,  # Retry connecting to RabbitMQ on startup
)

print(f"✅ Celery configured with broker: {rabbitmq_url}")