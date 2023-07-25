module ApiCall
  class Generic < Base
    def self.build_request
      Typhoeus::Request.new(@url, method: @method, params: @params, body: @body, headers: @headers)
    end
  end
end
