Ooorest

[![Build Status](https://travis-ci.org/akretion/ooorest.png?branch=master)](https://travis-ci.org/akretion/ooorest)

Basic REST Usage
----------------

Require the gem in your Gemfile with:
```ruby
gem 'ooorest', git: 'https://github.com/akretion/ooorest.git'
```

then run
```
bundle install
```

Finally mount in your Rails application as an engine, for instance by adding this line in your config/routes.rb

```ruby
mount Ooorest::Engine => "/ooorest"
```

You can now talk to OpenERP using REST webservices in JSON or XML formats!

Usage as a Rails framework
--------------------------

You may also just require ooorest but not necessarily mount the engine. You may simply enjoy using the RequestHelper class that makes it easy to write your own custom Rails controllers to deal with OpenERP objects seamlessly.
