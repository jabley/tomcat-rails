module TomcatRails
  require 'optparse'
  
  class CommandLineParser
    def self.parse
      default_options = {
        :port => 3000,
        :environment => 'development',
        :context_path => '/',
        :libs_dir => 'lib',
        :classes_dir => 'classes',
        :config => 'config/tomcat.yml'
      }
      
      parser = OptionParser.new do |opts|
        opts.banner = 'Tomcat server default options:'
        opts.separator ''

        opts.on('-e', '--env ENVIRONMENT', 'Rails environment', 
            "default: #{default_options[:environment]}") do |v| 
          default_options[:environment] = v
        end
        
        opts.on('-p', '--port PORT', 'Port to bind to', 
            "default: #{default_options[:port]}") do |v| 
          default_options[:port] = v
        end
        
        opts.on('-c', '--context CONTEXT_PATH', 'The application context path', 
            "default: #{default_options[:context_path]}") do |v| 
          default_options[:context_path] = v
        end
        
        opts.on('--lib', '--jars LIBS_DIR', 'Directory containing jars used by the application', 
            "default: #{default_options[:libs_dir]}") do |v| 
          default_options[:libs_dir] = v
        end
        
        opts.on('--classes', '--classes CLASSES_DIR', 'Directory containing classes used by the application', 
            "default: #{default_options[:classes_dir]}") do |v| 
          default_options[:classes_dir] = v
        end        

        opts.on('-f', '--config [CONFIG_FILE]', 'Configuration file',
            "default: #{default_options[:config]}") do |v|
          default_options[:config] = v if v
          default_options.merge! YAML.load_file(default_options[:config])
        end
        
        opts.on('-v', '--version', 'display the current version') do
          puts File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION')).chomp
          exit
        end
        
        opts.on('-h', '--help', 'display the help') do
          puts opts
          exit
        end
          
        opts.parse!(ARGV)
      end
      
        default_options
    end
  end
end