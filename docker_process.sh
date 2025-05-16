#!/bin/bash

# Konfiguration
IMAGE_NAME="nlp-processor"
CONTAINER_NAME="nlp-container"
PORT="8000"
DOCKERFILE_PATH="."  # Pfad zum Dockerfile (aktuelles Verzeichnis)

# Farben für Ausgaben
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW}      Docker Deployment für $IMAGE_NAME                ${NC}"
echo -e "${YELLOW}=====================================================${NC}"
echo ""

# 1. Prüfen, ob Docker ausgeführt wird
echo -e "${YELLOW}1. Prüfe, ob Docker läuft...${NC}"
if ! docker info >/dev/null 2>&1; then
  echo -e "${RED}Docker scheint nicht zu laufen. Bitte starte Docker und versuche es erneut.${NC}"
  exit 1
fi
echo -e "${GREEN}Docker läuft.${NC}"
echo ""

# 2. Alten Container stoppen, falls er existiert
echo -e "${YELLOW}2. Stoppe alten Container (falls vorhanden)...${NC}"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Container $CONTAINER_NAME gefunden. Wird gestoppt..."
  docker stop $CONTAINER_NAME
  echo "Container $CONTAINER_NAME wird gelöscht..."
  docker rm $CONTAINER_NAME
  echo -e "${GREEN}Alter Container gestoppt und gelöscht.${NC}"
else
  echo -e "${GREEN}Kein vorhandener Container mit Namen $CONTAINER_NAME gefunden.${NC}"
fi
echo ""

# 3. Image neu bauen
echo -e "${YELLOW}3. Baue neues Docker-Image...${NC}"
if docker build -t $IMAGE_NAME $DOCKERFILE_PATH; then
  echo -e "${GREEN}Image $IMAGE_NAME erfolgreich gebaut.${NC}"
else
  echo -e "${RED}Fehler beim Bauen des Images. Deployment abgebrochen.${NC}"
  exit 1
fi
echo ""

# 4. Neuen Container erstellen und starten
echo -e "${YELLOW}4. Starte neuen Container...${NC}"
if docker run -d -p $PORT:$PORT --name $CONTAINER_NAME $IMAGE_NAME; then
  echo -e "${GREEN}Neuer Container $CONTAINER_NAME erfolgreich gestartet.${NC}"
else
  echo -e "${RED}Fehler beim Starten des Containers. Deployment abgebrochen.${NC}"
  exit 1
fi
echo ""

# 5. Kurz warten, bis der Container bereit ist
echo -e "${YELLOW}5. Warte, bis der Container bereit ist...${NC}"
echo "   Bitte warten..."
sleep 10  # Warte 10 Sekunden, damit der Container Zeit hat, vollständig zu starten

# 6. Überprüfe, ob der Container läuft
echo -e "${YELLOW}6. Überprüfe Container-Status...${NC}"
if docker ps | grep -q $CONTAINER_NAME; then
  echo -e "${GREEN}Container $CONTAINER_NAME läuft!${NC}"
else
  echo -e "${RED}Container $CONTAINER_NAME läuft nicht. Prüfe die Logs:${NC}"
  docker logs $CONTAINER_NAME
  exit 1
fi
echo ""

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}      Deployment erfolgreich abgeschlossen!           ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo ""
echo -e "Container-Name: ${YELLOW}$CONTAINER_NAME${NC}"
echo -e "Container-Port: ${YELLOW}$PORT${NC}"
echo -e "API-Endpunkt:   ${YELLOW}http://localhost:$PORT${NC}"
echo ""
echo -e "Du kannst jetzt mit dem nächsten Skript einen Test-Request senden."
