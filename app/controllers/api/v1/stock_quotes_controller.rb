require_relative '../../../utilities/utility_methods'
module Api
  module V1
    class StockQuotesController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :handle_cannot_find_stock_quote
      rescue_from ActiveRecord::LockWaitTimeout, with: :handle_lock_wait_timeout

      def get_by_ticker # get all stock quotes of specific company
        company = Company.find_by("LOWER(ticker) = LOWER(?)", params[:ticker])
        if company
          stock_quotes = company.stock_quotes.sort_by { |quote| quote.updated_at }.reverse
          render json: stock_quotes
        else
          render json: { error: "Company with ticker '#{params[:ticker]}' not found" }, status: :not_found
        end
      end

      def destroy # delete one stock quote by id
        ActiveRecord::Base.transaction do
          if integer_string?(params[:id]) && Integer(params[:id]) > 0
            stock_quote_id = integer_string?(params[:id])
            stock_quote = StockQuote.find(stock_quote_id)
            stock_quote.lock!
            stock_quote.destroy
            head :no_content
          else
            render json: {error: "Id of stock quote should be positive integer! Provided: #{params[:id]}"}, status: :unprocessable_entity
          end
        end
      end

      def delete_all_by_ticker # delete all stock quotes of specific company, but not company
        ActiveRecord::Base.transaction do
          company = Company.lock.find_by("LOWER(ticker) = LOWER(?)", params[:ticker])
          if company
            stock_quotes = company.stock_quotes.lock(true)
            stock_quotes.destroy_all
            head :no_content
          else
            render json: { error: "Company with ticker '#{params[:ticker]}' not found" }, status: :not_found
          end
        end
      end

      def create
        # binding.irb
        render_blank_ticker_error && return if params[:ticker].blank?

        render_invalid_timestamp_error(params[:created_at]) && return if stock_quote_params.key?(:created_at) && !valid_timestamp(stock_quote_params[:created_at])

        company = Company.lock.find_by(ticker: params[:ticker])
        if company
          stock_quote = build_stock_quote(company)
          save_stock_quote(stock_quote)
        else
          render_company_not_found_error
        end
      end

      def update
        unless integer_string?(params[:id]) && Integer(params[:id]) > 0
          render json: {error: "Id of stock quote should be positive integer! Provided: #{params[:id]}"}, status: :unprocessable_entity
          return
        end
        if params.key?(:created_at) && !valid_timestamp(params[:created_at])
          render_invalid_timestamp_error(params[:created_at])
          return
        end

        new_params = stock_quotes_update_params
        stock_quote_id = integer_string?(params[:id])

        ActiveRecord::Base.transaction do
          stock_quote = StockQuote.lock.find(stock_quote_id)
          if params[:ticker].present?
            company = Company.lock.find_by("LOWER(ticker) = LOWER(?)", params[:ticker])
            if company
              new_params = new_params.merge({company_id: company.id})
            else
              render json: { error: "Company with ticker '#{params[:ticker]}' not found" }, status: :not_found
              return
            end
          end
          if stock_quote.update(new_params)
            render json: stock_quote, status: :ok
            return
          else
            render json: { error: stock_quote.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end
      end

      def show
        if integer_string?(params[:id]) && Integer(params[:id]) > 0
          id = Integer(params[:id])
          found_stock_quote = StockQuote.find(id)
          render json: found_stock_quote
        else
          render json: {error: "Id of stock quote should be positive integer! Provided: #{params[:id]}"}, status: :unprocessable_entity
        end
      end

      private
      def handle_cannot_find_stock_quote(e)
        render json: { error: "Cannot find stock quote with id: #{e.id}" }, status: :not_found
      end

      def handle_lock_wait_timeout
        render json: { error: "Failed to acquire lock on the stock quote record" }, status: :unprocessable_entity
      end

      def stock_quote_params
        params.permit(:price, :created_at)
      end

      def stock_quotes_update_params
        params.permit(:price, :created_at)
      end

      def build_stock_quote(company)
        merged_params = { company_id: company.id }
        merged_params[:updated_at] = stock_quote_params[:created_at] if stock_quote_params.key?(:created_at)
        StockQuote.new(stock_quote_params.merge(merged_params))
      end

      def save_stock_quote(stock_quote)
        if stock_quote.save
          render json: stock_quote, status: :created
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
        render json: { error: "Company with ticker: '#{params[:ticker]}' could not be found!" }, status: :not_found
      end

      def render_blank_stock_quote_id
        render json: { error: "Stock quote id can't be blank!" }, status: :unprocessable_entity
      end
    end
  end
end

