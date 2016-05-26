require "./success_response"

module JSONApi
  class ResourceResponse(T) < SuccessResponse
    @included : Array(Resource)?

    def initialize(
      @resource : T?,
      self_link : String? = nil,
      included = nil
    )
      super(200)
      @self_link = self_link || @resource.try {
        "#{API_ROOT}/#{resource.type}/#{resource.id}"
      }
      @included = included.try &.map &.as(Resource)
    end

    protected def serialize_data(object, io)
      object.field(:data, @resource)
    end

    protected def serialize_links(object, io)
      return unless self_link = @self_link
      object.field(:links) do
        io.json_object do |object|
          object.field(:self, self_link)
        end
      end
    end
  end
end
