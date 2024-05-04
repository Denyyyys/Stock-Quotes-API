# frozen_string_literal: true

require 'time'

def integer_string?(str)
  Integer(str)
rescue StandardError
  false
end

def validate_pagination_params
  pagination_params = %i[limit offset]
  pagination_params.each do |param_name|
    validate_pagination_param(param_name)
  end
end

def validate_pagination_param(param_name)
  return unless params[param_name].present?
  return if integer_string?(params[param_name]) && params[param_name].to_i.positive?

  render json: { error: "#{param_name.capitalize} parameter must be a positive integer or not be present" },
         status: :unprocessable_entity
end

def valid_timestamp?(timestamp)
  Time.parse(timestamp)
  true
rescue ArgumentError, TypeError
  false
end
