### VPC
1. Что такое *public/private subnets*?
<br/><br/>
*Public subnet* - это Subnet, которая привязана к *RouteTable* у которой
есть *Route* с *Target*=*InternetGateway*.
<br/><br/>
*Private subnet* - это Subnet, которая **не** привязана к *RouteTable* у которой
есть *Route* с *Target*=*InternetGateway*.

2. Доступ в интернет из *private subnet*.

    * Из *private subnet* нет доступа в интернет.
    * Чтобы был доступ в интернет, нужно настроить *NatGateway*.
 
3. Что такое *NatGateway*?

    * *NatGateway* располагается в *public subnet*.
    * *NatGateway* создается для конкретной az (в которой находится
    *public subnet*)
    * *NatGateway* требует привязки к *ElasticIP*, именно от этого
    *ElasticIP* он будет обращаться в интернет.
    
 4. Как сделать так, чтобы трафик от ec2 (например) в vpc шел
 к aws сервисам (s3, dynamo-db и т.д.) по внутренним сетям aws,
 а не через интернет. По внутренним сетям будет быстрее и трафик
 будет дешевле.
 
    * Нужно использовать VPC Endpoints
