module ApiCall
  class Base
    def initialize(url:, headers:, method:, params: nil, body: nil)
      @url = url
      @headers = headers
      @method = method
      @params = params
      @body = body
    end
  end
end
