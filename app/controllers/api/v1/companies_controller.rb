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
        companies = Company.limit(limit).offset(params[:offset])
        render json: companies
      end

      def show
        company = Company.find_by(ticker: params[:ticker])
        raise ActiveRecord::RecordNotFound unless company
        render json: company
      end

      def create
        company = Company.new(company_params)
        if company.save
          render json: company, status: :created
        else
          render json: { error: company.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      def destroy
        company = find_company_by_ticker(params[:ticker])
        if company
          destroy_company_and_associated_stock_quotes(company)
        else
          render_company_not_found_error
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
        render json: { error: error.message }, status: :unprocessable_entity
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
