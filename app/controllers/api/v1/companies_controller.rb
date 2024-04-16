require_relative '../../../utilities/utility_methods'
module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :validate_pagination_params, only: :index
      MAX_PAGINATION_LIMIT=50

      def index
        companies = Company.limit(limit).offset(params[:offset])
        render json: companies
      end

      def show
        if params[:ticker].present?
          company = Company.find_by("LOWER(ticker) = LOWER(?)", params[:ticker])
          if company
            render json: company
          else
            render json: { error: "Company with ticker '#{params[:ticker]}' not found" }, status: :not_found
          end
        end
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
