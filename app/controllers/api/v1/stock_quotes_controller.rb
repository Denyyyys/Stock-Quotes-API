module Api
  module V1
    class StockQuotesController < ApplicationController
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
      end

      def delete_all_by_ticker # delete all stock quotes of specific company
      end

      def create # create new stock quote
      end

      def update # update stock quote
      end

      def show # get one stock quote with id
      end
    end
  end
end

