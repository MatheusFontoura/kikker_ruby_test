module Api
  module V1
    class RatingsController < ApplicationController
      def create
        result = CreateRating.call(
          post_id: params[:post_id],
          user_id: params[:user_id],
          value: params[:value]
        )

        if result.success?
          render_success(result)
        else
          render_error(result)
        end
      end

      private

      def render_success(result)
        render json: { average: result.average }, status: :created
      end

      def render_error(result)
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end
  end
end
