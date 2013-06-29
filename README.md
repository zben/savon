# Savon

Heavy metal SOAP client

[Documentation](http://savonrb.com) | [RDoc](http://rubydoc.info/gems/savon) |
[Mailing list](https://groups.google.com/forum/#!forum/savonrb) | [Twitter](http://twitter.com/savonrb)

[![Build Status](https://secure.travis-ci.org/savonrb/savon.png?branch=version1)](http://travis-ci.org/savonrb/savon)
[![Gem Version](https://badge.fury.io/rb/savon.png)](http://badge.fury.io/rb/savon)
[![Code Climate](https://codeclimate.com/github/savonrb/savon.png)](https://codeclimate.com/github/savonrb/savon)
[![Coverage Status](https://coveralls.io/repos/savonrb/savon/badge.png?branch=version1)](https://coveralls.io/r/savonrb/savon)


## Version 1 (Deprecated)

Savon version 1 is available through [Rubygems](http://rubygems.org/gems/savon) and can be installed via:

```
$ gem install savon --version '~> 1.0'
```

or add it to your Gemfile like this:

```
gem 'savon', '~> 1.0'
```


Introduction
------------

``` ruby
require "savon"

# create a client for your SOAP service
client = Savon.client("http://service.example.com?wsdl")

client.wsdl.soap_actions
# => [:create_user, :get_user, :get_all_users]

# execute a SOAP request to call the "getUser" action
response = client.request(:get_user) do
  soap.body = { :id => 1 }
end

response.body
# => { :get_user_response => { :first_name => "The", :last_name => "Hoff" } }
```

Documentation
-------------

Continue reading at [savonrb.com/version1/](http://savonrb.com/version1/)
