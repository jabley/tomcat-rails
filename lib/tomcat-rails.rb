$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "java"
require 'rubygems'

require 'tomcat-rails/command_line_parser'
require 'tomcat-rails/jars'
require 'tomcat-rails/server'

module TomcatRails
  TOMCAT_LIBS = File.dirname(__FILE__) + "/../tomcat-libs" unless defined?(TOMCAT_LIBS)
end