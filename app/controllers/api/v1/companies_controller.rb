module Api
  module V1
    class CompaniesController < ApplicationController
      def index
        companies = Company.all
        render json: companies
      end

      def show
      end
      def create
      end

      def destroy
      end
    end
  end
end
