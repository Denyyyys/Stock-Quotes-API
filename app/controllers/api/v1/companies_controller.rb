require_relative '../../../utilities/utility_methods'
module Api
  module V1

    class CompaniesController < ApplicationController
      before_action :validate_pagination_params, only: :index

      MAX_PAGINATION_LIMIT=50

      def index
        companies = Company.limit(limit()).offset(params[:offset])
        render json: companies
      end

      def show
      end
      def create
      end

      def destroy
      end

      private
      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end
    end
  end
end
