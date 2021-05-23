```
➜  terraform-boilerplate$ docker-compose run --rm tf workspace new <service>
➜  terraform-boilerplate$ docker-compose run --rm tf init terraform/arch/<service>
➜  terraform-boilerplate$ docker-compose run --rm tf apply terraform/arch/<service>
➜  terraform-boilerplate$ docker-compose run --rm tf destroy terraform/arch/<service>
```
