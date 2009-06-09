# $ rackup sinatra_example.ru
require 'pathname'
root = Pathname(__FILE__).dirname.parent.expand_path
$:.unshift(root + 'lib')
 
require 'rubygems'
require 'rack'
require 'rack/ldap'
require 'yaml'
gem 'ruby-net-ldap'
require File.dirname(__FILE__) + '/sinatra_example'

use Rack::Session::Cookie
use Rack::Ldap, YAML.load_file(File.join(Pathname(__FILE__).dirname.expand_path, 'ldap.yml'))
run Sinatra::Application
