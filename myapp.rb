# myapp.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'
require 'net/https'
require 'uri'




class MySinatraApp < Sinatra::Base

  register Sinatra::CrossOrigin

  set :bind, '0.0.0.0'

  configure do
    enable :cross_origin
  end

  before do
  	request.body.rewind
  	@request_payload = JSON.parse request.body.read
  end

  options "*" do
  	response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
 
  	response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
 
  	200
  end

  get '/' do
    'Hello world!'
  end

  post '/analyzer' do
  	cross_origin
    paragraph = @request_payload['text'].to_s
  	sentences = paragraph.scan(/[^\.!?]+[\.!?]/).map(&:strip)

  	#http://wluo-mn1.linkedin.biz:5000/parse?q=tell me where is it&project=test_model12

  	uri = URI('http://wluo-mn1.linkedin.biz:5000/parse')
	params = { :q => sentences.last.to_s, :project => "test_model12" }
	uri.query = URI.encode_www_form(params)

	res = Net::HTTP.get_response(uri)
	    if res.is_a?(Net::HTTPSuccess)
			data = JSON.parse(res.body)
			intent = data['intent']['name']
			confidence = data['intent']['confidence']
			puts '============'
			puts intent
			puts confidence
			if intent == 'interview' && confidence > 0.6
				puts 'there'
				true.to_json
			else 
				puts 'here'
				false.to_json
			end
		else 
			false.to_json
	    end
  	end   
end

