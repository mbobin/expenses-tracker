require "json"
require "ox"

module Responder
  def self.build(request)
    klass = TYPES[request.env['CONTENT_TYPE']]
    klass && klass.new
  end

  class Json
    TYPE = "application/json"

    def content_type
      TYPE
    end

    def deserialize(args)
      JSON.parse(args)
    end

    def serialize(args)
      JSON.generate(args)
    end
  end

  class Xml
    TYPE = "application/xml"

    def content_type
      TYPE
    end

    def deserialize(args)
      Ox.parse_obj(args)
    end

    def serialize(args)
      Ox.dump(args)
    end
  end

  TYPES = {
    Json::TYPE => Json,
    Xml::TYPE => Xml
  }
end
