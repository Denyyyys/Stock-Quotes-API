# frozen_string_literal: true

require_relative '../../../utilities/utility_methods'
module Api
  module V1
    # Controller for handling API endpoints related to companies
    class CompaniesController < ApplicationController
      before_action :validate_pagination_params, only: :index
      before_action :upcase_ticker
      rescue_from ActiveRecord::RecordNotFound, with: :handle_cannot_find_company
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      rescue_from ActiveRecord::LockWaitTimeout, with: :handle_lock_wait_timeout
      MAX_PAGINATION_LIMIT = 50

      def index
        ActiveRecord::Base.transaction do
          companies = Company.limit(limit).offset(params[:offset])&.lock!
          render json: companies
        end
      end

      def show
        ActiveRecord::Base.transaction do
          company = Company.find_by(ticker: params[:ticker])&.lock!
          raise ActiveRecord::RecordNotFound unless company
          render json: company
        end
      end

      def create
        ActiveRecord::Base.transaction do
          company = Company.create!(company_params)&.lock!
          render json: company, status: :created
        end
      end

      def destroy
        ActiveRecord::Base.transaction do
          company = find_company_by_ticker(params[:ticker])&.lock!
          if company
            destroy_company_and_associated_stock_quotes(company)
          else
            render_company_not_found_error
          end
        end
      end

      private

      def upcase_ticker
        params[:ticker] = params[:ticker]&.upcase
      end
      def limit
        [
          params.fetch(:limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end

      def company_params
        params.permit(:ticker, :name, :origin_country)
      end

      def handle_cannot_find_company
        render json: { error: "Company with ticker #{params[:ticker]} not found" }, status: :not_found
      end
      def handle_record_invalid(error)
        error_message = error.record.errors.full_messages.join(", ")
        render json: { error: error_message }, status: :unprocessable_entity
      end

      def handle_lock_wait_timeout
        render json: { error: 'Failed to acquire lock on the company record' }, status: :unprocessable_entity
      end

      def find_company_by_ticker(ticker)
        Company.find_by('LOWER(ticker) = LOWER(?)', ticker)
      end

      def destroy_company_and_associated_stock_quotes(company)
        ActiveRecord::Base.transaction do
          company.lock!
          stock_quotes = company.stock_quotes.lock(true)
          stock_quotes.lock!
          stock_quotes.destroy_all
          company.destroy
          head :no_content
        end
      end

      def render_company_not_found_error
        render json: { error: "Company with ticker #{params[:ticker]} not found" }, status: :not_found
      end
    end
  end
end
