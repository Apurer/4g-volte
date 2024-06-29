#!/bin/bash

# Ustaw tryb automatycznego eksportowania zmiennych środowiskowych
set -a

# Załaduj zmienne środowiskowe z pliku .env
source .env

# Wyłącz zaporę sieciową
sudo ufw disable

# Włącz przekazywanie pakietów IP
sudo sysctl -w net.ipv4.ip_forward=1

# Ustaw tryb zarządzania energią procesora na "performance"
sudo cpupower frequency-set -g performance



