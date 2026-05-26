from flask import Flask, request, jsonify
from tasks import ppg_processing
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

@app.route('/process-measurement', methods=['POST', 'OPTIONS'])
def queue_processing():
    """
    Webhook endpoint that receives new measurement notifications
    and queues them for processing
    """
    # Handle CORS preflight
    if request.method == 'OPTIONS':
        return '', 204, {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type'
        }
    
    try:
        data = request.json
        print(f"📥 Received webhook: {data}")
        
        # Extract measurement_id from Supabase webhook
        if 'record' in data:
            # Supabase INSERT webhook format
            measurement_id = data['record'].get('measurement_id')
        else:
            # Manual trigger format
            measurement_id = data.get('measurement_id')
        
        if not measurement_id:
            return jsonify({'error': 'No measurement_id provided'}), 400
        
        # Queue the task in RabbitMQ
        task = ppg_processing.delay(measurement_id)
        
        print(f"✅ Task queued: {task.id} for measurement {measurement_id}")
        
        return jsonify({
            'status': 'queued',
            'task_id': task.id,
            'measurement_id': measurement_id
        }), 202  # 202 Accepted
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'potsync-pipeline'}), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5001))
    print(f"\n{'='*60}")
    print(f"🚀 Flask API starting on http://0.0.0.0:{port}")
    print(f"{'='*60}\n")
    app.run(host='0.0.0.0', port=port, debug=True)