# frozen_string_literal: true

# Serializer for the Company model
class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :ticker, :origin_country
end
