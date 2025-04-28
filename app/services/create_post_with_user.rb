class CreatePostWithUser
  Result = Struct.new(:success?, :post, :user, :errors, keyword_init: true)

  def self.call(params, fallback_ip)
    user = User.find_or_create_by(login: params[:login])

    post = Post.new(
      user: user,
      title: params[:title],
      body: params[:body],
      ip: params[:ip] || fallback_ip
    )

    if post.save
      Result.new(success?: true, post: post, user: user)
    else
      Result.new(success?: false, errors: post.errors.full_messages)
    end
  end
end
