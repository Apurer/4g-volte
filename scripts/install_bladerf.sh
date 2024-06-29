#!/bin/bash

# Skrypt instalacyjny dla BladeRF

# Zakończ wykonanie skryptu w przypadku błędu
set -e

# Dodaj repozytorium BladeRF
echo "Dodawanie repozytorium BladeRF..."
sudo add-apt-repository ppa:nuandllc/bladerf -y

# Aktualizuj listę pakietów
echo "Aktualizacja listy pakietów..."
sudo apt-get update

# Instaluj BladeRF
echo "Instalacja BladeRF..."
sudo apt-get install bladerf -y

echo "Instalacja zakończona pomyślnie!"