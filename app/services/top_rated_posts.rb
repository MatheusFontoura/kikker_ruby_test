class TopRatedPosts
  def self.call(limit = 10)
    Post
      .select('posts.id, posts.title, posts.body, AVG(ratings.value) AS average_rating')
      .joins(:ratings)
      .group('posts.id')
      .order('average_rating DESC')
      .limit(limit)
  end
end
