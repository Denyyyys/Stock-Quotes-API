# frozen_string_literal: true

require_relative '../../../utilities/utility_methods'
module Api
  module V1
    # Controller for handling API endpoints related to the stock quotes
    class StockQuotesController < ApplicationController
      attr_reader :companiesService

      def initialize(companiesService = CompaniesService.new)
        @companiesService = companiesService
        super()
      end


      rescue_from ActiveRecord::RecordNotFound, with: :handle_cannot_find_stock_quote
      rescue_from ActiveRecord::LockWaitTimeout, with: :handle_lock_wait_timeout
      rescue_from ActiveRecord::Deadlocked, with: :handle_deadlock
      rescue_from ActiveRecord::RecordInvalid, with: :handle_bad_record

      # get all stock quotes of specific company
      def by_ticker
        company = Company.find_by('LOWER(ticker) = LOWER(?)', params[:ticker])
        if company
          company.lock!
          stock_quotes = company.stock_quotes.sort_by(&:updated_at).reverse
          render json: stock_quotes
        else
          render_company_not_found_error
        end
      end

      # delete one stock quote by id
      def destroy
        ActiveRecord::Base.transaction do
          stock_quote = StockQuote.lock.find(params[:id])
          stock_quote.destroy
          head :no_content
        end
      end

      def delete_all_by_ticker
        ActiveRecord::Base.transaction do
          company = Company.lock.find_by('LOWER(ticker) = LOWER(?)', params[:ticker])
          if company
            stock_quotes = company.stock_quotes.lock(true)
            stock_quotes.destroy_all
            head :no_content
          else
            render_company_not_found_error
          end
        end
      end

      def create
        max_attempts = 3
        attempts = 0
        valid_params_create_stock_quote
        return if performed?
        upcase_ticker
        begin
          attempts += 1
          ActiveRecord::Base.transaction(isolation: :read_committed) do
            company = @companiesService.get_or_create_company_by_ticker(params[:ticker])
            save_stock_quote_and_render(build_stock_quote(company))
          end
        rescue Exception => e
          retry if attempts < max_attempts
          render json: {error: e.message}, status: :unprocessable_entity
        end
      end

      def update
        if params.key?(:created_at) && !valid_timestamp?(params[:created_at])
          return render_invalid_timestamp_error(params[:created_at])
        end

        ActiveRecord::Base.transaction do
          stock_quote = StockQuote.lock.find(params[:id])
          company = find_company(stock_quote)
          return render_company_not_found_error unless company

          update_and_render_stock_quote(stock_quote, company)
        end
      end

      def show
        found_stock_quote = StockQuote.find(params[:id])
        render json: found_stock_quote
      end

      private

      def handle_cannot_find_stock_quote(err)
        render json: { error: "Cannot find stock quote with id #{err.id}" }, status: :not_found
      end

      def handle_lock_wait_timeout
        render json: { error: 'Failed to acquire lock on the stock quote record' }, status: :unprocessable_entity
      end

      def handle_deadlock
        render json: { error: 'Sorry, there was a database deadlock. Please try again later.' },
               status: :internal_server_error
      end

      def handle_bad_record(e)
        return render json: { error: e.to_s }, status: :unprocessable_entity
      end

      def stock_quote_params
        params.permit(:price, :created_at)
      end

      def upcase_ticker
        params[:ticker] = params[:ticker]&.upcase
      end

      def stock_quotes_update_params
        params.permit(:price, :created_at)
      end

      def valid_params_create_stock_quote
        return render_blank_ticker_error if params[:ticker].blank?

        return unless stock_quote_params.key?(:created_at) && !valid_timestamp?(stock_quote_params[:created_at])

        render_invalid_timestamp_error(params[:created_at])
      end

      def build_stock_quote(company)
        merged_params = { company_id: company.id }
        merged_params[:updated_at] = stock_quote_params[:created_at] if stock_quote_params.key?(:created_at)
        StockQuote.new(stock_quote_params.merge(merged_params))&.lock!
      end

      def save_stock_quote_and_render(stock_quote)
        if stock_quote.save
          render json: stock_quote, status: :created
        else
          render json: { error: stock_quote.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      def find_company(stock_quote)
        if params[:ticker].present?
          find_company_by_ticker(params[:ticker])
        else
          find_company_by_id(stock_quote)
        end
      end

      def find_company_by_ticker(ticker)
        Company.lock.find_by('LOWER(ticker) = LOWER(?)', ticker)
      end

      def find_company_by_id(stock_quote)
        Company.lock.find(stock_quote.company_id)
      end

      def update_and_render_stock_quote(stock_quote, company)
        if stock_quote.update(stock_quotes_update_params)
          stock_quote.company = company
          stock_quote.save
          render json: stock_quote, status: :ok
        else
          render json: { error: stock_quote.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      def render_blank_ticker_error
        render json: { error: "Ticker can't be blank!" }, status: :unprocessable_entity
      end

      def render_invalid_timestamp_error(timestamp)
        render json: { error: "Provided timestamp is invalid! Provided: #{timestamp}" }, status: :unprocessable_entity
      end

      def render_company_not_found_error
        render json: { error: "Company with ticker #{params[:ticker]} not found!" }, status: :not_found
      end

      def render_blank_stock_quote_id
        render json: { error: "Stock quote id can't be blank!" }, status: :unprocessable_entity
      end
    end
  end
end
