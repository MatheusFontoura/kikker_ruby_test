# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'
require 'typhoeus'
require 'json'

TOTAL_USERS = 100
TOTAL_POSTS = 200_000
TOTAL_RATINGS = (TOTAL_POSTS * 0.75).to_i
POSTS_BATCH_SIZE = 1000
RATINGS_BATCH_SIZE = 1000

API_URL = ENV.fetch('API_URL', 'http://web:3000')
# Se rodar fora do docker: 'http://localhost:3001'

# 50 IPs
ips = (1..50).map { |i| "192.168.0.#{i}" }

Rails.logger.debug 'Criando usuários...'

users = Array.new(TOTAL_USERS) { |i| "user_#{i}_#{SecureRandom.hex(3)}" }
user_ids = []

# rubocop:disable Metrics/BlockLength
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
    Rails.logger.debug { "Erro criando usuário #{login}. Novamente..." }
    retry_response = request.run
    if retry_response.success?
      parsed = JSON.parse(retry_response.body)
      user_ids << parsed['user']['id']
    else
      Rails.logger.debug { "Falha ao criar usuário #{login} após retry. Código: #{retry_response.code}" }
    end
  end
end

Rails.logger.debug { "Usuários criados: #{user_ids.count}" }

Rails.logger.debug 'Criando posts...'

posts_ids = []

(0...TOTAL_POSTS).each_slice(POSTS_BATCH_SIZE) do |batch|
  hydra = Typhoeus::Hydra.new(max_concurrency: 40)

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
        Rails.logger.debug 'Erro criando post. Tentando novamente...'
        retry_response = request.run
        if retry_response.success?
          parsed = JSON.parse(retry_response.body)
          posts_ids << parsed['post']['id'] if parsed
        else
          Rails.logger.debug { "Falha ao criar post após retry. Código: #{retry_response.code}" }
        end
      end
    end

    hydra.queue(request)
  end

  hydra.run
  Rails.logger.debug { "Batch de #{batch.size} posts criada!" }
end

Rails.logger.debug { "Total de posts criados: #{posts_ids.size}" }

Rails.logger.debug 'Criando ratings...'

posts_ids.sample(TOTAL_RATINGS).each_slice(RATINGS_BATCH_SIZE) do |batch|
  hydra = Typhoeus::Hydra.new(max_concurrency: 40)

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
        Rails.logger.debug 'Erro criando rating. Tentando novamente...'
        retry_response = request.run
        unless retry_response.success?
          Rails.logger.debug { "Falha ao criar rating após retry. Código: #{retry_response.code}" }
        end
      end
    end

    hydra.queue(request)
  end

  hydra.run
  Rails.logger.debug { "Batch de #{batch.size} ratings criado" }
end
# rubocop:enable Metrics/BlockLength

Rails.logger.debug 'Seeds feitas'
