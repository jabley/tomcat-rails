module TomcatRails
  class WebApp
    attr_reader :web_app, :config
    
    def initialize(web_app, config)
      @web_app = web_app
      @config = config
    end
    
    def add_rack_filter
      filter_def = TomcatRails::Tomcat::FilterDef.new
      filter_def.setFilterName('RackFilter')
      filter_def.setFilterClass('org.jruby.rack.RackFilter')
      
      pattern = @config[:context_path][-1..-1] != '/' ? @config[:context_path] : @config[:context_path][0..-2]
      filter_map = TomcatRails::Tomcat::FilterMap.new
      filter_map.setFilterName('RackFilter')
      filter_map.addURLPattern("#{pattern}/*")
      
      @web_app.addFilterDef(filter_def)
      @web_app.addFilterMap(filter_map)
    end
    
    def add_context_loader
      class_loader = org.jruby.util.JRubyClassLoader.new(JRuby.runtime.jruby_class_loader)
      add_application_libs(class_loader)
      
      loader = TomcatRails::Tomcat::WebappLoader.new(class_loader)

      loader.container = @web_app
      @web_app.loader = loader
    end
    
    def add_init_params
      [:jruby_min_runtimes, :jruby_max_runtimes].each do |param|
        @web_app.addParameter(param.to_s.gsub(/_/, '.'), @config[param].to_s)
      end
      
      @web_app.addParameter('jruby.initial.runtimes', @config[:jruby_min_runtimes].to_s)
      @web_app.addParameter('rails.env', @config[:environment].to_s)
      @web_app.addParameter('rails.root', '/')
      @web_app.addParameter('public.root', '/public')
      
    end
    
    def add_web_dir_resources
      @web_app.setDocBase(File.join(Dir.pwd, "public/"))
    end
    
    def add_rack_context_listener
      @web_app.addApplicationListener('org.jruby.rack.rails.RailsServletContextListener')
    end
    
    def add_application_libs(class_loader)
      lib_dir = "#{@config[:web_app_dir]}/#{@config[:lib_dir]}/**/*.jar"
      
      Dir[lib_dir].each do |jar|
        class_loader.addURL(java.io.File.new(jar).to_url)
      end
    end
  end
end