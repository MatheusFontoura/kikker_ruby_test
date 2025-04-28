require 'faker'
require 'typhoeus'
require 'json'

puts 'Limpando bancos de dados...'
Rating.delete_all
Post.delete_all
User.delete_all
puts 'Bancos de dados limpos!'

TOTAL_USERS = 100
TOTAL_POSTS = 200_000
TOTAL_RATINGS = (TOTAL_POSTS * 0.75).to_i
POSTS_BATCH_SIZE = 1000
RATINGS_BATCH_SIZE = 1000

API_URL = ENV.fetch('API_URL', 'http://web:3000')
# Se rodar fora do docker: 'http://localhost:3001'

# 50 IPs
ips = (1..50).map { |i| "192.168.0.#{i}" }

puts 'Criando usuários...'

users = Array.new(TOTAL_USERS) { |i| "user_#{i}_#{SecureRandom.hex(3)}" }
user_ids = []

users.each_with_index do |login, index|
  body = {
    title: "Seed Post User #{index}",
    body: "Post inicial para criar user #{login}",
    login: login,
    ip: ips.sample
  }

  request = Typhoeus::Request.new(
    "#{API_URL}/api/v1/posts",
    method: :post,
    body: body.to_json,
    headers: { 'Content-Type' => 'application/json' }
  )

  response = request.run

  if response.success?
    parsed = JSON.parse(response.body)
    user_ids << parsed['user']['id']
  else
    puts "Erro criando usuário #{login}. Tentando novamente..."
    retry_response = request.run
    if retry_response.success?
      parsed = JSON.parse(retry_response.body)
      user_ids << parsed['user']['id']
    else
      puts "Falha ao criar usuário #{login} após retry. Código: #{retry_response.code}"
    end
  end
end

puts "Usuários criados: #{user_ids.count}"

puts 'Criando posts...'

posts_ids = []

(0...TOTAL_POSTS).each_slice(POSTS_BATCH_SIZE) do |batch|
  hydra = Typhoeus::Hydra.new(max_concurrency: 30)

  batch.each do
    body = {
      title: Faker::Book.title,
      body: Faker::Lorem.paragraph(sentence_count: 5),
      login: users.sample,
      ip: ips.sample
    }

    request = Typhoeus::Request.new(
      "#{API_URL}/api/v1/posts",
      method: :post,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    request.on_complete do |response|
      if response.success?
        parsed = JSON.parse(response.body)
        posts_ids << parsed['post']['id'] if parsed
      else
        puts 'Erro criando post. Tentando novamente...'
        retry_response = request.run
        if retry_response.success?
          parsed = JSON.parse(retry_response.body)
          posts_ids << parsed['post']['id'] if parsed
        else
          puts "Falha ao criar post após retry. Código: #{retry_response.code}"
        end
      end
    end

    hydra.queue(request)
  end

  hydra.run
  puts "Batch de #{batch.size} posts criada!"
end

puts "Total de posts criados: #{posts_ids.size}"

puts 'Criando ratings...'

posts_ids.sample(TOTAL_RATINGS).each_slice(RATINGS_BATCH_SIZE) do |batch|
  hydra = Typhoeus::Hydra.new(max_concurrency: 30)

  batch.each do |post_id|
    user_id = user_ids.sample

    body = {
      post_id: post_id,
      user_id: user_id,
      value: rand(1..5)
    }

    request = Typhoeus::Request.new(
      "#{API_URL}/api/v1/ratings",
      method: :post,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    request.on_complete do |response|
      unless response.success?
        puts 'Erro criando rating. Tentando novamente...'
        retry_response = request.run
        unless retry_response.success?
          puts "Falha ao criar rating após retry. Código: #{retry_response.code}"
        end
      end
    end

    hydra.queue(request)
  end

  hydra.run
  puts "Batch de #{batch.size} ratings criado!"
end

puts 'Seeds feitas!'
