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
  :default_lang => 'ja',
  :supported_langs => ['ja', en'],
  :url_pattern => 'path'
}

...
```

The WOVN.rb Rails middleware must also be installed. See [2.10 - install_middleware](#2.10-install_middleware)

* If you're using Sinatra

Insert the following into either the Application File or config.ru.

```ruby
...

require 'wovnrb'

use Wovnrb::Interceptor, {
  :project_token => 'EnS!t3',
  :default_lang => 'ja',
  :supported_langs => ['ja', 'en'],
  :url_pattern => 'path'
}

...
```

After completing setup, start the Ruby Application, and make sure the WOVN.io library is working correctly.

## 2. Parameter Setting

The following is a list of the WOVN.io Ruby Library's valid parameters.

Parameter Name                 | Required | Default Setting
-------------------------------| -------- | ----------------
project_token                  | yes      | ''
default_lang                   | yes      | 'ja'
supported_langs                | yes      | ['ja', 'en']
url_pattern                    | yes      | 'path'
lang_param_name                |          | 'wovn'
query                          |          | []
ignore_class                   |          | []
translate_fragment             |          | true
ignore_paths                   |          | []
install_middleware             |          | true
compress_api_requests          |          | true
api_timeout_seconds            |          | 1.0
api_timeout_search_engine_bots |          | 5.0
translate_canonical_tag        |          | true
custom_domain_langs            |          | {}

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

The Library works in the Ruby Application by adding new URLs to be translated. You can set the type of url with the `url_pattern` parameter. There are 4 types that can be set.

parameters      | Translated page's URL            | Notes
--------------- | -------------------------------- | -------
'path'          | https://wovn.io/ja/contact       | Default Value. If no settings have been set, url_pattern defaults to this value.
'subdomain'     | https://ja.wovn.io/contact       | DNS settings must be set.
'query'         | https://wovn.io/contact?wovn=ja  | The least amount of changes to the application required to complete setup.
'custom_domain' | Depends on `custom_domain_langs` | See [Section 2.15.](#215-custom_domain_langs).

※ The following is an example of a URL that has been translated by the library using the above URLs.

	https://wovn.io/contact

### 2.5. lang_param_name
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

### 2.9. ignore_paths

This parameter tells WOVN.rb to not localize content withing given directories.

The directories given will only be matched against the beginning of the URL path.

For instance, if you want to not localize the admin directory of your website, you should add the following to you WOVN.rb configuration.
```
'ignore_paths' => ['/admin/']
```

### 2.10. install_middleware

When using WOVN.rb in a Rails environment, this parameter controls whether the WOVN.rb middleware will be automatically installed or not.

By default, WOVN.rb is automatically installed as the first middleware.
If you are using Rack::Deflater or other middleware that needs to be executed first, set this parameter to `false` and manually insert the middleware appropriately.
WOVN.rb needs to be added after any compression middleware.

```ruby
  config.middleware.use Rack::Deflater
  config.middleware.insert_after Rack::Deflater, Wovnrb::Interceptor

  config.wovnrb = {
    :project_token => 'EnS!t3',
    :default_lang => 'en',
    :supported_langs => ['en'],
    :url_pattern => 'path',
    :install_middleware => false
  }
```

### 2.11. compress_api_requests

By default, requests to the translation API will be sent with gzip compression. Set to false to disable compression.

### 2.12. api_timeout_seconds
Configures the amount of time in seconds wovnrb will wait for the translation API for a response before the
request is considered timed-out. This setting defaults to `1.0`.

### 2.13. api_timeout_search_engine_bots
Similar to `api_timeout_seconds`, this timeout setting is applied when handling requests made by search engine bots.
Currently, bots from Google, Yahoo, Bing, Yandex, DuckDuckGo and Baidu are supported. This setting
defaults to `5.0`.

### 2.14. translate_canonical_tag
Configures if wovnrb should automatically translate existing canonical tag in the HTML. When set to `true`, wovnrb
will translate the canonical URL with the current language code according to your `url_pattern` setting.
This setting defaults to `true`.

### 2.15. custom_domain_langs
This parameter is valid and required, when `url_pattern_name` is `custom_domain`.
Set `custom_domain_langs` for all languages declared in `supported_langs`.

```ruby
config.wovnrb = {
  # ...
  :custom_domain_langs => {
    'en' => { 'url' => 'wovn.io/en' },
    'ja' => { 'url' => 'ja.wovn.io' },
    'fr' => { 'url' => 'fr.wovn.co.jp' }
  }
}
```

For the example above, all request URLs that match `wovn.io/en/*` will be considered as requests in English language.
All request URLs other than the above that match `ja.wovn.io/*` will be considered as requests in Japanese langauge.
And, request URLs that match `fr.wovn.co.jp/*` will be considered as requests in French langauge.
With the above example configuration, the page `http://ja.wovn.io/about.html` in Japanese language will have the URL `http://wovn.io/en/about.html` as English language.

`custom_domain_langs` setting may only be used together with the `url_pattern_name = custom_domain` setting.

If this setting is used, each language declared in `supported_langs` must be given a custom domain.

The path declared for your original language must match the structure of the actual web server.
In other words, you cannot use this setting to change the request path of your content in original language.
