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
          if integer_string?(params[:id])
            # binding.irb
            stock_quote_id = integer_string?(params[:id])
            stock_quote = StockQuote.find(stock_quote_id)
            stock_quote.lock!
            stock_quote.destroy
            head :no_content
          else
            render json: {error: "Id of stock quote should be positive integer! Provided: #{params[:id]}"}
          end
        end
      end

      def delete_all_by_ticker # delete all stock quotes of specific company
      end

      def create # create new stock quote
      end

      def update # update stock quote
      end

      def show # get one stock quote with id
      end

      private
      def handle_cannot_find_stock_quote(e)
        render json: { error: "Cannot find stock quote with id: #{e.id}" }, status: :unprocessable_entity
      end

      def handle_lock_wait_timeout
        render json: { error: "Failed to acquire lock on the stock quote record" }, status: :unprocessable_entity
      end
    end
  end
end

