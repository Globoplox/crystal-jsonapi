require "./resource"
require "./success_response"

module JSONApi
  class ResourceCollectionResponse(T) < SuccessResponse
    @included : Array(T)

    def initialize(
      @resources : Array(T),
      @self_link : String = T.type,
      included = nil
    )
      {% unless JSONApi::Resource.all_subclasses.includes?(T) %}
        {% raise "resources must be an Enumerable of Resource, not #{T}" %}
      {% end %}
      @included = included.try &.map &.as(Resource)
    end

    protected def serialize_data(object, io)
      object.field(:data) do
        io.json_array do |array|
          @resources.each do |resource|
            array << resource
          end
        end
      end
    end

    protected def serialize_links(object, io)
      object.field(:links) do
        io.json_object do |object|
          object.field(:self, @self_link)
        end
      end
    end
  end
end
