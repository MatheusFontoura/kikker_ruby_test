require 'rails_helper'

RSpec.describe 'GET /api/v1/ips', type: :request do
  it 'returns HTTP success with JSON array' do
    user1 = create(:user)
    user2 = create(:user)

    Post.create!(title: 'Post 1', body: 'Body 1', ip: '192.168.1.1', user: user1)
    Post.create!(title: 'Post 2', body: 'Body 2', ip: '192.168.1.1', user: user2)

    get '/api/v1/ips'

    expect(response).to have_http_status(:success)

    ips = response.parsed_body

    expect(ips).to be_an(Array)
    expect(ips.first['ip']).to eq('192.168.1.1')
    expect(ips.first['logins']).to include(user1.login, user2.login)
  end
end
