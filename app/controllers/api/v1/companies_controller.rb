module Api
  module V1
    class CompaniesController < ApplicationController
      MAX_PAGINATION_LIMIT=100

      def index
        companies = Company.all.limit(limit()).offset(params[:offset])
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
