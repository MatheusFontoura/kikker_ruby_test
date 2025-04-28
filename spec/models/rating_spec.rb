require 'rails_helper'

RSpec.describe Rating, type: :model do
  subject { build(:rating) }

  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:post_id) }
    it { is_expected.to validate_inclusion_of(:value).in_range(1..5) }
  end
end
