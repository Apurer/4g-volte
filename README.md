## Przetestowana konfiguracja

Docker host machine

- Ubuntu 22.04

Konfiguracje Over-The-Air:

- srsRAN eNB korzystający z Nuand bladeRF 2.0 micro xA4

## Budowanie obrazów Docker

* Wymagania obowiązkowe:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu) - wersja 22.0.5 lub wyższa
	* [docker compose](https://docs.docker.com/compose) - wersja 2.14 lub wyższa

#### Nadawanie uprawnień na skryptach shell

```
chmod +x setup-docker.sh
chmod +x install-docker-tools.sh
chmod +x install_bladerf.sh
chmod +x configure_host.sh
chmod +x find_veth_docker.sh
```

#### Konfiguracja Dockera. Uruchom ten skrypt, aby skonfigurować środowisko Docker na systemie. 

```
./setup-docker.sh
```

#### Instalacja Narzędzi Docker. Ten skrypt zainstaluje dodatkowe narzędzia potrzebne do zarządzania Dockerem i jego kontenerami.

```
./install-docker-tools.sh
```

#### Instalacja narzędzi BladeRF. Użyj tego skryptu, aby zainstalować narzędzia BladeRF, które są wymagane do operacji związanych z BladeRF.

```
./install_bladerf.sh
```

#### W celu weryfikacji poprawności instalacji narzędzi BladeRF, podłącz urządzenie BladeRF do komputera i uruchom poniższe polecenie:

```
bladeRF-cli -e 'info' -v verbose
```

#### Konfiguracja hosta:

```
./configure_host.sh
```

#### Wdrożenie 4G

```
# 4G Core Network + IMS + SMS over SGs
sudo docker compose -f 4g-volte-deploy.yaml up

# srsRAN eNB korzystający z SDR (OTA)
sudo docker compose -f srsenb.yaml up -d && docker container attach srsenb
```

## Provisionowanie informacji o SIM

### Provisionowanie informacji o SIM w open5gs HSS jak poniżej:

Otwórz (http://<DOCKER_HOST_IP>:9999) w przeglądarce internetowej, gdzie  <DOCKER_HOST_IP> to IP hosta uruchamiającego kontenery open5gs. Zaloguj się za pomocą następujących poświadczeń
```
Username : admin
Password : 1423
```

Korzystając z interfejsu Web UI, dodaj abonenta (subscriber)

![Zrzut ekranu subskrybenta nr 1](https://github.com/Apurer/4g-volte/blob/master/assets/img/konfiguracja-abonenta-w-webgui-nr1-6.png "Zrzut ekranu subskrybenta nr 1")
![Zrzut ekranu subskrybenta nr 2](https://github.com/Apurer/4g-volte/blob/master/assets/img/konfiguracja-abonenta-w-webgui-nr2-6.png "Zrzut ekranu subskrybenta nr 2")


### Provisionowanie IMSI i MSISDN z OsmoHLR jak poniżej:

1. Najpierw zaloguj się do kontenera osmohlr

```
sudo docker exec -it osmohlr /bin/bash
```

2. Następnie telnet do localhost

```
$ telnet localhost 4258

OsmoHLR> enable
OsmoHLR#
```

3. W końcu zarejestruj informacje o abonencie zgodnie z poniższym przykładem:

```
OsmoHLR# subscriber imsi 001010123456789 create
OsmoHLR# subscriber imsi 001010123456789 update msisdn 9076543210

OsmoHLR# subscriber imsi 001010123456791 create
OsmoHLR# subscriber imsi 001010123456791 update msisdn 9076543211
```

### Provisionowanie informacji o SIM w pyHSS jest jak poniżej:

1. Przejdź do http://<DOCKER_HOST_IP>:8080/docs/
2. Wybierz **apn** -> **Create new APN** -> Naciśnij **Try it out**. Następnie w sekcji payload użyj poniższego JSONa, a potem naciśnij **Execute**

```
{
  "apn": "internet",
  "apn_ambr_dl": 0,
  "apn_ambr_ul": 0
}
```

Zanotuj **apn_id** podany w **Response body** pod **Server response** dla APN **internet**

Powtórz krok tworzenia dla następującego payloadu

```
{
  "apn": "ims",
  "apn_ambr_dl": 0,
  "apn_ambr_ul": 0
}
```

Zanotuj **apn_id** podany w **Response body** pod **Server response** dla APN **ims**

**Wykonaj ten krok tworzenia APN**

3. Następnie, wybierz **auc** -> **Create new AUC** -> Naciśnij **Try it out**. Następnie w sekcji payload użyj poniższego przykładowego JSONa do wypełnienia, a następnie naciśnij **Execute**

```
{
  "ki": "99887766554433221100AABBCCDDEEFF",
  "opc": "73BFA50EE6523365FF14C1F45F88737D",
  "amf": "8000",
  "sqn": 0,
  "imsi": "001010123456789"
}
```

Zanotuj **auc_id** podany w **Response body** pod **Server response**

Powtórz krok tworzenia dla następującego payloadu

```
{
    "ki": "00112233445566778899AABBCCDDEEFF",
    "opc": "63BFA50EE6523365FF14C1F45F88737D",
    "amf": "8000",
    "sqn": 0,
    "imsi": "001010123456791"
}
```
Zanotuj **auc_id** podany w **Response body** pod **Server response**

4. Następnie, wybierz **subscriber** -> **Create new SUBSCRIBER** -> Naciśnij **Try it out**. Następnie w sekcji payload użyj poniższego przykładowego JSONa, a następnie naciśnij **Execute**

```
{
    "imsi": "001010123456789",
    "enabled": true,
    "auc_id": 1,
    "default_apn": 1,
    "apn_list": "1,2",
    "msisdn": "9076543210",
    "ue_ambr_dl": 0,
    "ue_ambr_ul": 0
}
```

- **auc_id** to ID **AUC** utworzone w poprzednich krokach
- **default_apn** to ID APN **internet** utworzone w poprzednich krokach
- **apn_list** to lista oddzielonych przecinkami ID APN dozwolonych dla UE, czyli ID APN dla  **internet** i **ims** utworzone w poprzednich krokach

Powtórz krok tworzenia dla następującego payloadu

```
{
    "imsi": "001010123456791",
    "enabled": true,
    "auc_id": 2,
    "default_apn": 1,
    "apn_list": "1,2",
    "msisdn": "9076543211",
    "ue_ambr_dl": 0,
    "ue_ambr_ul": 0
}
```

**Zastąp imsi i msisdn zgodnie z zaprogramowaną kartą SIM**

5. Wybierz **ims_subscriber** -> **Create new IMS SUBSCRIBER** -> Naciśnij **Try it out**. Następnie w sekcji payload użyj poniższego przykładowego JSONa, a następnie naciśnij **Execute**

```
{
    "imsi": "001010123456789",
    "msisdn": "9076543210",
    "sh_profile": "string",
    "scscf_peer": "scscf.ims.mnc001.mcc001.3gppnetwork.org",
    "msisdn_list": "[9076543210]",
    "ifc_path": "default_ifc.xml",
    "scscf": "sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060",
    "scscf_realm": "ims.mnc001.mcc001.3gppnetwork.org"
}
```

Powtórz krok tworzenia dla następującego payloadu

```
{
    "imsi": "001010123456791",
    "msisdn": "9076543211",
    "sh_profile": "string",
    "scscf_peer": "scscf.ims.mnc001.mcc001.3gppnetwork.org",
    "msisdn_list": "[9076543211]",
    "ifc_path": "default_ifc.xml",
    "scscf": "sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060",
    "scscf_realm": "ims.mnc001.mcc001.3gppnetwork.org"
}
```

## Nieobsługiwane
- Użycie IPv6 w Docker
