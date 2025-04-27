require 'rails_helper'

RSpec.describe CreatePostWithUser, type: :service do
  describe '.call' do
    let(:login) { 'test_user' }
    let(:params) { { title: 'Title', body: 'Body', login: login } }
    let(:ip) { '127.0.0.1' }

    context 'when user does not exist' do
      it 'creates a new user and post' do
        result = described_class.call(params, ip)

        expect(result).to be_success
        expect(User.find_by(login: login)).to be_present
        expect(Post.find_by(title: 'Title')).to be_present
      end

      it 'saves the correct IP address in the post' do
        described_class.call(params, ip)

        post = Post.find_by(title: 'Title')
        expect(post.ip).to eq(ip)
      end
    end

    context 'when user already exists' do
      let!(:user) { create(:user, login: login) }

      it 'creates only the post' do
        expect do
          described_class.call(params, ip)
        end.to change { Post.count }.by(1)

        expect(User.where(login: login).count).to eq(1)
      end
    end

    context 'when params are invalid' do
      it 'fails to create post' do
        invalid_params = { title: '', body: '', login: '' }
        result = described_class.call(invalid_params, ip)

        expect(result).not_to be_success
        expect(result.errors).to be_present
      end
    end
  end
end
