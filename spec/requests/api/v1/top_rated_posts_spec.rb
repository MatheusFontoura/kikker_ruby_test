require 'rails_helper'

RSpec.describe 'GET /api/v1/top_rated_posts', type: :request do
  it 'returns HTTP success with JSON array' do
    get '/api/v1/top_posts'

    expect(response).to have_http_status(:success)
    expect(response.parsed_body).to be_an(Array)
  end
end
