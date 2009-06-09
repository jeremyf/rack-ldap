require 'rubygems'
require 'sinatra'


# gem 'rack-ldap'
require 'rack/ldap'

# gem 'josh-memcache_openid_store'
# require 'openid/store/memcache'
# 
# use Rack::OpenID, OpenID::Store::Memcache.new

get '/login' do
  erb :login
end

post '/login' do
  if resp = request.env["rack.ldap.response"]
    if resp.status == :success
      "Welcome: #{resp.display_identifier}"
    else
      "Error: #{resp.status}"
    end
  else
    headers Rack::Ldap::AUTHENTICATE_HEADER => Rack::Ldap.build_header(
      :username => params['username'],
      :password => params['password']
    )
    throw :halt, [401, 'got ldap?']
  end
end

use_in_file_templates!

__END__

@@ login
<form action="/login" method="post">
  <p>
    <label for="username">Username:</label>
    <input id="username" name="username" type="text" />
  </p>
  <p>
    <label for="password">Password:</label>
    <input id="password" name="password" type="password" />
  </p>

  <p>
    <input name="commit" type="submit" value="Sign in" />
  </p>
</form>
