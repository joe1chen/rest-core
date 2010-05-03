
require 'rest-graph'

require 'rr'
require 'webmock'
require 'bacon'

include RR::Adapters::RRMethods
include WebMock
WebMock.disable_net_connect!
Bacon.summary_on_exit

describe RestGraph do
  before do
    reset_webmock
  end

  it 'would build correct headers' do
    rg = RestGraph.new(:accept => 'text/html',
                       :lang   => 'zh-tw')
    rg.send(:build_headers).should == {'Accept'          => 'text/html',
                                       'Accept-Language' => 'zh-tw'}
  end

  it 'would build empty query string' do
    RestGraph.new.send(:build_query_string).should == ''
  end

  it 'would create access_token in query string' do
    RestGraph.new(:access_token => 'token').send(:build_query_string).
      should == '?access_token=token'
  end

  it 'would build correct query string' do
    RestGraph.new(:access_token => 'token').send(:build_query_string,
                                                 :message => 'hi!!').
      should == '?access_token=token&message=hi%21%21'

    RestGraph.new.send(:build_query_string, :message => 'hi!!',
                                            :subject => '(&oh&)').
      should == '?message=hi%21%21&subject=%28%26oh%26%29'
  end

  it 'would request to correct server' do
    stub_request(:get, 'http://nothing.godfat.org/me').with(
      :headers => {'Accept'          => 'text/plain',
                   'Accept-Language' => 'zh-tw',
                   'Accept-Encoding' => 'gzip, deflate', # this is by ruby
                   'User-Agent'      => 'Ruby'}).        # this is by ruby
      to_return(:body => '{"data": []}')

    RestGraph.new(:server => 'http://nothing.godfat.org',
                  :lang   => 'zh-tw',
                  :accept => 'text/plain').get('me').should == {'data' => []}
  end
end