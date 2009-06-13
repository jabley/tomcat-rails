require File.dirname(__FILE__) + '/../spec_helper'

describe TomcatRails::Server
  before do
    @tomcat = TomcatRails::Tomcat::Tomcat.new
    @web_app = @tomcat.addWebapp('/', File.dirname(__FILE__) + '/../../')
  end

end