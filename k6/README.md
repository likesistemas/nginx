# K6.io

Para rodar os testes iniciar o nginx usando o docker-compose.

```shell
docker-compose up --build -d
k6 run --vus 40 --duration 30s -e PORT=83 index.js # executar o nginx sem limites
k6 run --vus 40 --duration 30s -e PORT=84 -e BODY=php limit.js # executar o nginx com limites
```

Neste exemplo ele irá rodar com 40 conexões simultaneas por 30 segundos.

Para instalar o k6 seguir os passos no próprio [site](https://k6.io/docs/getting-started/installation/).
