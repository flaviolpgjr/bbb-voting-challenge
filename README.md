# BBB Voting Challenge

Sistema de votação desenvolvido em **Ruby on Rails** inspirado na dinâmica de votação do Big Brother Brasil.

O projeto foi desenvolvido com foco em **escalabilidade**, **processamento assíncrono**, **observabilidade** e **alta disponibilidade**, utilizando Redis como contador de votos, Sidekiq para persistência assíncrona e Prometheus/Grafana para monitoramento.

---

# Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Arquitetura](#arquitetura)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Funcionalidades](#funcionalidades)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Como Executar Localmente](#como-executar-localmente)
- [APIs](#apis)
- [Observabilidade](#observabilidade)
- [SLO e SLI](#slo-e-sli)
- [Segurança](#segurança)
- [Testes Automatizados](#testes-automatizados)
- [Teste de Carga](#teste-de-carga)
- [Decisões Técnicas](#decisões-técnicas)
- [Melhorias Futuras](#melhorias-futuras)

---

# Sobre o Projeto

A aplicação permite que usuários votem em participantes de um paredão.

Para suportar um grande volume de votos, os contadores são mantidos em Redis, enquanto a persistência definitiva é realizada de forma assíncrona através do Sidekiq.

Além da API de votação, o projeto disponibiliza métricas para Prometheus, dashboards no Grafana e mecanismos simples de proteção contra bots.

---

# Arquitetura

```
                           Frontend
                     HTML + CSS + JavaScript
                               │
                               │ HTTP
                               ▼
                     Ruby on Rails API
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
          ▼                    ▼                    ▼
       Redis              Sidekiq Jobs        PostgreSQL
(contadores em memória)     (persistência)     (armazenamento)

                               │
                               ▼
                     Prometheus Metrics
                               │
                               ▼
                           Grafana
```

### Componentes

- Frontend em HTML/CSS/JavaScript
- API REST em Ruby on Rails
- Redis para contadores
- Sidekiq para processamento assíncrono
- PostgreSQL para persistência
- Prometheus para coleta de métricas
- Grafana para dashboards

---

# Tecnologias Utilizadas

## Backend

- Ruby on Rails
- PostgreSQL
- Redis
- Sidekiq
- RSpec

## Frontend

- HTML5
- CSS3
- Bootstrap
- JavaScript

## Observabilidade

- Prometheus
- Grafana

## Infraestrutura

- Docker
- Docker Compose

---

# Funcionalidades

- Cadastro de participantes via Seeds
- Votação
- Resultado parcial
- Resultado por participante
- Resultado por hora
- Persistência assíncrona
- Métricas Prometheus
- Dashboards Grafana
- Honeypot
- Rate Limiting
- Validação de tempo mínimo para votação

---

# Estrutura do Projeto

```
backend/
frontend/
load-tests/
observability/

docker-compose.yml
docker-compose.load.yml
README.md
```

---

# Como Executar Localmente

## Pré-requisitos

- Docker
- Docker Compose

---

## Subindo a aplicação

```bash
docker compose up --build
```

Na primeira execução, execute:

```bash
docker compose exec backend rails db:create
docker compose exec backend rails db:migrate
docker compose exec backend rails db:seed
```

---

## Acessos

| Serviço      | URL                           |
| ------------ | ----------------------------- |
| Frontend     | http://localhost:8080         |
| Backend      | http://localhost:3000         |
| Health Check | http://localhost:3000/health  |
| Metrics      | http://localhost:3000/metrics |
| Prometheus   | http://localhost:9090         |
| Grafana      | http://localhost:3001         |

### Grafana

Usuário

```
admin
```

Senha

```
admin
```

---

# APIs

## Registrar voto

```
POST /api/v1/votes
```

### Body

```json
{
  "participant_id": 1,
  "website": "",
  "rendered_at": 1752090000000
}
```

### Resposta

```
202 Accepted
```

```json
{
  "success": true,
  "message": "Vote accepted for processing"
}
```

---

## Resultado da votação

```
GET /api/v1/results
```

### Exemplo

```json
{
  "total_votes": 125,
  "participants": [],
  "hourly_results": []
}
```

---

## Health Check

```
GET /health
```

### Exemplo

```json
{
  "status": "ok",
  "database": "up",
  "redis": "up"
}
```

---

## Métricas

```
GET /metrics
```

Exemplo:

```
vote_requests_total
votes_accepted_total
votes_rejected_total
```

---

# Observabilidade

O projeto disponibiliza dashboards no Grafana para acompanhamento da aplicação.

## Dashboard API

Monitora:

- Total de requisições
- Votos aceitos
- Votos rejeitados
- Requisições por segundo

---

## Dashboard Availability

Monitora:

- Disponibilidade da API
- Histórico de disponibilidade
- SLO de disponibilidade

---

## Dashboard Voting

Monitora:

- Taxa de sucesso das votações (SLI)
- Acompanhamento do SLO de votação

---

# SLO e SLI

## Disponibilidade

### SLO

Disponibilidade mínima de **99,9%**.

### SLI

```
avg_over_time(up{job="bbb_backend"}[5m]) * 100
```

---

## Sucesso das votações

### SLO

Pelo menos **99%** das requisições devem ser aceitas.

### SLI

```
(votes_accepted_total / vote_requests_total) * 100
```

---

# Segurança

## Honeypot

Campo oculto utilizado para identificar bots.

---

## Tempo mínimo

O voto só é aceito caso exista um intervalo mínimo entre o carregamento da página e o envio.

---

## Rate Limiting

Implementado utilizando Rack::Attack.

Configurável através das variáveis:

```
RACK_ATTACK_LIMIT
RACK_ATTACK_PERIOD
```

---

# Testes Automatizados

Executar:

```bash
docker compose exec backend bundle exec rspec
```

Os testes cobrem:

- Request Specs
- Service Specs
- Contadores Redis

---

# Teste de Carga

Para executar o ambiente otimizado para carga:

```bash
docker compose -f docker-compose.yml -f docker-compose.load.yml up --build
```

Executar o teste:

```bash
docker run --rm \
  --network bbb-voting-challenge_default \
  -v "$PWD/load-tests:/scripts" \
  -e BASE_URL=http://backend:3000 \
  grafana/k6 run /scripts/vote-throughput.js
```

Caso o nome da rede seja diferente:

```bash
docker network ls
```

---

## Resultado obtido

Em ambiente Docker local, foi executado um cenário de carga configurado para gerar até **1000 votos por segundo**.

Resultado observado:

- Aproximadamente **903 requisições/segundo**
- **99,67%** de sucesso
- Latência **p95 inferior a 1 segundo**

Os resultados podem variar conforme os recursos disponíveis na máquina utilizada.

---

# Decisões Técnicas

### Redis

Utilizado para manter os contadores em memória, reduzindo leituras constantes no banco.

---

### Sidekiq

Responsável pela persistência assíncrona dos votos, desacoplando a resposta da API da gravação definitiva.

---

### PostgreSQL

Responsável pelo armazenamento persistente dos votos e demais dados relacionais.

---

### Prometheus

Coleta métricas da aplicação através do endpoint `/metrics`.

---

### Grafana

Exibe dashboards para acompanhamento operacional da aplicação.

---

### Docker

Todo o ambiente é executado através do Docker Compose, facilitando a reprodução do projeto em qualquer ambiente.

---

# Melhorias Futuras

- Redis Cluster
- Balanceamento de carga
- Kubernetes
- Auto Scaling
- Atualização em tempo real via WebSocket
- Persistência em lote
- Cache distribuído
- Autenticação de usuários

---

# Autor

Projeto desenvolvido como solução para o desafio técnico **BBB Voting Challenge**.
