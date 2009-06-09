require 'rack'
require 'net/ldap'

class Rack::Ldap
  class Config
    attr_accessor :host, :encryption, :treebase, :encryption, :login_form_username_ldap_attribute, 
      :login_form_username_field, :login_form_password_field, :port
    def initialize(options = {})
      options.each { |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
      @encryption = @encryption.to_sym if @encryption
    end
  end
  attr_reader :app, :config
  AUTHENTICATE_HEADER = "WWW-Authenticate".freeze
  
  def self.build_header(params = {})
    value = 'LDAP '
    value += params.map { |k, v|
      if v.is_a?(Array)
        "#{k}=\"#{v.join(',')}\""
      else
        "#{k}=\"#{v}\""
      end
    }.join(', ')
    value
  end

  def self.parse_header(str)
    params = {}
    if str =~ /^LDAP /
      str = str.gsub(/^LDAP /, '')
      str.split(', ').each { |e|
        k, *v = e.split('=')
        v = v.join('=')
        v.gsub!(/^\"/, '').gsub!(/\"$/, "")
        v = v.split(',')
        params[k] = v.length > 1 ? v : v.first
      }
    end
    params
  end
  
  def initialize(app, config_options, options ={})
    @app = app
    @config = Config.new(config_options)
  end
  
  def call(env)
    req = Rack::Request.new(env)
    
    status, headers, body = @app.call(env)
    
    if status.to_i == 401 && (authentication_header_string = headers[AUTHENTICATE_HEADER])
      begin_authentication(env, authentication_header_string)
    else
      [status, headers, body]
    end
    
  end
  
  protected
  def begin_authentication(env, authentication_header_string)
    raise RuntimeError, "Rack::Ldap requires a session" unless session = env["rack.session"]
    if authenticate?(authentication_header_string)
      # Now what?
    else
      # And now what?
    end    
  end
  
  def authenticate?(authentication_header_string)
    params = self.class.parse_header(authentication_header_string)
    dn = ''
    ldap_con = Net::LDAP.new({:host => config.host, :encryption => config.encryption, :port => config.port}) 
    ldap_con.search(:base => config.treebase, :filter => Net::LDAP::Filter.eq(config.login_form_username_ldap_attribute, params[config.login_form_username_field]), :attributes=> 'dn') { |entry| dn = entry.dn }
    return false if dn.empty?
    ldap_con.auth(dn, params[config.login_form_password_field]) && ldap_con.bind
  end
end