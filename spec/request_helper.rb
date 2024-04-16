module RequestHelper
  def response_body
    JSON.parse(response.body)
  end

  def response_body_without_id
    response_body.except("id")
  end
end