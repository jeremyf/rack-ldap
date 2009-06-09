require 'rack'

class Rack::Ldap
  attr_reader :app
  
  def initialize(app, options ={})
    @app = app
  end
  
  def call(env)
    
  end
end