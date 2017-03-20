module Helpers
  def parsed_response
    JSON.parse(last_response.body)
  end
end
