module Curler
  def self.curl(uri, conf = nil)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    user = conf ? conf[:user] : nil
    pass = conf ? conf[:pass] : nil
    request.basic_auth(user, pass) if user && pass
    response = http.request(request)
  end
end
