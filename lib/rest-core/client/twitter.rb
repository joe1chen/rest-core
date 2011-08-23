
require 'rest-core'

RestCore::Twitter = RestCore::Builder.client(:data) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.twitter.com/1/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}

  use s::Oauth1Header  ,
    'oauth/request_token', 'oauth/access_token', 'oauth/authorize'

  use s::CommonLogger  , method(:puts)

  use s::Cache         , {}, 3600 do
    use s::ErrorHandler  , lambda{ |env|
      if (body = env[s::RESPONSE_BODY]).kind_of?(Hash)
        raise body['error']
      else
        raise body
      end
    }
    use s::ErrorDetectorHttp
    use s::JsonDecode    , true
    run s::Ask
  end

  use s::Defaults      , :data     => lambda{{}}

  run s::RestClient
end

module RestCore::Twitter::Client
  include RestCore

  def oauth_token
    data['oauth_token'] if data.kind_of?(Hash)
  end
  def oauth_token= token
    data['oauth_token'] = token if data.kind_of?(Hash)
  end
  def oauth_token_secret
    data['oauth_token_secret'] if data.kind_of?(Hash)
  end
  def oauth_token_secret= secret
    data['oauth_token_secret'] = secret if data.kind_of?(Hash)
  end

  def tweet status, queries={}, opts={}
    post('statuses/update.json',
      {:status => status}.merge(queries), opts)
  end

  def statuses user, queries={}, opts={}
    get('statuses/user_timeline.json', {:id => user}.merge(queries), opts)
  end

  private
  def set_token query
    self.data = query
  end
end

RestCore::Twitter.send(:include, RestCore::ClientOauth1)
RestCore::Twitter.send(:include, RestCore::Twitter::Client)
