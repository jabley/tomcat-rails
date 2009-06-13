module TomcatRails
  class Server
    
    @@defaults = {
      :environment => 'development',
      :context_path => '/',
      :libs_dir => 'lib',
      :classes_dir => 'classes',
      :port => 3000,
      :jruby_min_runtimes => 1,
      :jruby_max_runtimes => 5
    }
    
    def initialize(config = {})
      @config = @@defaults.merge!(config)
      @config[:web_app_dir] = Dir.pwd
      
      @tomcat = TomcatRails::Tomcat::Tomcat.new
      @tomcat.setPort(@config[:port].to_i)
      
      create_web_app      
    end
    
    def create_web_app
      web_app = WebApp.new(@tomcat.addWebapp(@config[:context_path].to_s, @config[:web_app_dir]), @config)
      
      web_app.add_rack_filter
      web_app.add_context_loader
      web_app.add_init_params
      web_app.add_web_dir_resources
      
      web_app.add_rack_context_listener
    end

    def start
      @tomcat.start
      @tomcat.getServer().await
    end
  end
end