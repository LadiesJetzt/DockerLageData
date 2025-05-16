from flask import Flask, request, jsonify
import json
import spacy

app = Flask(__name__)

nlp_xx = spacy.load('xx_sent_ud_sm')
nlp_de = spacy.load('de_core_news_sm');

app.config['MAX_CONTENT_LENGTH'] = 1024 * 1024 * 1024  # 1GB

def logg(*tt):
    with open('/var/log/ner_service.log', 'a') as log_file:
        for ttt in tt:
            log_file.writelines(ttt)

@app.route('/ner', methods=['POST'])
def process_data():
    logg(['endpoint: ner'])
    try:
        content_type = request.headers.get('Content-Type')
        if content_type == 'application/json':
            data = request.get_json(force=True)
            text_length = len(data['text'])
            hashtag_length = data['hashtags'].length
            logg('text_length: ' + str(text_length))
            logg('hashtag_length: ' + str(hashtag_length))

            res_hashtag_array = [str(text_length), str(hashtag_length)]
            return jsonify({
                'array': res_hashtag_array
            })
        else:
            raise Exception("No json")
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    import os
    from gunicorn.app.base import BaseApplication
    
    class StandaloneApplication(BaseApplication):
        def __init__(self, app, options=None):
            self.options = options or {}
            self.application = app
            super().__init__()
            
        def load_config(self):
            for key, value in self.options.items():
                if key in self.cfg.settings and value is not None:
                    self.cfg.set(key.lower(), value)
                    
        def load(self):
            return self.application
    
    options = {
        'bind': '0.0.0.0:8000',
        'workers': 4,
        'timeout': 120,  # Longer timeout for large data processing
        'worker_class': 'sync',
        'max_requests': 200,
        'max_requests_jitter': 50
    }
    
    StandaloneApplication(app, options).run()
