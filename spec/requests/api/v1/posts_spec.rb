require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  describe 'POST /api/v1/posts' do
    let(:valid_attributes) do
      {
        title: 'Post Title',
        body: 'Post Body',
        login: 'new_user'
      }
    end

    let(:headers) do
      { 'CONTENT_TYPE' => 'application/json' }
    end

    context 'when the request is valid' do
      it 'creates a post and a user' do
        post '/api/v1/posts', params: valid_attributes.to_json, headers: headers

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['post']['title']).to eq('Post Title')
        expect(response.parsed_body['user']['login']).to eq('new_user')
      end
    end

    context 'when the request is invalid' do
      it 'returns an error' do
        invalid_attributes = { title: '', body: '', login: '' }

        post '/api/v1/posts', params: invalid_attributes.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to be_present
      end
    end
  end
end
