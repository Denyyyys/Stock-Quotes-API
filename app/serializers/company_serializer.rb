class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :ticker, :origin_country
end
