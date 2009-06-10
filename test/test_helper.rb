require 'rubygems'
require 'test/unit'
require 'shoulda'

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../jetty-libs')

require 'tomcat-rails'

class Test::Unit::TestCase
end
