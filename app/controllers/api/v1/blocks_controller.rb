module Api
  module V1
    class BlocksController < ApplicationController
      before_action :validate_query_params, only: :show
      before_action :validate_pagination_params, :pagination_params, only: :index

      def index
        if from_home_page?
          blocks = Block.recent.limit(ENV["HOMEPAGE_BLOCK_RECORDS_COUNT"].to_i)
          options = {}
        else
          blocks = Block.recent.page(@page).per(@page_size)
          options = FastJsonapi::PaginationMetaGenerator.new(request: request, records: blocks, page: @page, page_size: @page_size).call
        end

        render json: BlockListSerializer.new(blocks, options)
      end

      def show
        json_block = Block.find_block!(params[:id])

        render json: json_block
      end

      private

      def from_home_page?
        params[:page].blank? || params[:page_size].blank?
      end

      def pagination_params
        @page = params[:page] || 1
        @page_size = params[:page_size] || Block.default_per_page
      end

      def validate_query_params
        validator = Validations::Block.new(params)

        if validator.invalid?
          errors = validator.error_object[:errors]
          status = validator.error_object[:status]

          render json: errors, status: status
        end
      end
    end
  end
end
