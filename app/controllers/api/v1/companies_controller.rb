module Api
  module V1
    class CompaniesController < ApplicationController
      def index
        companies = Company.all
        render json: companies, each_serializer: CompanySerializer
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
