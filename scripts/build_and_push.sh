#!/bin/bash

# Skrypt do klonowania repozytorium i budowania obrazów Docker z wieloma architekturami

# Klonowanie repozytorium z GitHub
git clone https://github.com/Apurer/4g-volte.git

# Przejście do katalogu repozytorium
cd 4g-volte

# Budowanie obrazów Docker dla różnych komponentów 4G z VoLTE i wypchnięcie ich do GitHub Container Registry
# Obrazy są budowane dla platform linux/amd64 i linux/arm64, a następnie wypychane do rejestru
./base docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/open5gs:1.0 --push .
./ims_base docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/kamailio:1.0 --push .
./srslte docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/srslte:1.0 --push .
./dns docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/dns:1.0 --push .
./rtpengine docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/rtpengine:1.0 --push .
./mysql docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/mysql:1.0 --push .
./pyhss docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/pyhss:1.0 --push .
./osmomsc docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/osmomsc:1.0 --push .
./osmohlr docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/apurer/osmohlr:1.0 --push .

