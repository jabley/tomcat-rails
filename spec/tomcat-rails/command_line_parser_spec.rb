require File.dirname(__FILE__) + '/../spec_helper'

describe TomcatRails::CommandLineParser do
  it "should override classes option" do
    ARGV = "--classes my_classes".split
    
    options = TomcatRails::CommandLineParser.parse
    options[:classes_dir].should == 'my_classes'
  end
  
  it "should override libs option with lib option" do
    ARGV = "--lib my_libs".split
    
    options = TomcatRails::CommandLineParser.parse
    options[:libs_dir].should == 'my_libs'
  end
  
  it "should override libs option with jar option" do
    ARGV = "--jars my_jars".split
    
    options = TomcatRails::CommandLineParser.parse
    options[:libs_dir].should == 'my_jars'
  end
end