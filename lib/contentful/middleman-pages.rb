require "middleman-pages/extension"

::Middleman::Extensions.register(:contentful_pages, Contentful::PagexExtension)
