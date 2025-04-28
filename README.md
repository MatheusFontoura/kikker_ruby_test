### 📚 DESAFIO TÉCNICO - KIKKER

### 🔥 Sobre o desafio

**Este projeto consiste em construir uma API REST para:**

- Criar usuários e posts
- Avaliar posts com notas de 1 a 5
- Listar os posts mais bem avaliados
- Listar IPs utilizados por múltiplos autores

**Além disso, o teste prático solicita:**

- Seeds utilizando a própria API
- Banco de dados PostgreSQL
- Uso de Ruby on Rails
- Cobertura de testes automatizados
- Código validado com RuboCop

### Tecnologias utilizadas

- Ruby: 3.3.1
- Rails: 7.1.3.2
- PostgreSQL: 16
- Docker + Docker Compose
- RSpec para testes
- Rubocop para linters
- Typhoeus para requisições paralelas no seed
- Faker para geração de dados falsos

-----------------------------------------------------------------

### 🚀 SETUP DO PROJETO
O projeto está totalmente dockerizado! Basta seguir os passos abaixo:

**1. Clone o repositório**
```
git clone
cd kikker_ruby_test
```

**2. Suba o ambiente**
```
docker-compose build
docker-compose up -d
```

**3. Crie o banco de dados**
```
docker-compose exec web bundle exec rails db:create
docker-compose exec web bundle exec rails db:migrate
```

**4. Execute os testes automatizados**
```
docker-compose exec web bundle exec rspec
```

**5. Rode as seeds** 

(Se rodar as seeds antes dos testes automatizados, verifique-se de limpar a base de dados de testes)
```
docker-compose exec web bundle exec rails db:seed
```
_OBS: Pode demorar._

**6. Execute o RuboCop**
```
docker-compose exec web bundle exec rubocop
```

**7. Verifique o banco de dados via console**
```
docker-compose exec web bundle exec rails console
```

Dentro do console:
```
User.count
Post.count
Rating.count
```

**🌐 Testes manuais via API**

_A aplicação estará rodando em: http://localhost:3001_

**8. Endpoints principais**

Criar novo post
```
curl -X POST http://localhost:3001/api/v1/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Meu Post Teste","body":"Corpo do post","login":"testeuser","ip":"192.168.0.1"}'
```


Avaliar um post

_(Substitua post_id e user_id conforme criado na request anterior)_
```
curl -X POST http://localhost:3001/api/v1/ratings \
  -H "Content-Type: application/json" \
  -d '{"post_id":1,"user_id":1,"value":5}'
```

Listar Top Posts
```
curl http://localhost:3001/api/v1/top_posts
```

Listar IPs utilizados por múltiplos autores
```
curl http://localhost:3001/api/v1/ips
```

⚠️ Testes de cenários de erro

**9. Via API**

Criar post inválido (sem título, corpo ou login)
```
curl -X POST http://localhost:3001/api/v1/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"","body":"","login":"","ip":"192.168.0.1"}'
```

Avaliação inválida (valor fora de 1..5)
```
curl -X POST http://localhost:3001/api/v1/ratings \
  -H "Content-Type: application/json" \
  -d '{"post_id":1,"user_id":1,"value":10}'
```

**10. Via console**

Abra o console:
```
docker-compose exec web bundle exec rails console
```

Teste de avaliação duplicada (deve falhar)
```
Rating.create(post_id: 1, user_id: 1, value: 5) 
```
_Deve retornar erro caso já exista via seeds ou API manual_

```
Rating.create(post_id: 1, user_id: 1, value: 4) 
```
_Deve retornar erro_


Teste de valor fora do permitido
```
Rating.create(post_id: 1, user_id: 2, value: 10)
```

Exemplo de fluxo correto:
```
post = Post.first
user = User.where.not(id: post.user_id).first
rating = Rating.create(post_id: post.id, user_id: user.id, value: 4)
rating.persisted?
```

----------------------------------------
### 🧠 Estratégia de Geração de Dados (db/seeds.rb)
Para atender o desafio de 200.000 posts, cerca de 100 usuários e 75% dos posts com avaliações, o script de seeds utiliza:

- Limpeza de dados antes da criação (delete_all nas tabelas).
- Criação via API (Typhoeus).
- Execução paralela usando Typhoeus::Hydra para melhorar o desempenho.
- Batches de criação de posts e avaliações (grupos de 1000 registros).
- Resiliência: Tentativas de recriação em caso de falhas nas requisições.
- 50 IPs únicos e logins de usuários únicos usando SecureRandom.

### 🎯 Observações Finais

- Cobertura de testes RSpec para models, services e requests.
- Código validado por RuboCop.
- Projeto preparado para alta carga e múltiplas requisições simultâneas.
- 100% rodando em containers Docker.