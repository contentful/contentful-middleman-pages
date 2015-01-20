# Contentful Middleman Pages

This gem bundles an extension to [Middleman](https://middlemanapp.com/). The goal of this extension is to simplify the usage withing Middleman of data imported from Contentul (using the [contentful_middleman](https://github.com/contentful/contentful_middlema) gem).

## Table of contents
* [Installation](#installation)
* [Usage](#usage)
  * [Extension configuration](#extension-configuration)
  * [Template locals](#template-locals)
  * [Blogging](#blogging)
  * [Pagination](#pagination)

## Installation

Add this line to your application's Gemfile:

    gem 'contentful-middleman-pages'

And then execute:

    $ bundle

## Usage

### Extension configuration


```ruby
activate :contentful_pages do |extension|
  extension.data      = 'blog.post'
  extension.prefix    = 'blog'
  extension.template  = 'random.html.erb'
  extension.permalink = 'my/nice/permalink/{title}.html'
end
```


Parameter | Required | Description
----------|----------|------------
data | true | Concatenation of the space name and content type (same names used when configuring the contentful_middleman extension) that identifies the entries to be used
template | true | Path to the template used to render every entry
prefix | false | String that will be prepended to the value specified in `template` and `permalink`
permalink | false | Uri template to specify a custom destination path for the resulting pages. Can interpolate values available in the entries

#### Extension configuration: example

Consider the following configuration of the contentful_middleman gem. On this case we are assigning the name partners to the space and name partner to the content type.

```ruby
activate :contentful do |f|
  f.space         = {partners: '7ujlxwexazta'}
  f.access_token  = '437fcca0ac3ec11728782c51cc559c0dfd0d2c568b7da5345c67a1ce31de5a8f'
  f.cda_query     = { content_type: '1EVL9Bl48Euu28QEOa44ai', include: 1 }
  f.content_types = { partner: {mapper: PartnerMapper, id:'1EVL9Bl48Euu28QEOa44ai'}}
end
```

On the activation below we are fetching the entries stored under the key `partners.partner`. We will render each of the entries using the template `source/random.html.erb`.

```ruby
activate :contentful do |extension|
  extension.data      = 'partners.partner'
  extension.template  = 'random.html.erb'
end
```

On the activation below we are using the same entries. We have set the prefix to `partners` and so we will render each of the entries using the template `source/partners/random/html.erb`.
```ruby
activate :contentful_pages do |extension|
  extension.data      = 'partners.partner'
  extension.prefix    = 'partners'
  extension.template  = 'random.html.erb'
end
```


On the activation below we are using the same entries. We have again set the prefix but this time we are using a custom permalink. Resulting pages will be available under `partners/my/nice/permalink/xyz.html` where `xyz` is the title of the entry used to render the page.
```ruby
activate :contentful_pages do |extension|
  extension.data      = 'partners.partner'
  extension.prefix    = 'partners'
  extension.template  = 'random.html.erb'
  extension.permalink = 'my/nice/permalink/{title}.html'
end
```

### Template locals

Inside every template you will have access to the followig set of local variables:

  * One local variable for each one of the properties stored for every entry in the local data.
  * Access to all the configured resources under the variable `contentful`.

#### Template locals: example

Consider the following Middleman configuration:

```ruby
activate :contentful do |extension|
  extension.data      = 'partners.partner'
  extension.template  = 'random.html.erb'
end

activate :contentful do |extension|
  extension.data      = 'blog.post'
  extension.template  = 'post.html.erb'
end
```

And that:

  * For every entry in `data.partner` the following properties are stored: id, name, location
  * For every entry in `blog.post` the following properties are stored: id, slug, author_name

So inside the `source/random.html.erb` template you will have access the partner properties as local variables:


```html
<h1><%= name %></h1>

Partner location: <%= location %>
```

And inside of every template you will have access to `contentful.partners.partner` and to `contentful.blog.post`. You could write something like this:

```html
<ul>
  <% contentful.partners.partner do |partner| %>
    <li> <%= partner.name %> , <%= partner.location %></li>
  <%end%>
</ul>

<ul>
  <% contentful.blog.post do |post| %>
    <li> <%= post.slug %> , <%= post.author_name %></li>
  <%end%>
</ul>
```

Please note that all the elements in `contentful.partners.partner` and `contentful.blog.post` are Middleman [resources](http://www.rubydoc.info/github/middleman/middleman/Middleman/Sitemap/Resource) and so all its methods are available to use.


### Blogging

If you want to create a blog with Middleman you should use the officially supported extension [middleman-blog](https://github.com/middleman/middleman-blog). To use the `middleman-blog` extension with data imported from contentful you will have to start writing a configuration like this:

```ruby
activate :blog do |blog|
  blog.prefix    = "blog"
  blog.sources   = "posts/:year-:month-:day-:title"
end
```

The relevant part of the previous snippet is the `blog.source` configuration parameter.  This parameter is used by the `middleman-blog` extension to know which resources it has to use to create the blog. To make resources created with the `contentful-middleman-pages` available to the blog extension set the permalink of each of these resources to a value that matches the `blog.sources` expression. For example:

```ruby
activate :contentful_pages do |extension|
  extension.data      = 'blog.post'
  extension.prefix    = 'blog'
  extension.permalink = "posts/{year}-{month}-{day}-{slug}.html"
  extension.template  = 'post.html.erb'
end
```

### Pagination

Pagination is not built into this extension. Use [middleman-pagination](https://github.com/Aupajo/middleman-pagination) instead.
