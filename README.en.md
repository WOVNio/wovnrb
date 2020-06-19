# WOVN.io Ruby Library

The WOVN.io Ruby library is a library that uses WOVN.io in order to provide translations. The WOVN.io Ruby Library is packaged as Rack Middleware.

This document explains the process of installing WOVN.io Ruby, as well as set up and configuration process.

## 1. Install

### 1.1. Creating a WOVN.io account.

In order to use the WOVN.io Ruby Library, you need a WOVN.io account. If you do not have an account, please first sign up for one at WOVN.io.

### 1.2. Adding a Page

After logging into WOVN.io, add a page that you would like translated.

### 1.3. Ruby Application Settings

To use the WOVN.io Ruby Library, insert the following line into your Ruby Application's Gemfile. WOVN.io currently supports version 2.0.1 and up.

```ruby
gem 'wovnrb', '>= 2.0.1'
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
  :project_token => 'EnS!t3',
  :default_lang => 'en',
  :supported_langs => ['en'],
  :url_pattern => 'path'
}

...
```

* If you're using Sinatra

Insert the following into either the Application File or config.ru.

```ruby
...

require 'wovnrb'

use Wovnrb::Interceptor, {
  :project_token => 'EnS!t3',
  :default_lang => 'en',
  :supported_langs => ['en'],
  :url_pattern => 'path'
}

...
```

After completing setup, start the Ruby Application, and make sure the WOVN.io library is working correctly.

## 2. Parameter Setting

The following is a list of the WOVN.io Ruby Library's valid parameters.

Parameter Name     | Required | Default Setting
------------------ | -------- | ----------------
project_token      | yes      | ''
default_lang       | yes      | 'en'
supported_langs    | yes      | ['en']
url_pattern        | yes      | 'path'
lang_param_name    |          | 'wovn'
query              |          | []
ignore_class       |          | []
translate_fragment |          | true
ignore_paths       |          | []

### 2.1. project_token

Set your WOVN.io Account's Project token. This parameter is required.

### 2.2. default_lang

This sets the Ruby application's default language. The default value is English ('en').

If, for a requested page, the default language parameter is included in the URL, the request is redirected before translating. The default_lang parameter is used for this purpose.

If the default_lang is set to 'en', when receiving a request for the following URL,

	https://wovn.io/en/contact

Then the library will redirect to the following URL.

	https://wovn.io/contact

### 2.3. supported_langs
This tells the library which languages are being used on the website (including
the original language). This setting allows for inserting metadata necessary for
SEO (Search Engine Optimization).

If your website is in English and you are using WOVN.io to localize it in
Japanese, then you should use the following setting:
```
:supported_langs => ['en', 'ja']
```
**Note:** The order of the languages in the list does not matter.

### 2.4. url_pattern

The Library works in the Ruby Application by adding new URLs to be translated. You can set the type of url with the `url_pattern` parameter. There are 3 types that can be set.

parameters  | Translated page's URL           | Notes
----------- | ------------------------------- | -------
'path'      | https://wovn.io/ja/contact      | Default Value. If no settings have been set, url_pattern defaults to this value.
'subdomain' | https://ja.wovn.io/contact      | DNS settings must be set.
'query'     | https://wovn.io/contact?wovn=ja | The least amount of changes to the application required to complete setup.

※ The following is an example of a URL that has been translated by the library using the above URLs.

	https://wovn.io/contact

### 2.5 lang_param_name
This parameter is only valid for when `url_pattern` is set to `'query'`.

It allows you to set the query parameter name for declaring the language of the
page. The default value for this setting is `'wovn'`, such that a page URL in
translated language English has the form
`https://my-website.com/index.php?wovn=en`. If you instead set the value to
`'lang'`, then the later URL example would have the form
`https://my-website.com/index.php?lang=en`.

### 2.6. query

WOVN.io ignores query parameters when searching a translated page. If you want to add a query parameter to translated page's URL, you should configure the `query` parameter. (You need to configure WOVN.io too)

	https://wovn.io/ja/contact?os=mac&keyboard=us

If the `default_lang` is 'en', and the query is set to '', the above URL will be modified into the following URL to search for the page's translation.

	https://wovn.io/contact

If the `default_lang` is 'en', and the query is set to 'os', the above URL will be modified into the following URL to search for the page's translation.

	https://wovn.io/contact?os=mac

### 2.7. ignore_class

This sets "Ignore class" which prevents WOVN from translating HTML elements that have a class contained in this array.

### 2.8. translate_fragment

This option allows to disable translating partial HTML content. By default,
partial HTML content is translated but no widget snippet is added. Set
`translate_fragment` to `false` to prevent translating partial HTML content.

### 2.9 ignore_paths

This parameter tells WOVN.rb to not localize content withing given directories.

The directories given will only be matched against the beginning of the URL path.

For instance, if you want to not localize the admin directory of your website, you should add the following to you WOVN.rb configuration.
```
'ignore_paths' => ['/admin/']
```
