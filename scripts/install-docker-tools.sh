#!/bin/bash

# Zakończ wykonanie skryptu w przypadku błędu
set -e

# Aktualizacja listy pakietów i instalacja wymaganych pakietów
echo "Aktualizacja pakietów i instalacja Docker'a oraz narzędzi..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Instalacja Docker i komponentów zakończona sukcesem."



