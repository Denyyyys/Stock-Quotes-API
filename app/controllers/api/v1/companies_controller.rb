require_relative '../../../utilities/utility_methods'
module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :validate_pagination_params, only: :index
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      rescue_from ActiveRecord::RecordNotUnique, with: :handle_new_record_has_not_unique_ticker
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
        company = Company.create!(company_params)

        if company.save
          render json: company, serializer: CompanySerializer, status: :created
        else
          render json: { status: 'Error', message: company.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
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

      def company_params
        params.permit(:ticker, :name, :origin_country)
      end

      def handle_record_invalid(error)
        render json: { error: error.message }, status: :unprocessable_entity
      end

      def handle_new_record_has_not_unique_ticker
        render json: { error: "Company with provided ticker already exists!" }, status: :unprocessable_entity
      end
    end
  end
end
