# Hostinger DDNS — controller.capivaradsm.com.br

Utilitário Linux independente para manter:

    controller.capivaradsm.com.br  A  <IPv4 público atual>

## Otimização por estado local

O serviço verifica o IPv4 público a cada execução, mas não precisa consultar
a API Hostinger toda vez.

Após confirmar que o DNS está correto, salva:

    /var/lib/hostinger-ddns/state

Exemplo:

    LAST_CONFIRMED_IP=200.100.50.25
    LAST_VERIFIED_EPOCH=1788145200
    FQDN=controller.capivaradsm.com.br

Se na próxima execução o IP público continuar igual ao IP confirmado, a
consulta à Hostinger é ignorada.

Para evitar que uma alteração manual feita no painel Hostinger passe
despercebida indefinidamente, existe uma revalidação forçada.

Por padrão:

    FORCE_VERIFY_SECONDS=86400

ou seja, uma consulta completa à API pelo menos a cada 24 horas.

## Requisitos

- Linux com systemd
- curl
- jq
- token da API Hostinger com acesso à zona `capivaradsm.com.br`

## Instalação

    cd hostinger-ddns
    sudo ./install.sh

Configure o token:

    sudo nano /etc/hostinger-ddns/token

Depois:

    sudo hostinger-ddns test
    sudo hostinger-ddns update
    sudo systemctl start hostinger-ddns.timer

## Comandos

    sudo hostinger-ddns test
    sudo hostinger-ddns check
    sudo hostinger-ddns update
    sudo hostinger-ddns status

### test

Sempre consulta a API, mas não altera DNS.

### check

Sempre consulta a API e compara o registro Hostinger com o IP público.
Quando estiver correto, atualiza o cache local.

### update

É o comando usado pelo systemd:

1. Detecta o IPv4 público.
2. Compara com o cache local.
3. Se for igual e o cache ainda estiver dentro do período de validade,
   encerra sem chamar a API.
4. Se mudou ou a revalidação venceu, consulta a Hostinger.
5. Se necessário, valida e atualiza o registro A.
6. Salva o novo estado local.

## Configuração

    /etc/hostinger-ddns/hostinger-ddns.conf

Valores padrão:

    DOMAIN="capivaradsm.com.br"
    RECORD="controller"
    TTL=300
    TOKEN_FILE="/etc/hostinger-ddns/token"
    STATE_DIR="/var/lib/hostinger-ddns"
    STATE_FILE="/var/lib/hostinger-ddns/state"
    FORCE_VERIFY_SECONDS=86400

## Timer

Executa aproximadamente a cada 5 minutos:

    OnUnitActiveSec=5min

A execução frequente não significa uma chamada frequente à API porque o
estado local evita consultas desnecessárias.

## Logs

    sudo journalctl -u hostinger-ddns.service
    sudo journalctl -u hostinger-ddns.service -f

## Estado

    sudo hostinger-ddns status

Também pode ser inspecionado diretamente:

    sudo cat /var/lib/hostinger-ddns/state

## API

Operações:

    GET  /zones/capivaradsm.com.br
    POST /zones/capivaradsm.com.br/validate
    PUT  /zones/capivaradsm.com.br

A atualização usa `overwrite: true` para substituir os registros que
coincidem com `name=controller` e `type=A`.

## Desinstalação

    sudo ./uninstall.sh

A desinstalação remove o cache de `/var/lib/hostinger-ddns`, mas preserva
`/etc/hostinger-ddns`, pois esse diretório contém o token da API.
