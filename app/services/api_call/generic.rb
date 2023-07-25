module ApiCall
  class Generic < Base
    def build_request
      Typhoeus::Request.new(@url, method: @method, params: @params, body: @body, headers: @headers)
    end

    def self.call
      build_request.run
    end
  end
end
