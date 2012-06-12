# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'mail'

set :haml, :format => :html5, :escape_html => true

configure :production do 
	before do 
		cache_control :public, :max_age => 24*3600 
		Mail.defaults do
			delivery_method :smtp, { 
				:address        => "smtp.sendgrid.net",
				:port           => "25",
				:authentication => :plain,
				:user_name      => ENV['SENDGRID_USERNAME'],
				:password       => ENV['SENDGRID_PASSWORD'],
				:domain         => ENV['SENDGRID_DOMAIN']
			}
		end
	end
end

configure :development do
	before do
		cache_control :no_store
		Mail.defaults do
			delivery_method :test
		end
	end
end

before do 
  if request.host == 'dmks.se'
    halt redirect "http://www.dmks.se#{request.path}"
  end
	content_type :html, :charset => 'utf-8'
	@title = "DMKS - Digitalt medlems kort system"
	@menu = [
		['/', 'DMKS'],
		['/funktioner', 'Funktioner'],
		['/rundtur', 'Rundtur'],
		['/anpassa', 'Anpassa'],
		['/testa', 'Testa'],
		['/faq', 'Frågor'],
	]
end

get '/' do
	last_modified File.mtime "./views/index.haml"
	haml :index
end

get '/:page' do |page|
	pass unless File.exists? "./views/#{page}.haml"
	last_modified File.mtime "./views/#{page}.haml"
	@title = page.capitalize.gsub(/_/, ' ') + " - " + @title
	haml page.to_sym
end

get '/mail' do
	subj = "#{params[:subject]} #{params[:company]}" if params[:company]
	subj = "#{params[:subject]}}" 
	body = params.inspect
	Mail.deliver do
		from 'homepage@dmks.se'
		to 'info@mon7.se'
		subject subj
		body body
	end
	redirect '/felrapport_skickat' unless params[:company]
	redirect '/mail_skickat'
end

get 'mail_skickat' do
	haml :mail_skickat
end

not_found do
	haml :not_found
end
