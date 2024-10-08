#!/bin/bash

# Zakończ wykonanie skryptu w przypadku błędu
set -e

# Krok 1: Dodaj oficjalny klucz GPG Docker'a
echo "Aktualizacja pakietów i instalacja wymaganych pakietów..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl

echo "Tworzenie katalogu keyrings i dodawanie klucza GPG Docker'a..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Krok 2: Dodaj repozytorium Docker do źródeł APT
echo "Dodawanie repozytorium Docker do źródeł APT..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Aktualizacja listy pakietów..."
sudo apt-get update

echo "Konfiguracja repozytorium Docker zakończona."
