module Contentful
  module MiddlemanPages
    class PagexExtension < ::Middleman::Extension
      self.supports_multiple_instances = false

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

      private
      def massage_options
        massage_data_option
      end

      def massage_data_option
        data_option = options.data
        space_name, content_type_name = *data_option.split(".")
        p space_name
        p content_type_name
      end
      #def manipulate_resource_list(resources)
      #  options.data.map do |element|
      #    resource = ::Middleman::Sitemap::Resource.new(
      #      @app.sitemap,
      #      "#{options.prefix}/#{element.first}.html"
      #    )

      #    resource.extend ResourceInstanceMethods
      #    resource.template_locals = element[1]
      #    resource.resource_options = {template: File.expand_path(options.template)}

      #    resource
      #  end

      #end
    end
  end
end
