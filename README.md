# SavonV2

Heavy metal SOAP client

[Documentation](http://savon_v2rb.com) | [RDoc](http://rubydoc.info/gems/savon_v2) |
[Mailing list](https://groups.google.com/forum/#!forum/savon_v2rb) | [Twitter](http://twitter.com/savon_v2rb)

[![Build Status](https://secure.travis-ci.org/savon_v2rb/savon_v2.png?branch=version2)](http://travis-ci.org/savon_v2rb/savon_v2)
[![Gem Version](https://badge.fury.io/rb/savon_v2.png)](http://badge.fury.io/rb/savon_v2)
[![Code Climate](https://codeclimate.com/github/savon_v2rb/savon_v2.png)](https://codeclimate.com/github/savon_v2rb/savon_v2)
[![Coverage Status](https://coveralls.io/repos/savon_v2rb/savon_v2/badge.png?branch=version2)](https://coveralls.io/r/savon_v2rb/savon_v2)


## Version 2

SavonV2 version 2 is available through [Rubygems](http://rubygems.org/gems/savon_v2) and can be installed via:

```
$ gem install savon_v2
```

or add it to your Gemfile like this:

```
gem 'savon_v2', '~> 2.8.0'
```

## Usage example

``` ruby
require 'savon_v2'

# create a client for the service
client = SavonV2.client(wsdl: 'http://service.example.com?wsdl')

client.operations
# => [:find_user, :list_users]

# call the 'findUser' operation
response = client.call(:find_user, message: { id: 42 })

response.body
# => { find_user_response: { id: 42, name: 'Hoff' } }
```

For more examples, you should check out the
[integration tests](https://github.com/savon_v2rb/savon_v2/tree/version2/spec/integration).

## FAQ

* URI::InvalidURIError -- if you see this error, then it is likely that the http client you are using cannot parse the URI for your WSDL. Try `gem install httpclient` or add it to your `Gemfile`.
  - See https://github.com/savon_v2rb/savon_v2/issues/488 for more info

## Give back

If you're using SavonV2 and you or your company is making money from it, then please consider
donating via [Gittip](https://www.gittip.com/tjarratt/) so that I can continue to improve it.

[![donate](donate.png)](https://www.gittip.com/tjarratt/)


## Documentation

Please make sure to [read the documentation](http://savon_v2rb.com/version2/).

And if you find any problems with it or if you think something's missing,
feel free to [help out and improve the documentation](https://github.com/savon_v2rb/savon_v2rb.com).

Donate icon from the [Noun Project](http://thenounproject.com/noun/donate/#icon-No285).
