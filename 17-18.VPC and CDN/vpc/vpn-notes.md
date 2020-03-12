### Client VPN

##### 1. Сгенерировать сертификаты

1. Устанавливаем easyrsa, инициализируем pki, создаем
certificate authority, генерируем сертификаты для клиента
и сервера и копируем их в специальную папку.
    ```
   # download easy-rsa
   git clone https://github.com/OpenVPN/easy-rsa.git
   cd easy-rsa/easyrsa3
   
   # initialize public key infrastructure
   ./easyrsa init-pki
   # build new certificate authority
   ./easyrsa build-ca nopass
   
   # generate server cert and key
   ./easyrsa build-server-full server nopass
   # generate client cert and key
   ./easyrsa build-client-full client1.domain.tld nopass
   
   # copy to custom folder
   mkdir ~/.rsa-certs/
   cp pki/ca.crt ~/.rsa-certs/
   cp pki/issued/server.crt ~/.rsa-certs/
   cp pki/private/server.key ~/.rsa-certs/
   cp pki/issued/client1.domain.tld.crt ~/.rsa-certs
   cp pki/private/client1.domain.tld.key ~/.rsa-certs/
   cd ~/.rsa-certs/ 
   ```

2. Загружаем сертификат и ключ сервера в aws certificate
manager, чтобы подключить его к client vpn endpoint.
    ```
   # upload server certificate and key
    aws acm import-certificate 
        --certificate fileb://server.crt 
        --private-key fileb://server.key
        --certificate-chain fileb://ca.crt 
        --region eu-north-1
   ```

##### 2. Доступы

1. Достаточно чтобы *client vpn endpoint* был ассоциирован только с одной
*subnet*. Если эта *subnet* имеет доступ к другим *subnet*, то через нее
*client vpn endpoint* будет иметь доступ и к остальным *subnets*.

2. Имеет смысл подключать *client vpn endpoint* к хотя бы одной *subnet*
в каждой *az* присутствия. Т.к. если *client vpn endpoint* подключен только
к одной *az*, и она отвалилась, то *client vpn endpoint* не потеряет доступ
и к остальным *az*.

3. Чтобы был доступ к конкретной subnet, должен быть добавлены:
    * *VpnClientEndpoint.RouteTable.route* с *destination=subnet.cidr*
    * *VpnClientEndpoint.Authorization.authorizeIngress с *destination=subnet.cidr*
    * *VpnClientEndpoint.SecurityGroups* с необходимыми разрешениями. 

##### 3. Подключиться к client vpn endpoint

1. Получить config file 
    ```
    aws ec2 export-client-vpn-client-configuration \
        --client-vpn-endpoint-id cvpn-endpoint-0d9549b5835dcdbf7 \
        --output text>client-config.ovpn
    ```
2. Добавить информацию о сертификате в config file
    ```
    echo "cert client1.domain.tld.crt" >> client-config.ovpn
    echo "key client1.domain.tld.key" >> client-config.ovpn
    ```
3. Поместить config file и сертификаты туда, где vpn client
(например OpenVpn) ожидает их обнаружить.
    ```
    mkdir OpenVPN
    mkdir OpenVPN/config
    cp client-config.ovpn ~/OpenVPN/config
    cp ~/.rsa-certs/client1.domain.tld.crt ~/OpenVPN/config 
    cp ~/.rsa-certs/client1.domain.tld.key ~/OpenVPN/config
    ```   
   
##### 4. Заставить OpenVPN ходить в интернет через локальную сеть, а не через client vpn endpoint

Нужно выставить параметр
```
...
resource "aws_ec2_client_vpn_endpoint" "my-vpn-endpoint" {
    ...
    split_tunnel = true
    ...
}
...
```
и дело в шляпе.
<br/><br/>


Если этого не сделать, то во время подключения, серверная сторона
передает клиенту routes для его локального RouteTable, которые:
* Не имеют явных маршрутов к интересующим сетям в aws.
* Имеют маршруты, которые гонят весь трафик в client vpn endpoint.

Маршруты, которые приходят с сервера, имеют приоритет выше, чем можно
задать в config file клиента. Т.о. нельзя через config file задать маршруты,
которые перекроют те, что приходят с сервера. 
<br/><br/>
Решение:
1. Задать в config file клиента команду "игнорировать маршруты от сервера" (кроме
маршрутов относящихся к client vpn endpoint сети).
    ```
   ...
   pull-filter ignore redirect-gateway
   ...
   ```

2. Задать в config file клиента маршруты для интересующих сетей в aws.
    ```
   ...
   route 10.0.1.0 255.255.255.0
   route 10.0.2.0 255.255.255.0
   ...
   ```
