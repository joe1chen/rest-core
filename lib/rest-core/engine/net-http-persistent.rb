
require 'net/http/persistent'
require 'rest-core/engine'

class RestCore::NetHttpPersistent < RestCore::Engine
  def request promise, env
    http = ::Net::HTTP::Persistent.new
    http.open_timeout, http.read_timeout = calculate_timeout(env[TIMER])
    payload, headers = payload_and_headers(env)

    uri = ::URI.parse(env[REQUEST_URI])
    req = ::Net::HTTP.const_get(env[REQUEST_METHOD].to_s.capitalize).
            new(uri, headers)
    req.body_stream = payload
    res = http.request(uri, req)

    promise.fulfill(res.body, res.code.to_i, normalize_headers(res.to_hash))
  rescue Exception => e
    promise.reject(e)
  end
end
