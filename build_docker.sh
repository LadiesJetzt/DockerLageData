docker build -t ner_service_v2_hashtag_generator .
docker ps
docker run -d -p 8000:8000 ner_service_v2_hashtag_generator ner_service_v2_hashtag_generator
docker start ner_service_v2_hashtag_generator
docker ps

