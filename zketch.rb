require 'sinatra'
require 'redis'
require 'digest'

before do
  @redis = Redis.new
end

get '/' do
  if @redis.llen('sketches') == 0
    redirect 'upload'
  else
    id = @redis.lindex('sketches', 0)
    redirect id
  end
end

get '/upload' do
  erb :upload
end

get '/best' do
  ratings = {}
  @redis.lrange('sketches', 0, -1).each do |sketch|
    sum = @redis.lrange(sketch, 0, -1).map(&:to_f).reduce(&:+)
    rating = sum / @redis.llen(sketch).to_f if sum  
    ratings[sketch] = rating
  end
  
  puts ratings.values
  
  best = ratings.values.sort.last
  redirect ratings.keys.select{|key| ratings[key] == best }.first
end

get '/:id' do
  @filename = params[:id]
  sum = @redis.lrange(@filename, 0, -1).map(&:to_f).reduce(&:+)
  @rating =  sum / @redis.llen(@filename).to_f if sum
  sketches = @redis.lrange('sketches', 0, -1)
  index = sketches.find_index(@filename)
  puts index
  puts sketches
  if index
    @next = sketches[index + 1] if index < sketches.length - 1
    @prev = sketches[index - 1] if index > 0
  end
  erb :show
end

get '/:id/rating' do
  @filename = params[:id]
  sum = @redis.lrange(@filename, 0, -1).map(&:to_f).reduce(&:+)
  rating = sum / @redis.llen(@filename).to_f if sum
  "%.2f" % rating
end

post '/' do # upload
  file = params[:sketch][:tempfile]
  filename = ('a'...'z').to_a[0..7].shuffle.join
  File.open("public/#{filename}.jpg", 'w') { |f| f.write(file.read) }
  @redis.lpush('sketches', filename)
  redirect filename
end

post '/:id' do
  @redis.lpush(params[:id], params[:rating])
  @filename = params[:id]
  sum = @redis.lrange(@filename, 0, -1).map(&:to_f).reduce(&:+)
  rating = sum / @redis.llen(@filename).to_f if sum
  "%.2f" % rating  
end