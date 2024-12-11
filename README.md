# Catalyst con Deception
Il deployment del nodo Catalyst può essere realizzato in due step distinti:

1) Instanziazione di Wazuh
2) Instanziazione del nodo Catalyst

# Instanziazione di Wazuh

Tutti i file necessari per l'instanziazione di Wazuh sono stati inseriti nella directory single-node. Di seguito sono indicati i passi per completare tale stage.

1) Esegui lo script per la creazione dei certificati:
```
$ docker-compose -f generate-indexer-certs.yml run --rm generator
```

2) Avvia l'ambiente con docker-compose:

- In primo piano:
```
$ docker-compose up
```

- In background:
```
$ docker-compose up -d
```

# Instanziazione del Nodo Catalist

Per instazionare il nodo catalyst è necessario lanciare lo script init.sh presente all'interno di questa directory
```
$ ./init.sh
```

Per installare gli agent è necessario eseguire i seguenti comandi all'interno della directory wazuh-agent
```
$ docker cp <so>-agent.sh <nome_container>:/root/
$ docker exec -ti <nome_container> bash
# cd root
# ./<so>-agent.s
```

N.B. Si deve scegliere l'opportuno script in base al tipo di container in cui si instanzia l'immagine.
