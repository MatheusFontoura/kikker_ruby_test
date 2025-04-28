require 'rails_helper'

RSpec.describe CreateRating do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user: user) }

    context 'when rating is valid' do
      it 'creates a rating' do
        result = described_class.call(post_id: post.id, user_id: user.id, value: 4)

        expect(result.success?).to be true
        expect(result.average).to eq(4.0)
        expect(Rating.count).to eq(1)
      end

      it 'updates the post average rating correctly' do
        create(:rating, post: post, user: create(:user), value: 5)

        result = described_class.call(post_id: post.id, user_id: user.id, value: 3)

        expect(result.success?).to be true
        expect(result.average).to eq(4.0)
      end
    end

    context 'when rating is invalid' do
      it 'does not create a rating when required fields are missing' do
        result = described_class.call(post_id: nil, user_id: nil, value: 4)

        expect(result.success?).to be false
        expect(result.errors).to be_present
        expect(Rating.count).to eq(0)
      end

      it 'does not create a rating when value is out of allowed range' do
        result = described_class.call(post_id: post.id, user_id: user.id, value: 6)

        expect(result.success?).to be false
        expect(result.errors).to include('Value is not included in the list')
        expect(Rating.count).to eq(0)
      end
    end

    context 'when concurrent rating attempts happen' do
      it 'ensures only one rating is created for the same post/user' do
        threads = []

        5.times do
          threads << Thread.new do
            CreateRating.call(post_id: post.id, user_id: user.id, value: 5)
          end
        end

        threads.each(&:join)

        expect(Rating.where(post_id: post.id, user_id: user.id).count).to eq(1)
      end
    end
  end
end
