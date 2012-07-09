require "rubygems"
require "bundler/setup"
require "sinatra"
require "erb"
require "models/anagram"
require "services/storage"
require 'rack-flash'

use Rack::Flash
enable :sessions


get '/' do
  if session[:uploaded].nil?
    flash[:notice] = "We notice you have not uploaded an anagramer file yet!"
    redirect '/upload'
  else
    anagram = Anagram.new(session)
    @results = anagram.results
    erb :results
  end
end

post '/guess' do
  anagram = Anagram.new(session)
  result = anagram.guess(params['word'])
  if result
    flash[:notice] = "Awesome! Your word retrieved '" + result.join(", ") + "' as anagram match/es"
  else
    flash[:notice] = "Bummer! Your word didn't retrieve an anagram..."
  end
  redirect '/'
end

get '/upload' do
  erb :upload
end

post '/upload' do
  anagram = Anagram.new(session)
  anagram.upload params
  flash[:notice] = "Your anagramer list has been added, please guess an anagram!"
  redirect '/'
end