# WOVN.io Ruby Library

The WOVN.io Ruby library is a library that uses WOVN.io in order to provide translations. The WOVN.io Ruby Library is packaged as Rack Middleware.

This document explains the the process of installing WOVN.io Ruby, as well as set up and configuration.

## 1. Install

### 1.1. Creating a WOVN.io account.

In order to use the WOVN.io Ruby Library, you need a WOVN.io account. If you do not have an account, please first sign up for one at WOVN.io.

### 1.2. Adding a Page

After logging into WOVN.io, add a page you would like translated.

### 1.3. Ruby Application Settings

To use the WOVN.io Ruby Library, insert the following line into your Ruby Application's Gemfile. WOVN.io currently supports version 0.2 and up.

```ruby
gem 'wovnrb', '>= 0.2'
```

After setting the above, execute the following command to install the WOVN.io Ruby Library.

```bash
bundle install
```

After installing the library, insert the following into your Ruby Application's settings file.

* If you're using Ruby on Rails

Insert the following into either config/application.rb or config/environments/.

```ruby
...

config.wovnrb = {
  :user_token => '2Wle3'
}

...
```

* If you're using Sinatra

Insert the following into either the Application File or config.ru.

```ruby
...

require 'wovnrb'

use Wovnrb::Interceptor, {
  :user_token => '2Wle3'
}

...
```

After completing setup, start the Ruby Application, and make sure the WOVN.io library is working correctly.

## 2. Parameter Setting

WOVN.io Ruby Library's valid parameters are as follows.

Parameter Name | Required | Default Setting
-------------- | -------- | ----------------
user_token     | yes      | ''
url_pattern    | yes      | 'path'
query          |          | []
default_lang   | yes      | 'en'

### 2.1. user_token

Set your WOVN.io Account's user token. This parameter is required.

### 2.2. url_pattern

The Library works in the Ruby Application by adding new URL's to be translated. You can set the type of url with the url_pattern parameter. There are 3 types that can be set.

parameters  | Translated page's URL           | Notes
----------- | ------------------------------- | -------
'path'      | https://wovn.io/ja/contact      | Default Value. If no settings have been set, url_pattern defaults to this value.
'subdomain' | https://ja.wovn.io/contact      | DNS settings must be set.
'query'     | https://wovn.io/contact?wovn=ja | The least amount of changes to the application required to complete setup.

※ The following is an example of a URL that has been translated by the library using the above URL's.

	https://wovn.io/contact

### 2.3. query

WOVN.io ignores query parameters when searching translated page. If you want to add query parameter to translated page's URL, you should configure "query" parameter. (You need to configure WOVN.io too)

	https://wovn.io/ja/contact?os=mac&keyboard=us

If the defualt_lang is 'en', and the query is set to '', the above URL will be modified into the following URL to search for the page's translation.

	https://wovn.io/contact

If the default_lang is 'en', and the query is set to 'os', the above URL will be modified into the following URL to search for the page's translation.

	https://wovn.io/contact?os=mac

### 2.4. default_lang

This sets the Ruby application's default language. The default value is English ('en').

If a requested page, where the default language's parameter is included in the URL, the request is redirected before translating. The default_lang parameter is used for this purpose.

If the default_lang is set to 'en', when receiving a request for the following URL,

	https://wovn.io/en/contact

The library will redirect to the following URL.

	https://wovn.io/contact

## 3. Contributing

1. Fork it ( https://github.com/[my-github-username]/wovnrb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
