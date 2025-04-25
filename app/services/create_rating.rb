class CreateRating
  Result = Struct.new(:success?, :average, :errors, keyword_init: true)

  def self.call(post_id:, user_id:, value:)
    rating = Rating.new(post_id: post_id, user_id: user_id, value: value)

    if rating.save
      avg = Rating.where(post_id: post_id).average(:value).to_f.round(2)
      Result.new(success?: true, average: avg)
    else
      Result.new(success?: false, errors: rating.errors.full_messages)
    end
  end
end
