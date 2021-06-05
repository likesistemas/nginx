# K6.io

Para rodar os testes iniciar o nginx usando o docker-compose.

```shell
docker-compose up --build -d
k6 run --vus 40 --duration 30s index.js # executar o nginx sem limites
k6 run --vus 40 --duration 30s limit.js # executar o nginx com limites
```

Neste exemplo ele irá rodar com 40 conexões simultaneas por 30 segundos.

Para instalar o k6 seguir os passos no próprio [site](https://k6.io/docs/getting-started/installation/).
