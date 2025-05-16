#!/bin/bash

# Titel-Banner anzeigen
echo "======================================================"
echo "      Docker Komplette Bereinigung                    "
echo "      WARNUNG: Löscht ALLES in Docker                 "
echo "======================================================"
echo ""

# Prüfen, ob Docker ausgeführt wird
echo "Prüfe, ob Docker läuft..."
if ! docker info >/dev/null 2>&1; then
  echo "Docker scheint nicht zu laufen. Bitte starte Docker und versuche es erneut."
  exit 1
fi

# Bestätigung vom Benutzer anfordern
echo "WARNUNG: Dieses Skript wird Folgendes löschen:"
echo "  - Alle laufenden und gestoppten Container"
echo "  - Alle Docker Volumes"
echo "  - Alle Docker Images"
echo "  - Alle Docker Netzwerke"
echo ""
echo "Diese Aktion kann NICHT rückgängig gemacht werden!"
echo ""
read -p "Möchtest du wirklich fortfahren? (j/n): " CONFIRM

if [[ "$CONFIRM" != "j" && "$CONFIRM" != "J" ]]; then
  echo "Bereinigung abgebrochen."
  exit 0
fi

# Stoppen aller laufenden Container
echo ""
echo "1. Stoppe alle laufenden Container..."
RUNNING_CONTAINERS=$(docker ps -q)
if [ -n "$RUNNING_CONTAINERS" ]; then
  docker stop $RUNNING_CONTAINERS
  echo "   Alle Container gestoppt."
else
  echo "   Keine laufenden Container gefunden."
fi

# Lösche alle Container
echo ""
echo "2. Lösche alle Container..."
ALL_CONTAINERS=$(docker ps -a -q)
if [ -n "$ALL_CONTAINERS" ]; then
  docker rm -f $ALL_CONTAINERS
  echo "   Alle Container wurden gelöscht."
else
  echo "   Keine Container gefunden."
fi

# Lösche alle Volumes
echo ""
echo "3. Lösche alle Volumes..."
VOLUMES=$(docker volume ls -q)
if [ -n "$VOLUMES" ]; then
  docker volume rm $VOLUMES
  echo "   Alle Volumes wurden gelöscht."
else
  echo "   Keine Volumes gefunden."
fi

# Lösche alle Netzwerke (außer die Standard-Netzwerke)
echo ""
echo "4. Lösche alle benutzerdefinierten Netzwerke..."
NETWORKS=$(docker network ls | grep -v "bridge\|host\|none" | awk '{print $1}')
if [ -n "$NETWORKS" ]; then
  docker network rm $NETWORKS
  echo "   Alle benutzerdefinierten Netzwerke wurden gelöscht."
else
  echo "   Keine benutzerdefinierten Netzwerke gefunden."
fi

# Lösche alle Images
echo ""
echo "5. Lösche alle Images..."
IMAGES=$(docker images -q)
if [ -n "$IMAGES" ]; then
  docker rmi -f $IMAGES
  echo "   Alle Images wurden gelöscht."
else
  echo "   Keine Images gefunden."
fi

# Bereinige verbleibende Ressourcen
echo ""
echo "6. Bereinige verbleibende Ressourcen..."
docker system prune -a -f --volumes
echo "   Bereinigung abgeschlossen."

echo ""
echo "======================================================"
echo "      Docker Bereinigung abgeschlossen                "
echo "======================================================"
echo ""
echo "Alle Container, Volumes, Netzwerke und Images wurden gelöscht."
echo "Dein Docker-System ist jetzt komplett bereinigt."