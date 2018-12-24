
## AVM FRITZ!Box Synology Surveillance Home Mode Automation

![AVM FRITZ!Box Synology Surveillance Home Mode Automation](https://gioxx.org/wp-content/uploads/2018/12/synology-surveillance-station-automatizzare-lhome-mode-tramite-wifi-2.png)

Fork basato sul già ottimo lavoro di **Mark Schipper**, [qui disponibile](https://github.com/mschippr/AVMFritz-Box7490-SynologySurveillance-Automation). Io ho operato alcune piccole modifiche, introdotto l'utilizzo di Telegram (per farsi inviare il cambio di stato in "*tempo reale*") e tradotto il README in italiano, pubblicando inoltre un [articolo sul blog](https://gioxx.org/2018/12/24/synology-surveillance-station-home-mode-automatico-tramite-wifi/) per spiegarti l'uso di questi script e la possibilità di automatizzare il cambio dello stato *Home Mode* di [Synology Surveillance Station](https://www.synology.com/it-it/surveillance) (*dato che il Geofencing ufficiale è davvero una ciofeca!*).

## Requisiti di sistema

 - PHP 7 (disponibile nel Synology Package Manager) con estensioni soap e curl.
 - Utenza "API" per permettere di disabilitare o abilitare Home Mode della Surveillance Station (sconsigliato utilizzarne una già esistente con maggiori accessi).
 - Pacchetto file contenuti nel repository (aggiornati in caso di necessità).
 - **Opzionale**: bot Telegram tramite il quale ricevere i cambi di stato.

## Di cosa si tratta

Lo script PHP lancia una query SOAP a uno o più router AVM Fritz!Box per verificare che un MAC address sia attivo sulla rete WiFi. Seppur pensato per verificare un solo MAC, questo può verificarne anche più contemporaneamente, basterà specificarli tutti intervallandoli con uno spazio vuoto.

Lo script di shell utilizza chiamate API per modificare l'opzione Home Mode della Surveillance Station (per comodità *SS*) basandosi sul risultato della query SOAP. Lo script contiene infatti l'IP del tuo Synology e un'utenza della SS. Il consiglio è quello di creare un apposito utente con i soli diritti di abilitazione / disabilitazione dell'opzione Home Mode, così da poter riportare in chiaro username e password all'interno dello script senza troppe preoccupazioni.

Gli script SH, PHP, STATE, e RETRY trovano spazio all'interno della directory dell'utente appena creata. I due file di state e retry contengono l'ultimo stato dell'opzione Home Mode così da evitare di contattare costantemente le API della SS. Tu dovrai solo mettere a posto i permessi dei file e avviare lo script di shell tramite l'Utilità di Pianificazione del Synology. Io ho scelto di eseguire lo script di controllo ogni 5 minuti.

**La modifica dello script switch_homemode.sh è necessaria.**

 - Sintassi del singolo file: *./switch_homemode.sh MAC1 MAC2*
 - Sintassi per l'Utilità di Pianificazione in Synology: *bash
   /var/services/homes/api_user/switch_homemode.sh MAC1 MAC2*

