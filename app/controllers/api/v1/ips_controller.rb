module Api
  module V1
    class IpsController < ApplicationController
      def index
        result = IpsByAuthors.call
        render_success(result)
      end

      private

      def render_success(result)
        render json: result, status: :ok
      end
    end
  end
end
