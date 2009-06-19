module TomcatRails
  class WebApp
    attr_reader :context, :config
    
    def initialize(context, config)
      @context = context
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
      
      @context.addFilterDef(filter_def)
      @context.addFilterMap(filter_map)
    end
    
    def add_context_loader
      class_loader = org.jruby.util.JRubyClassLoader.new(JRuby.runtime.jruby_class_loader)
      add_application_libs(class_loader)
      add_application_classes(class_loader)
      
      loader = TomcatRails::Tomcat::WebappLoader.new(class_loader)

      loader.container = @context
      @context.loader = loader
    end
    
    def add_init_params
      [:jruby_min_runtimes, :jruby_max_runtimes].each do |param|
        @context.addParameter(param.to_s.gsub(/_/, '.'), @config[param].to_s)
      end
      
      @context.addParameter('jruby.initial.runtimes', @config[:jruby_min_runtimes].to_s)
      @context.addParameter('rails.env', @config[:environment].to_s)
      @context.addParameter('rails.root', '/')
      @context.addParameter('public.root', '/public')
      
    end
    
    def add_web_dir_resources
      @context.setDocBase(File.join(@config[:web_app_dir], "public/"))
    end
    
    def add_rack_context_listener
      @context.addApplicationListener('org.jruby.rack.rails.RailsServletContextListener')
    end
    
    def add_application_libs(class_loader)
      resources_dir = File.join(@config[:web_app_dir], @config[:libs_dir], '**', '*.jar')
      
      Dir[resources_dir].each do |resource|
        class_loader.addURL(java.io.File.new(resource).to_url)
      end
    end
    
    def add_application_classes(class_loader)
      resources_dir = File.join(@config[:web_app_dir], @config[:classes_dir])
      class_loader.addURL(java.io.File.new(resources_dir).to_url)
    end

    def load_default_web_xml
      default_web_xml = File.expand_path(File.join(@config[:web_app_dir], @config[:default_web_xml]))
      
      if File.exist?(default_web_xml)
        @context.setDefaultWebXml(default_web_xml)
        @context.setDefaultContextXml(default_web_xml)

        context_config = TomcatRails::Tomcat::ContextConfig.new
        context_config.setDefaultWebXml(default_web_xml)

        @context.addLifecycleListener(context_config)
      end
    end
  end
end