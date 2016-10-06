require 'addressable/template'
require 'pathname'
require 'hashugar'

module Contentful
  module MiddlemanPages
    module ResourceInstanceMethods
      attr_accessor :data

      def ignored?
        # As we are ignoring the template used to render this resource
        # the resources won't be rendered. We have to force it.
        false
      end

      def respond_to?(symbol)
         key_in_data(symbol) || super
      end

      def method_missing(symbol, *args, &block)
        return data.fetch(symbol.to_s) if key_in_data(symbol)
        super
      end

      private
      def key_in_data(key)
        data.key? key.to_s
      end

    end

    module UriTemplate
      def uri_template(uri)
        Addressable::Template.new uri
      end

      def apply_uri_template(template, data)
        template.expand data
      end
    end

    class Extension < ::Middleman::Extension
      include UriTemplate

      SOURCE_PATH = 'source'

      self.supports_multiple_instances = true

      option :data, nil,
        'The name of the Space and the Content Type to be used as the source of data'

      option :prefix, nil,
        'The prefix that will be prepended to the values in template and permalink options'

      option :template, nil,
        'The path to the template that will be used to generate a file for every entry in the given data'

      option :permalink, nil,
        'The template used to generate the destination path of an entry'

      def initialize(app, options, &block)
        super

        @contentful_resources = []
      end

      #
      # Middleman hooks
      #
      def after_configuration
        massage_options
      end

      def manipulate_resource_list(resources)
        new_resources_list = resources
        @contentful_resources += options.data.map do |entry_id, entry_data|
          expanded_permalink = expand_permalink entry_data
          resource           = ::Middleman::Sitemap::Resource.new(
            @app.sitemap,
            expanded_permalink,
            options.template
          )

          resource.extend ResourceInstanceMethods
          resource.data = entry_data
          resource.add_metadata locals: entry_data
          resource.add_metadata page: entry_data

          if (index = is_existing_resource?(resource, new_resources_list))
            new_resources_list[index] = resource
          else
            new_resources_list << resource
          end

          resource
        end

        (resources + @contentful_resources).map do |resource|
           contentful_metadata   = resource.metadata.fetch(:locals).fetch(:contentful, {}.to_hashugar)
           contentful_metadata[@space_name] = {@content_type_name => @contentful_resources}.to_hashugar
           resource.add_metadata locals: {contentful: contentful_metadata}
           resource
        end

        new_resources_list
      end

      private
      def apply_prefix_option
        unless options.prefix.nil?
          options.template  = ::File.join(options.prefix, options.template)

          template_path = ::File.join(::File.expand_path(::Dir.pwd), SOURCE_PATH, options.template)
          app.logger.warn "contentful_pages: template not found at #{template_path}" unless ::File.exist?(template_path)

          options.permalink = ::File.join(options.prefix, options.permalink) unless options.permalink.nil?
        end
      end

      def expand_permalink(entry_data)
        apply_uri_template(uri_template, entry_data).to_s
      end

      def is_existing_resource?(resource, resources)
        resource_id = resource.data.fetch("id")
        resources.find_index do |existing_resource|
          existing_resource.data["id"] == resource_id
        end
      end

      def uri_template
        @path_template ||= super options.permalink
      end

      def massage_options
        apply_prefix_option

        massage_data_option
        massage_permalink_option
        massage_template_option
      end

      def massage_data_option
        data_option                   = options.data
        space_name, content_type_name = *data_option.split(".")

        @space_name        = space_name
        @content_type_name = content_type_name

        unless app.data[space_name] && app.data[space_name][content_type_name]
          app.logger.warn "contentful_pages: no local data for key #{data_option}"
          options.data = []
          return
        end

        options.data = app.data[space_name].fetch(content_type_name)
      end

      def massage_permalink_option
        if options.permalink.nil?
          template_dirname  = Pathname(options.template).dirname
          options.permalink = ::File.join(template_dirname, "{id}.html" )
        end
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
