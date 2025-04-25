module Api
  module V1
    class PostsController < ApplicationController
      def create
        result = CreatePostWithUser.call(permitted_params, request.remote_ip)

        if result.success?
          render json: {
            post: result.post.as_json(only: %i[id title body ip]),
            user: result.user.as_json(only: %i[id login])
          }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def permitted_params
        params.permit(:title, :body, :login, :ip)
      end
    end
  end
end
