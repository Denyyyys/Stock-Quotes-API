def integer_string?(str)
  Integer(str) rescue false
end

def validate_pagination_params
  pagination_params = [:limit, :offset]
  pagination_params.each do |param_name|
    validate_pagination_param(param_name)
  end
end

def validate_pagination_param(param_name)
  if params[param_name].present?
    unless integer_string?(params[param_name]) && params[param_name].to_i > 0
      render json: { error: "#{param_name.capitalize} parameter must be a positive integer or not be present" }, status: :unprocessable_entity
    end
  end
end