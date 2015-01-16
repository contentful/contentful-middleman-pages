module Contentful
  module MiddlemanPages
    module ResourceInstanceMethods
      attr_accessor :resource_options, :template_locals

      def render(opts = {}, locs ={}, &block)
        super(opts, template_locals, &block)
      end

      def ignored?
        # As we are ignoring the template used to render this resource
        # the resources won't be rendered. We have to force it.
        false
      end
    end

    class Extension < ::Middleman::Extension
      self.supports_multiple_instances = true

      option :data, nil,
        'The name of the Space and the Content Type to be used as the source of data'
      option :prefix, nil, ""
      option :template, nil,
        'The path to the template that will be used to generate a file for every entry in the given data'

      #
      # Middleman hooks
      #
      def after_configuration
        massage_options
      end

      def manipulate_resource_list(resources)
        resources + options.data.map do |entry_id, entry_data|
          resource = ::Middleman::Sitemap::Resource.new(
            @app.sitemap,
            "#{options.prefix}/#{entry_id}.html",
            options.template
          )

          resource.extend ResourceInstanceMethods
          resource.template_locals = entry_data

          resource
        end
      end

      private
      def massage_options
        massage_data_option
        massage_template_option
      end

      def massage_data_option
        data_option                   = options.data
        space_name, content_type_name = *data_option.split(".")

        options.data = app.data.send(space_name).fetch(content_type_name)
      end

      def massage_template_option
        # Ignore the template used to render this page. Otherwise
        # Middleman will try to render it but the resource won't have
        # the required local variables and there'll be an error
        app.ignore options.template
        options.template = ::File.join(app.source_dir, options.template)
      end

    end
  end
end
