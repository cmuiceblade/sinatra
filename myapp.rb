# myapp.rb
require 'sinatra'
require 'net/http'
require 'net/https'
require 'uri'


class MySinatraApp < Sinatra::Base

  before do
  	request.body.rewind
  	@request_payload = JSON.parse request.body.read
  end

  get '/' do
    'Hello world!'
  end

  post '/analyzer' do
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
			if intent == 'interview' && confidence > 0.5
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

