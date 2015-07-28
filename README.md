[![Build Status](https://travis-ci.org/akretion/ooorest.png?branch=master)](https://travis-ci.org/akretion/ooorest)
[![Dependency Status](https://www.versioneye.com/ruby/ooorest/badge.png)](https://www.versioneye.com/ruby/ooorest)

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

You can now talk to Odoo using REST webservices in JSON or XML formats!

You may run
```
rake routes
```
to discover the basic REST routes. You may typically have:
```
Routes for Ooorest::Engine:
  dashboard GET         /                                      ooorest/rest#dashboard
      index GET         /:model_name(.:format)                 ooorest/rest#index
        new GET         /:model_name/new(.:format)             ooorest/rest#new
     create POST        /:model_name(.:format)                 ooorest/rest#create
     export GET|POST    /:model_name/export(.:format)          ooorest/rest#export
bulk_delete POST|DELETE /:model_name/bulk_delete(.:format)     ooorest/rest#bulk_delete
bulk_action POST        /:model_name/bulk_action(.:format)     ooorest/rest#bulk_action
       show GET         /:model_name/:id(.:format)             ooorest/rest#show
       edit GET         /:model_name/:id/edit(.:format)        ooorest/rest#edit
     update PATCH       /:model_name/:id/update(.:format)      ooorest/rest#update
    destroy DELETE      /:model_name/:id(.:format)             ooorest/rest#destroy
show_in_app GET         /:model_name/:id/show_in_app(.:format) ooorest/rest#show_in_app
```

For instance you can get the list of Odoo users with:
```
GET /ooorest/res-users.json
```
You can also read user with 1 with:
```
GET /ooorest/res-users/1.json
```

the Odoo model name param should come after the engine scope ('ooorest' here). Note that '.' from Odoo model names are replaced by '-' (res.users -> res-users).


Usage as a Rails framework
--------------------------

You may also just require ooorest but not necessarily mount the engine. You may simply enjoy using the RequestHelper class that makes it easy to write your own custom Rails controllers to deal with Odoo objects seamlessly.


Forcing authentication for Ooorest actions
==========================================

If you mount the Ooorest engine, you probably want to ensure that only authenticated users can hit Ooorest actions and hence Odoo. To force this, in config/ooor.yml, you need to add
```yaml
  authenticate_ooorest: true
```

Global Odoo authentication (same Odoo credentials)
========================================================

You can choose to bootstrap a default default OOOR connection in your whole Rails app by setting an appropriate config/ooor.yml config file (see in test/dummy/config/ooor.yml for an example).
In this case the mentionned classes will be bootstraped and you'll be able to use them in your Rails application. These classes will use the credentials defined in ooor.yml. Warning! this can be a security issue! So make sure that the default credentials you use here only have basic acess rights, possibly no write permissions at all in your Odoo (specially if you mount the engine and hence enable default CRUD actions).


Mapping web users to Odoo users
==================================

If instead you want to enable users to write in your Odoo, you should use an authentication system such as Devise (or anything base on Warden) and then use the ooor_object method from RequestHelper, for instance:
```ruby
ooor_object('product.product')
```
wich will appropriately instanciate Odoo proxies with appropriate specific Odoo credentials according to the Rails logged user.


But for this to work, the ooor rack middleware (ooor/lib/ooor/rack.rb) needs to do its job of mapping the currently authenticated user to some Odoo user. Note that to use ooor_object method, Ooorest will force you to be authentitacted. Non authenticated users cannot have specific credentials, right? So non authenticated users can use the public_ooor_object method instead to get the proxy to the global Odoo credentials if any instead.

To map a web user to an Odoo user, Ooorest is quite agnostic and let you do really what you want. All you have to do is provide such a block of code in your Rails config/application.rb file for instance:

```ruby
  ::Ooor::Rack.ooor_session_config_mapper do |env|
    # read Warden or Devise documentation to figure out what you can read about current user in the env variable
    {username: 'some_user', password: 'some_password', database: 'some_database', url: 'some_url', connection_session: {lang: 'pt_BR'}}
  end
```

Note that you can see here the full power of Ooor/Ooorest which is multi-Odoo instances out of the box.

In this other example, we inject the email of the Devise authenticated user into the context of Odoo requests so that some custom Odoo access rule method could filter the ERP resources to be accessed according to the Devise user of the web application despite these users may map to a single ERP portal user:
https://github.com/akretion/ooorest-app/blob/master/config/application.rb#L13

Yes this is putting somewhere the password of the Odoo users in the Rails app in clear. I advise you never do that with an admin user and you be careful about exploits that would consist in trying to read these passwords. A typical use case however is the concept of 'light user': several web portal users will map to the same Odoo user.
TODO In this case Ooorest will forward to Odoo the email of the current portal user in the Odoo context so you could log it or eventually apply specific access rule. TODO
In the future, this would be welcome to ensure Ooor could authenticate to the same OAuth2 provider as Odoo instead to avoid such a thing. Contributions are welcome.

