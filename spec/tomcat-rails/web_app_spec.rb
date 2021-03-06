require File.dirname(__FILE__) + '/../spec_helper'

describe TomcatRails::WebApp do
  before do
    @tomcat = TomcatRails::Tomcat::Tomcat.new
    tomcat_web_app = @tomcat.addWebapp('/', File.dirname(__FILE__) + '/../../')
    config = { 
      :libs_dir => 'lib',
      :classes_dir => 'classes',
      :default_web_xml => 'config/web.xml',
      :web_app_dir => File.join(File.dirname(__FILE__), '..', 'web_app_mock')
    }
    @web_app = TomcatRails::WebApp.new(tomcat_web_app, config)
  end
  
  it "should load custom jars" do 
    class_loader = org.jruby.util.JRubyClassLoader.new(JRuby.runtime.jruby_class_loader)
    @web_app.add_application_libs(class_loader)
    
    resource = class_loader.find_class('org.ho.yaml.Yaml')
    resource.should_not == nil
  end

  it "should load custom classes" do
    class_loader = org.jruby.util.JRubyClassLoader.new(JRuby.runtime.jruby_class_loader)
    @web_app.add_application_classes(class_loader)
    
    resource = class_loader.find_class('HelloTomcat')
    resource.should_not == nil    
  end

  it "should start application context without errors" do
    load_tomcat_libs
    lambda { @web_app.context.start }.should_not raise_error
  end

  it "should add a filter from the default web.xml" do
    load_tomcat_libs
    @web_app.load_default_web_xml
    lambda { @web_app.context.start }.should_not raise_error
    @web_app.context.findFilterDefs().size().should == 1
  end

  def load_tomcat_libs
    @web_app.config[:libs_dir] = File.join(File.dirname(__FILE__), '..', '..', 'tomcat-libs')
    @web_app.add_context_loader
  end
  
end