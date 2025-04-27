require 'rails_helper'

RSpec.describe 'Api::V1::Ratings', type: :request do
  describe 'POST /api/v1/ratings' do
    let!(:user) { create(:user) }
    let!(:post_record) { create(:post, user: user) }

    let(:valid_attributes) do
      {
        post_id: post_record.id,
        user_id: user.id,
        value: 5
      }
    end

    let(:headers) do
      { 'CONTENT_TYPE' => 'application/json' }
    end

    context 'when the request is valid' do
      it 'creates a rating' do
        post '/api/v1/ratings', params: valid_attributes.to_json, headers: headers

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['average']).to eq(5.0)
      end
    end

    context 'when the request is invalid' do
      it 'returns an error' do
        invalid_attributes = { post_id: nil, user_id: nil, value: 10 }

        post '/api/v1/ratings', params: invalid_attributes.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to be_present
      end
    end

    context 'when trying to rate the same post twice by the same user' do
      before do
        post '/api/v1/ratings', params: valid_attributes.to_json, headers: headers
      end

      it 'does not allow duplicate ratings' do
        post '/api/v1/ratings', params: valid_attributes.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('User has already been taken')
      end
    end
  end
end
