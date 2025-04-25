module Api
    module V1
      class PostsController < ApplicationController
        def create
          result = CreatePostWithUser.call(permitted_params, request.remote_ip)
  
          if result.success?
            render_success(result)
          else
            render_error(result)
          end
        end
  
        private
  
        def permitted_params
          params.permit(:title, :body, :login, :ip)
        end
  
        def render_success(result)
          render json: {
            post: result.post.slice(:id, :title, :body, :ip),
            user: result.user.slice(:id, :login)
          }, status: :created
        end
  
        def render_error(result)
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
    end
  end
  