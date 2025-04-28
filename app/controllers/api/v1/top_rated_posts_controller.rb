module Api
  module V1
    class TopRatedPostsController < ApplicationController
      def index
        limit = params[:limit].to_i
        limit = 10 if limit <= 0

        posts = TopRatedPosts.call(limit)

        render_success(posts)
      end

      private

      def render_success(posts)
        render json: posts.map { |post| post.slice(:id, :title, :body) }, status: :ok
      end
    end
  end
end
