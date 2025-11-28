# Controlador de Domínio Primário (Active Directory) rodando Samba4 sob Void Linux Server ;D

## 🎯 Objetivo - Subir um Controlador de Domínio Primário no Void Linux (glibc) compilando o Samba4 a partir do código fonte, configurando DNS interno, Kerberos, integração AD, ACLs, serviços e toda a pilha necessária para controlar os clientes da rede.

### 🔧 ADAPTE o tutorial á SUA realidade, obviamente!

## 📡 Layout de rede local

- Domínio: EDUCATUX.EDU
- Hostname: VOIDDC01
- Firewall 192.168.70.254 (DNS/GW)
- Ip: 192.168.70.250

---

## Instalar o Void Linux

## Trocar o Shell padrão do Void

```bash
chsh -s /bin/bash
```

## 🧩 Instalar pacotes de dependências para compilar o Samba4 no Void

```bash
xbps-install -S \
 net-tools rsync acl attr attr-devel autoconf automake libtool \
 binutils bison gcc make ccache chrpath curl \
 docbook-xml docbook-xsl flex gdb git htop \
 mit-krb5 mit-krb5-client mit-krb5-devel \
 libarchive-devel avahi avahi-libs libblkid-devel \
 libbsd-devel libcap-devel cups-devel dbus-devel glib-devel \
 gnutls-devel gpgme-devel icu-devel jansson-devel \
 lmdb lmdb-devel libldap-devel ncurses-devel pam-devel perl \
 perl-Text-ParseWords perl-JSON perl-Parse-Yapp \
 libpcap-devel popt-devel readline-devel \
 libtasn1 libtasn1-devel libunwind-devel python3 python3-devel \
 python3-dnspython python3-cryptography \
 python3-matplotlib python3-pexpect python3-pyasn1 \
 tree libuuid-devel wget xfsprogs-devel zlib-devel \
 bind ldns pkg-config
```

## 🖥️ Setar hostname

```bash
echo "voiddc01" > /etc/hostname
```

## 🏠 /etc/hosts

```bash
vim /etc/hosts
```

## Conteúdo:

```bash
127.0.0.1      localhost
127.0.1.1      voiddc01.educatux.edu voiddc01
192.168.70.250 voiddc01.educatux.edu voiddc01
```

## 🌐 Configurar IP fixo

### 👉 Usaremos o método padrão do Void, o /etc/dhcpcd.conf

```bash
vim /etc/dhcpcd.conf
```

## Adicionar ip, gateway e dns:

```bash
interface eth0
static ip_address=192.168.70.250/24
static routers=192.168.70.254
static domain_name_servers=192.168.70.254
```

## Reiniciar a interface de rede:

```bash
sv restart dhcpcd
```

## 🌐 Setar o DNS temporário (ANTES de provisionar)

```bash
echo "nameserver 192.168.70.254" > /etc/resolv.conf
```

## Travar a configuração do resolv.conf

```bash
chattr +i /etc/resolv.conf
```

## 🔍 Validar endereço atribuído á interface de rede

```bash
ip -c addr
```

```bash
ip -br link
```

## 📥 Baixar e descompactar o código fonte do Samba4

```bash
wget https://download.samba.org/pub/samba/samba-4.23.3.tar.gz
```

```bash
tar -xvzf samba-4.23.3.tar.gz
```

## Compilar e instalar o código fonte

```bash
cd samba-4.23.3
```

```bash
./configure --prefix=/opt/samba
```

```bash
make -j$(nproc) && make install
```

## Comentário:

- O Void não interfere na instalação, pois Samba é compilado em /opt/samba.
- O make -j acelera muito a compilação, mesmo assim, vá tomar um café.
- Após instalar, o Samba4 compilado não tem serviços criados no runit.
- Criaremos os serviços manualmente.

## 📁 Adicionar Samba4 ao PATH do Sistema e reler o ambiente

```bash
echo 'export PATH=/opt/samba/bin:/opt/samba/sbin:$PATH' > /etc/profile
```

```bash
source /etc/profile
```

## Testar a inserção do PATH do Samba4 no Sistema Operacional

```bash
samba-tool -V
```

## Resultado:

```bash
4.23.3
```

🏰 Provisionar o domínio SAMBA4 (Criando o PDC propriamente dito)

```bash
samba-tool domain provision \
 --realm=educatux.edu \
 --domain=EDUCATUX \
 --use-rfc2307 \
 --dns-backend=SAMBA_INTERNAL \
 --server-role=dc \
 --adminpass='P@ssw0rd' \
 --option="ad dc functional level = 2016" \
 --function-level=2016
```

### Samba4 criará:

```bash
/opt/samba/etc/smb.conf
/opt/samba/private/*
/opt/samba/var/locks/sysvol
```

## Em resumo o Samba4:

- Cria a floresta AD, o DC primário, o DNS interno e o DB das contas.
- Define domínio, realm, nível funcional 2016 e a senha do Administrator.
- Void não instala nenhum Samba nativo, então não há conflito.
- Após isso, o DNS passa a ser o próprio PDC, precisando ajustar /etc/resolv.conf para 127.0.0.1.

## ⚙️ Validar o nível funcional 2016 do Active Directory

```bash
samba-tool domain level show
```

## Resultado:

```bash
Domain and forest function level for domain 'DC=educatux,DC=edu'
Forest function level: (Windows) 2016
Domain function level: (Windows) 2016
Lowest function level of a DC: (Windows) 2016
```

## 🧪 Testar manualmente o serviço AD DC antes de criar o serviço

```bash
/opt/samba/sbin/samba -i -M single
```

* -i → foreground
* -M single → modelo single-process (não dispara daemon forking fora do controle do runit)

## Se tudo estiver bem, você verá:

```bash
Completed DNS update check OK
Completed SPN update check OK
Registered EDUCATUX<1c> ...
```

## CTRL+C para sair

## 📦 Criar o serviço RUNIT do samba-ad-dc para subir o AD no boot

## ⚠️ Esta parte é muito importante. Apague restos antigos se for reajuste de Server pré-existente!!

```bash
sv stop samba-ad-dc 2>/dev/null
rm -rf /var/service/samba-ad-dc
rm -rf /var/service/a-ad-dc
rm -rf /etc/sv/samba-ad-dc
rm -rf /etc/sv/a-ad-dc
rm -rf /etc/sv/*/supervise
rm -rf /var/service/*/supervise
```

## Agora vamos criar os serviços e permissões do samba-ad-dc com logs, para o runit subir no boot do Sistema:

## Criar a estrutura do serviço antes de tudo

```bash
mkdir -p /etc/sv/samba-ad-dc/log
mkdir -p /var/log/samba-ad-dc
```

## Criar o serviço do run

```bash
cat > /etc/sv/samba-ad-dc/run << 'EOF'
#!/bin/sh
exec 2>&1
exec /opt/samba/sbin/samba -i -M single --debuglevel=3
EOF
```

## Setar a permissão do serviço do run

```bash
chmod +x /etc/sv/samba-ad-dc/run
```

## Criar o arquivo do log

```bash
cat > /etc/sv/samba-ad-dc/log/run << 'EOF'
#!/bin/sh
exec svlogd -tt /var/log/samba-ad-dc
EOF
```

## Setar a permissão do log/run

```bash
chmod +x /etc/sv/samba-ad-dc/log/run
```

## Habilitar o serviço do samba-ad-dc para subir no boot:

```bash
ln -s /etc/sv/samba-ad-dc /var/service/
```

## Validar se está rodando

```bash
sv status samba-ad-dc
```

## Você deverá ver algo como:

```bash
run: samba-ad-dc: (pid 28032) 4s; run: log: (pid 28031) 4s
```

## Validar os logs online:

```bash
tail -f /var/log/samba-ad-dc/current
```

## A saída correta será algo assim:

```bash
2025-11-27_04:14:23.73604 Completed DNS update check OK
2025-11-27_04:14:25.35809 Registered VOIDDC01<00> with 192.168.70.250 on interface 192.168.70.255
2025-11-27_04:14:25.35814 Registered VOIDDC01<03> with 192.168.70.250 on interface 192.168.70.255
2025-11-27_04:14:25.35815 Registered VOIDDC01<20> with 192.168.70.250 on interface 192.168.70.255
2025-11-27_04:14:25.35941 Registered EDUCATUX<1b> with 192.168.70.250 on interface 192.168.70.255
2025-11-27_04:14:25.35942 Registered EDUCATUX<1c> with 192.168.70.250 on interface 192.168.70.255
2025-11-27_04:14:25.35944 Registered EDUCATUX<00> with 192.168.70.250 on interface 192.168.70.255
2025-11-27_04:14:36.71381 Calling samba_kcc script
2025-11-27_04:14:37.31554 samba_runcmd_io_handler: Child /opt/samba/sbin/samba_kcc exited 0
2025-11-27_04:14:37.31557 Completed samba_kcc OK
```

## 🕒 NTP / Chrony Server

## O Controlador de domínio precisará ser o Time Server da rede local, pois com discrepância de 5min o Kerberos não autenticará mais o cliente

## Instalar o pacote do Chrony Server

```bash
xbps-install -Syu chrony
```

## Editar o arquivo do Server, substituir os repositórios de sincronizações de tempo e liberar as consultas da rede interna

```bash
vim /etc/chrony.conf
```

### Apontar os Servidores de tempo públicos do Brasil

```bash
# Comentar a linha do Servidor externo
#pool pool.ntp.org iburst (AQUI)

# Servidores de tempo BR
server 0.br.pool.ntp.org iburst
server 1.br.pool.ntp.org iburst
server 2.br.pool.ntp.org iburst
server 3.br.pool.ntp.org iburst

# Permitir sincronização da rede interna
allow 192.168.70.0/24
```

## Adicionar o serviço do chronyd ao start do RUNIT

```bash
ln -s /etc/sv/chronyd/ /var/service
```

## Reiniciar o TimeServer:

```bash
sv restart chronyd
```

## Valide os Servers, são cíclicos e aleatórios durante as consulta

```bash
chronyc sources -v
```

## 🔐 Kerberos: vincular o arquivo krb5.conf criado automagicamente no provisionamento ao path do /etc

```bash
ln -sf /opt/samba/private/krb5.conf /etc/krb5.conf
```

## 🧭 Destravar e rejustar o /etc/resolv.conf APÓS o provisionamento, e apontar para o próprio PDC

```bash
chattr -i /etc/resolv.conf
```

```bash
vim /etc/resolv.conf
```

## Conteúdo:

```bash
domain educatux.edu
search educatux.edu
nameserver 127.0.0.1
```

## Travar o arquivo novamente:

```bash
chattr +i /etc/resolv.conf
```

## 👑 Dar poderes de root ao Administrator

```bash
vim /opt/samba/etc/user.map
```

```bash
!root=educatux.edu\Administrator
```

## 🔗 Linkar bibliotecas do Winbind no Sistema

## Validar os paths de libdir:

```bash
/opt/samba/sbin/smbd -b | grep LIBDIR
```

## Saída esperada:

```bash
LIBDIR: /opt/samba/lib
```

## Criar links entre as bibliotecas

```bash
ln -s /opt/samba/lib/libnss_winbind.so.2 /usr/lib/
```

```bash
ln -s /usr/lib/libnss_winbind.so.2 /usr/lib/libnss_winbind.so
```

## Releia a configuração com as novas bibliotecas linkadas

```bash
ldconfig
```

## Validar efetividade da troca de tickets do kerberos, adicionando winbind ás duas linhas do nsswhitch (passwd e group):

```bash
vim /etc/nsswitch.conf
```

```bash
passwd: files winbind
group:  files winbind
```

### O resto do arquivo fica como está

## 📝 Validar o smb.conf criado automagicamente pelo provisionamento

```bash
cat /opt/samba/etc/smb.conf
```

```
# Global parameters
[global]
        ad dc functional level = 2016
        dns forwarder = 192.168.70.254
        netbios name = VOIDDC01
        realm = EDUCATUX.EDU
        server role = active directory domain controller
        workgroup = EDUCATUX
        idmap_ldb:use rfc2307 = yes

[sysvol]
        path = /opt/samba/var/locks/sysvol
        read only = No

[netlogon]
        path = /opt/samba/var/locks/sysvol/educatux.edu/scripts
        read only = No
```

## 🔍 Agora iremos validar importantes serviços do PDC como DNS, SMB, Winbind e Kerberos

```bash
ps aux | grep samba
```

## Resultado recebido:

```bash
root     28030  0.0  0.0   2392  1388 ?        Ss   01:14   0:00 runsv samba-ad-dc
root     28031  0.0  0.0   2540  1376 ?        S    01:14   0:00 svlogd -tt /var/log/samba-ad-dc
root     28032  0.1  3.3 129656 66884 ?        S    01:14   0:04 samba: root process  .
root     28033  0.0  1.6 129152 33728 ?        S    01:14   0:00 samba: tfork waiter process(28034)
root     28034  0.0  3.3 133112 67156 ?        Ss   01:14   0:00 /opt/samba/sbin/smbd -D --option=server role check:inhibit=yes --foreground
root     28038  0.0  1.6 129152 33432 ?        S    01:14   0:00 samba: tfork waiter process(28039)
root     28039  0.0  3.1 127588 63240 ?        Ss   01:14   0:00 /opt/samba/sbin/winbindd -D --option=server role check:inhibit=yes --foreground
root     28180  0.0  0.1   6696  2556 pts/0    S+   02:10   0:00 grep samba
```

```bash
samba-tool user show administrator
```

## Resultado recebido:

```bash
dn: CN=Administrator,CN=Users,DC=educatux,DC=edu
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Administrator
description: Built-in account for administering the computer/domain
instanceType: 4
whenCreated: 20251127040618.0Z
uSNCreated: 3889
name: Administrator
objectGUID: 732e3aed-f232-427d-9377-5bf7bc79cd8e
userAccountControl: 512
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
pwdLastSet: 134086899781242602
primaryGroupID: 513
objectSid: S-1-5-21-294413610-3908852046-3961109876-500
adminCount: 1
accountExpires: 9223372036854775807
sAMAccountName: Administrator
sAMAccountType: 805306368
objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=educatux,DC=edu
isCriticalSystemObject: TRUE
memberOf: CN=Domain Admins,CN=Users,DC=educatux,DC=edu
memberOf: CN=Schema Admins,CN=Users,DC=educatux,DC=edu
memberOf: CN=Enterprise Admins,CN=Users,DC=educatux,DC=edu
memberOf: CN=Group Policy Creator Owners,CN=Users,DC=educatux,DC=edu
memberOf: CN=Administrators,CN=Builtin,DC=educatux,DC=edu
lastLogonTimestamp: 134086916533352620
whenChanged: 20251127043413.0Z
uSNChanged: 4307
lastLogon: 134086917409338150
logonCount: 5
distinguishedName: CN=Administrator,CN=Users,DC=educatux,DC=edu
```

```bash
wbinfo -u
```

## Resultado recebido:

```bash
EDUCATUX\administrator
EDUCATUX\guest
EDUCATUX\krbtgt
```

```bash
wbinfo -g
```

## Resultado recebido:

```bash
EDUCATUX\administrator
EDUCATUX\guest
EDUCATUX\krbtgt
[root@voiddc01 samba-4.23.3]# wbinfo -g
EDUCATUX\cert publishers
EDUCATUX\ras and ias servers
EDUCATUX\allowed rodc password replication group
EDUCATUX\denied rodc password replication group
EDUCATUX\dnsadmins
EDUCATUX\enterprise read-only domain controllers
EDUCATUX\domain admins
EDUCATUX\domain users
EDUCATUX\domain guests
EDUCATUX\domain computers
EDUCATUX\domain controllers
EDUCATUX\schema admins
EDUCATUX\enterprise admins
EDUCATUX\group policy creator owners
EDUCATUX\read-only domain controllers
EDUCATUX\protected users
EDUCATUX\dnsupdateproxy
```

```bash
getent group "Domain Admins"
```

## Resultado recebido:

```bash
EDUCATUX\domain admins:x:3000004:
```

```bash
smbclient -L localhost -U Administrator
```

## Resultado recebido:

```bash
Password for [EDUCATUX\Administrator]:

        Sharename       Type      Comment
        ---------       ----      -------
        sysvol          Disk
        netlogon        Disk
        IPC$            IPC       IPC Service (Samba 4.23.3)
SMB1 disabled -- no workgroup available
```

```bash
samba-tool dns zonelist localhost -U administrator
```

## Resultado recebido:

```bash
Password for [EDUCATUX\administrator]:
  2 zone(s) found

  pszZoneName                 : educatux.edu
  Flags                       : DNS_RPC_ZONE_DSINTEGRATED DNS_RPC_ZONE_UPDATE_SECURE
  ZoneType                    : DNS_ZONE_TYPE_PRIMARY
  Version                     : 50
  dwDpFlags                   : DNS_DP_AUTOCREATED DNS_DP_DOMAIN_DEFAULT DNS_DP_ENLISTED
  pszDpFqdn                   : DomainDnsZones.educatux.edu

  pszZoneName                 : _msdcs.educatux.edu
  Flags                       : DNS_RPC_ZONE_DSINTEGRATED DNS_RPC_ZONE_UPDATE_SECURE
  ZoneType                    : DNS_ZONE_TYPE_PRIMARY
  Version                     : 50
  dwDpFlags                   : DNS_DP_AUTOCREATED DNS_DP_FOREST_DEFAULT DNS_DP_ENLISTED
  pszDpFqdn                   : ForestDnsZones.educatux.edu
```

```bash
samba-tool user show administrator
```

## Resultado recebido:

```bash
dn: CN=Administrator,CN=Users,DC=educatux,DC=edu
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Administrator
description: Built-in account for administering the computer/domain
instanceType: 4
whenCreated: 20251127040618.0Z
uSNCreated: 3889
name: Administrator
objectGUID: 732e3aed-f232-427d-9377-5bf7bc79cd8e
userAccountControl: 512
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
pwdLastSet: 134086899781242602
primaryGroupID: 513
objectSid: S-1-5-21-294413610-3908852046-3961109876-500
adminCount: 1
accountExpires: 9223372036854775807
sAMAccountName: Administrator
sAMAccountType: 805306368
objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=educatux,DC=edu
isCriticalSystemObject: TRUE
memberOf: CN=Domain Admins,CN=Users,DC=educatux,DC=edu
memberOf: CN=Schema Admins,CN=Users,DC=educatux,DC=edu
memberOf: CN=Enterprise Admins,CN=Users,DC=educatux,DC=edu
memberOf: CN=Group Policy Creator Owners,CN=Users,DC=educatux,DC=edu
memberOf: CN=Administrators,CN=Builtin,DC=educatux,DC=edu
lastLogonTimestamp: 134086916533352620
whenChanged: 20251127043413.0Z
uSNChanged: 4307
lastLogon: 134086917409338150
logonCount: 5
distinguishedName: CN=Administrator,CN=Users,DC=educatux,DC=edu
```

## 🔐 Desabilitar a complexidade de senhas para usuários do domínio (facilitar testes em laboratório - Inseguro para produção!)

```bash
samba-tool domain passwordsettings set --complexity=off
samba-tool domain passwordsettings set --history-length=0
samba-tool domain passwordsettings set --min-pwd-length=0
samba-tool domain passwordsettings set --min-pwd-age=0
samba-tool user setexpiry Administrator --noexpiry
```

## Reler as configurações do Samba4

```bash
smbcontrol all reload-config
```

## 🧪 Validar troca de tickets do Kerberos

```bash
kinit Administrator@EDUCATUX.EDU
```

```bash
klist
```

## Resultado recebido:

```bash
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: Administrator@EDUCATUX.EDU

Valid starting       Expires              Service principal
27/11/2025 02:22:52  27/11/2025 12:22:52  krbtgt/EDUCATUX.EDU@EDUCATUX.EDU
        renew until 28/11/2025 02:22:47
```

```bash
samba-tool dns query voiddc01 educatux.edu @ A -U Administrator
```

## Resultado recebido:

```bash
Password for [EDUCATUX\Administrator]:

  Name=, Records=1, Children=0
    A: 192.168.70.250 (flags=600000f0, serial=1, ttl=900)
  Name=_msdcs, Records=0, Children=0
  Name=_sites, Records=0, Children=1
  Name=_tcp, Records=0, Children=4
  Name=_udp, Records=0, Children=2
  Name=DomainDnsZones, Records=0, Children=2
  Name=ForestDnsZones, Records=0, Children=2
  Name=voiddc01, Records=1, Children=0
    A: 192.168.70.250 (flags=f0, serial=1, ttl=900)
```

```bash
drill google.com @192.168.70.250
```

## Resultado obtido:

```bash
;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 50285
;; flags: qr rd ra ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
;; QUESTION SECTION:
;; google.com.  IN      A

;; ANSWER SECTION:
google.com.     300     IN      A       172.217.30.142

;; AUTHORITY SECTION:

;; ADDITIONAL SECTION:

;; Query time: 224 msec
;; EDNS: version 0; flags: ; udp: 1232
;; SERVER: 192.168.70.250
;; WHEN: Thu Nov 27 02:30:42 2025
;; MSG SIZE  rcvd: 55
```

```bash
samba_dnsupdate --verbose
```

```bash
IPs: ['192.168.70.250']
Looking for DNS entry A voiddc01.educatux.edu 192.168.70.250 as voiddc01.educatux.edu.
Looking for DNS entry CNAME a9126dd4-c5ad-46b4-b91b-6ae91313e3b8._msdcs.educatux.edu voiddc01.educatux.edu as a9126dd4-c5ad-46b4-b91b-6ae91313e3b8._msdcs.educatux.edu.
Looking for DNS entry NS educatux.edu voiddc01.educatux.edu as educatux.edu.
Looking for DNS entry NS _msdcs.educatux.edu voiddc01.educatux.edu as _msdcs.educatux.edu.
Looking for DNS entry A educatux.edu 192.168.70.250 as educatux.edu.
Looking for DNS entry SRV _ldap._tcp.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _ldap._tcp.dc._msdcs.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.dc._msdcs.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.dc._msdcs.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _ldap._tcp.f5cccdab-a9d9-4b1f-9344-d2affb3c9855.domains._msdcs.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.f5cccdab-a9d9-4b1f-9344-d2affb3c9855.domains._msdcs.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.f5cccdab-a9d9-4b1f-9344-d2affb3c9855.domains._msdcs.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _kerberos._tcp.educatux.edu voiddc01.educatux.edu 88 as _kerberos._tcp.educatux.edu.
Checking 0 100 88 voiddc01.educatux.edu. against SRV _kerberos._tcp.educatux.edu voiddc01.educatux.edu 88
Looking for DNS entry SRV _kerberos._udp.educatux.edu voiddc01.educatux.edu 88 as _kerberos._udp.educatux.edu.
Checking 0 100 88 voiddc01.educatux.edu. against SRV _kerberos._udp.educatux.edu voiddc01.educatux.edu 88
Looking for DNS entry SRV _kerberos._tcp.dc._msdcs.educatux.edu voiddc01.educatux.edu 88 as _kerberos._tcp.dc._msdcs.educatux.edu.
Checking 0 100 88 voiddc01.educatux.edu. against SRV _kerberos._tcp.dc._msdcs.educatux.edu voiddc01.educatux.edu 88
Looking for DNS entry SRV _kpasswd._tcp.educatux.edu voiddc01.educatux.edu 464 as _kpasswd._tcp.educatux.edu.
Checking 0 100 464 voiddc01.educatux.edu. against SRV _kpasswd._tcp.educatux.edu voiddc01.educatux.edu 464
Looking for DNS entry SRV _kpasswd._udp.educatux.edu voiddc01.educatux.edu 464 as _kpasswd._udp.educatux.edu.
Checking 0 100 464 voiddc01.educatux.edu. against SRV _kpasswd._udp.educatux.edu voiddc01.educatux.edu 464
Looking for DNS entry SRV _ldap._tcp.Default-First-Site-Name._sites.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.Default-First-Site-Name._sites.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.Default-First-Site-Name._sites.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _ldap._tcp.Default-First-Site-Name._sites.dc._msdcs.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.Default-First-Site-Name._sites.dc._msdcs.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.Default-First-Site-Name._sites.dc._msdcs.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _kerberos._tcp.Default-First-Site-Name._sites.educatux.edu voiddc01.educatux.edu 88 as _kerberos._tcp.Default-First-Site-Name._sites.educatux.edu.
Checking 0 100 88 voiddc01.educatux.edu. against SRV _kerberos._tcp.Default-First-Site-Name._sites.educatux.edu voiddc01.educatux.edu 88
Looking for DNS entry SRV _kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs.educatux.edu voiddc01.educatux.edu 88 as _kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs.educatux.edu.
Checking 0 100 88 voiddc01.educatux.edu. against SRV _kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs.educatux.edu voiddc01.educatux.edu 88
Looking for DNS entry SRV _ldap._tcp.pdc._msdcs.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.pdc._msdcs.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.pdc._msdcs.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry A gc._msdcs.educatux.edu 192.168.70.250 as gc._msdcs.educatux.edu.
Looking for DNS entry SRV _gc._tcp.educatux.edu voiddc01.educatux.edu 3268 as _gc._tcp.educatux.edu.
Checking 0 100 3268 voiddc01.educatux.edu. against SRV _gc._tcp.educatux.edu voiddc01.educatux.edu 3268
Looking for DNS entry SRV _ldap._tcp.gc._msdcs.educatux.edu voiddc01.educatux.edu 3268 as _ldap._tcp.gc._msdcs.educatux.edu.
Checking 0 100 3268 voiddc01.educatux.edu. against SRV _ldap._tcp.gc._msdcs.educatux.edu voiddc01.educatux.edu 3268
Looking for DNS entry SRV _gc._tcp.Default-First-Site-Name._sites.educatux.edu voiddc01.educatux.edu 3268 as _gc._tcp.Default-First-Site-Name._sites.educatux.edu.
Checking 0 100 3268 voiddc01.educatux.edu. against SRV _gc._tcp.Default-First-Site-Name._sites.educatux.edu voiddc01.educatux.edu 3268
Looking for DNS entry SRV _ldap._tcp.Default-First-Site-Name._sites.gc._msdcs.educatux.edu voiddc01.educatux.edu 3268 as _ldap._tcp.Default-First-Site-Name._sites.gc._msdcs.educatux.edu.
Checking 0 100 3268 voiddc01.educatux.edu. against SRV _ldap._tcp.Default-First-Site-Name._sites.gc._msdcs.educatux.edu voiddc01.educatux.edu 3268
Looking for DNS entry A DomainDnsZones.educatux.edu 192.168.70.250 as DomainDnsZones.educatux.edu.
Looking for DNS entry SRV _ldap._tcp.DomainDnsZones.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.DomainDnsZones.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.DomainDnsZones.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _ldap._tcp.Default-First-Site-Name._sites.DomainDnsZones.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.Default-First-Site-Name._sites.DomainDnsZones.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.Default-First-Site-Name._sites.DomainDnsZones.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry A ForestDnsZones.educatux.edu 192.168.70.250 as ForestDnsZones.educatux.edu.
Looking for DNS entry SRV _ldap._tcp.ForestDnsZones.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.ForestDnsZones.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.ForestDnsZones.educatux.edu voiddc01.educatux.edu 389
Looking for DNS entry SRV _ldap._tcp.Default-First-Site-Name._sites.ForestDnsZones.educatux.edu voiddc01.educatux.edu 389 as _ldap._tcp.Default-First-Site-Name._sites.ForestDnsZones.educatux.edu.
Checking 0 100 389 voiddc01.educatux.edu. against SRV _ldap._tcp.Default-First-Site-Name._sites.ForestDnsZones.educatux.edu voiddc01.educatux.edu 389
No DNS updates needed
```

### ✅ RESUMO FINAL

## 🎉 Parabéns — você acaba de montar um domínio AD nível 2016 totalmente funcional no Void Linux!

### 👉 LEMBRE-SE: O Samba4, apesar de poder ser gerenciado por linha de comando, foi projetado para ser gerenciado pelas ferramentas de Gerenciamento de Servidores remotos - RSAT, podendo estas serem instaladas numa máquina com Windows 10, sem problemas!

## Agora você pode:

- unir máquinas Windows ao domínio
- usar GPOs
- testar replication (quando criar um DC2)
- criar usuários / grupos via RSAT
- configurar sysvol replication (com Rsync ou com o novo samba-gpupdate)
- adicionar DNS forwarders
- ativar DFS
- criar File Server membro
- etc.

---

🎯 THAT'S ALL FOLKS!

👉 Contato: zerolies@disroot.org
👉 https://t.me/z3r0l135


