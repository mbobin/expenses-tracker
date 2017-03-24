module Helpers
  def parsed_response
    JSON.parse(last_response.body)
  end

  def parsed_xml_response
    Ox.parse_obj(last_response.body)
  end
end
