# Hostinger DDNS — controller.capivaradsm.com.br

Utilitário Linux independente para manter:

    controller.capivaradsm.com.br  A  <IPv4 público atual>

## Otimização por estado local

O serviço verifica o IPv4 público a cada execução, mas não precisa consultar a API Hostinger toda vez.

Após confirmar que o DNS está correto, salva:

    /var/lib/hostinger-ddns/state

Se o IPv4 público continuar igual ao IP confirmado, a consulta à Hostinger é ignorada até `FORCE_VERIFY_SECONDS` expirar. O padrão é 86400 segundos (24 horas).

## Requisitos

- Linux com systemd
- curl
- jq
- dig (`dnsutils` no Ubuntu/Debian)
- token da API Hostinger com acesso à zona `capivaradsm.com.br`

## Instalação

    git clone https://github.com/EzequielRibeiro/hostinger-ddns.git
    cd hostinger-ddns
    sudo ./install.sh

Configure o token:

    sudo nano /etc/hostinger-ddns/token

Depois:

    sudo hostinger-ddns test
    sudo hostinger-ddns verify
    sudo hostinger-ddns update
    sudo systemctl start hostinger-ddns.timer

## Comandos

    sudo hostinger-ddns test
    sudo hostinger-ddns check
    sudo hostinger-ddns update
    sudo hostinger-ddns update --force
    sudo hostinger-ddns verify
    sudo hostinger-ddns verify --update
    sudo hostinger-ddns status

### `test`

Consulta a API e mostra o IPv4 público e o registro Hostinger sem alterar DNS.

### `check`

Consulta a API Hostinger e compara o registro A com o IPv4 público. Quando estiver correto, atualiza o cache local.

### `update`

É o modo usado pelo systemd. Usa o cache local para evitar chamadas desnecessárias. Se o IP mudou ou a revalidação venceu, consulta a Hostinger e atualiza o registro quando necessário.

### `update --force`

Ignora o cache e força a validação + gravação do IPv4 público atual na Hostinger, mesmo quando o valor já é o mesmo. Útil para manutenção e recuperação manual.

### `verify`

Faz uma verificação E2E e compara o IPv4 público com:

- Hostinger API
- DNS autoritativo da zona
- Cloudflare `1.1.1.1`
- Google `8.8.8.8`
- Quad9 `9.9.9.9`
- resolver DNS local do Linux

Exemplo:

    Origem                   IPv4               Estado
    ------------------------ ------------------ --------
    IPv4 público             201.27.179.4       REFERÊNCIA
    Hostinger API            201.27.179.4       OK
    DNS autoritativo         201.27.179.4       OK
    Cloudflare 1.1.1.1       201.27.179.4       OK
    Google 8.8.8.8           201.27.179.4       OK
    Quad9 9.9.9.9            201.27.179.4       OK
    Resolver local           201.27.179.4       OK

    STATUS: HEALTHY

Se alguma camada divergir, retorna `STATUS: DEGRADED` e exit code 2.

### `verify --update`

Executa `verify`. Se houver divergência, executa `update --force` e repete a verificação. Isso corrige a zona Hostinger automaticamente; divergências causadas por cache de resolvers externos podem continuar até o TTL expirar.

### `status`

Mostra configuração, cache local e estado dos units systemd.

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

A execução frequente não significa chamadas frequentes à API porque o estado local evita consultas desnecessárias.

## Logs

    sudo journalctl -u hostinger-ddns.service
    sudo journalctl -u hostinger-ddns.service -f

## Estado local

    sudo cat /var/lib/hostinger-ddns/state

## Atualizando a instalação

    cd ~/hostinger-ddns
    git pull
    sudo ./install.sh

O instalador preserva `/etc/hostinger-ddns/hostinger-ddns.conf` e `/etc/hostinger-ddns/token` existentes.

## API

Operações utilizadas:

    GET  /zones/capivaradsm.com.br
    POST /zones/capivaradsm.com.br/validate
    PUT  /zones/capivaradsm.com.br

A atualização usa `overwrite: true` para substituir os registros que coincidem com `name=controller` e `type=A`.

## Desinstalação

    sudo ./uninstall.sh

A desinstalação remove o cache de `/var/lib/hostinger-ddns`, mas preserva `/etc/hostinger-ddns`, pois esse diretório contém o token da API.
