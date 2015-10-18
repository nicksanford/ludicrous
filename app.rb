module App
  def self.call(env)
    puts Rack::Request.new(env).params
    [200, { 'Content-Type' => 'text/plain' }, StringIO.new(Rack::Request.new(env).params.to_s)]  
  end
end
