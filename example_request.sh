curl -X POST \
  http://192.168.2.38:8000/ner \
  -H "Content-Type: application/json" \
  -d '{"text": "Berlin ist die Hauptstadt von Deutschland.", "hashtags": "['AAAAA']"}'