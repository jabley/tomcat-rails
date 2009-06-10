module TomcatRails
  class Server
    
    @@defaults = {
      :environment => 'development',
      :context_path => '/',
      :lib_dir => 'lib',
      :classes_dir => 'classes',
      :port => 3000,
      :jruby_min_runtimes => 1,
      :jruby_max_runtimes => 5
    }
    
    def initialize(config = {})
      @config = config.merge!(@@defaults)
      
      @tomcat = TomcatRails::Tomcat::Tomcat.new
      @tomcat.setPort(@config[:port])
      
      web_app = @tomcat.addWebapp(@config[:context_path], Dir.pwd)
      
      add_rack_filter(web_app, @config[:context_path])      
      add_context_loader(web_app)
      add_init_params(web_app)
      add_web_dir_resources(web_app)
      
      web_app.addApplicationListener('org.jruby.rack.rails.RailsServletContextListener')
    end

    def start
      @tomcat.start
      @tomcat.getServer().await
    end
   
    private 
    def add_rack_filter(web_app, context_path)
      filter_def = TomcatRails::Tomcat::FilterDef.new
      filter_def.setFilterName('RackFilter')
      filter_def.setFilterClass('org.jruby.rack.RackFilter')
      
      pattern = context_path[-1..-1] != '/' ? context_path : context_path[0..-2]
      filter_map = TomcatRails::Tomcat::FilterMap.new
      filter_map.setFilterName('RackFilter')
      filter_map.addURLPattern("#{pattern}/*")
      
      web_app.addFilterDef(filter_def)
      web_app.addFilterMap(filter_map)
    end
    
    def add_context_loader(web_app)
      class_loader = org.jruby.util.JRubyClassLoader.new(JRuby.runtime.jruby_class_loader)
      loader = TomcatRails::Tomcat::WebappLoader.new(class_loader)

      loader.container = web_app
      web_app.loader = loader
    end
    
    def add_init_params(web_app)
      [:jruby_min_runtimes, :jruby_max_runtimes].each do |param|
        web_app.addParameter(param.to_s.gsub(/_/, '.'), @config[param].to_s)
      end
      
      web_app.addParameter('jruby.initial.runtimes', @config[:jruby_min_runtimes].to_s)
      web_app.addParameter('rails.env', @config[:environment].to_s)
      web_app.addParameter('rails.root', '/')
    end
    
    def add_web_dir_resources(web_app)
      dir_context = TomcatRails::Tomcat::FileDirContext.new
      dir_context.setDocBase(File.join(Dir.pwd, "public"))
      
      web_app.setResources(dir_context)
    end
  end
end