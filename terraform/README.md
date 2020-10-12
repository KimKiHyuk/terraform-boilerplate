```
➜  terraform-boilerplate$ docker-compose run --rm tf init terraform/arch/service_0/dev
➜  terraform-boilerplate$ docker-compose run --rm tf apply -var "<region>" -var "cidr_block=<block>" -var "subnet=<subnet>" -var "access_key=<key>" -var "secret_key=<key>" terraform/arch/service_0/dev
➜  terraform-boilerplate$ docker-compose run --rm tf destroy -var "<region>" -var "cidr_block=<block>" -var "subnet=<subnet>" -var "access_key=<key>" -var "secret_key=<key>" terraform/arch/service_0/dev
```
