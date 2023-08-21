# WOVN.io Ruby Library

For English users: [English](README.en.md)

WOVN.io Rubyライブラリは、翻訳を提供するためにWOVN.ioを利用したライブラリです。
WOVN.io Ruby ライブラリは Rack Middleware としてパッケージ化されています。

このドキュメントでは、WOVN.io Rubyをインストールするまでの手順や、セットアップ・設定の流れを説明しています。

## 1. インストール

### 1.1. WOVN.ioアカウントを作成

WOVN.io Ruby Libraryを利用するには、WOVN.ioのアカウントが必要です。
アカウントをお持ちでない方は、まずはWOVN.ioに登録してください。

### 1.2. ページ追加

WOVN.ioにログイン後、翻訳したいページを追加します。

### 1.3. Rubyアプリケーションの設定

WOVN.io Ruby ライブラリを使用するには、以下の行を Ruby アプリケーションの Gemfile に挿入します。
WOVN.ioは現在、バージョン2.0.1以上をサポートしています。

```ruby
gem 'wovnrb', '>= 2.0.1'
```

以上の設定を行った後、以下のコマンドを実行して、WOVN.io Rubyライブラリをインストールします。

```bash
bundle install
```

ライブラリをインストールしたら、Rubyアプリケーションの設定ファイルに以下を挿入します。

* Ruby on Rails を使っている場合

`config/application.rb` または `config/environments/` に以下を挿入します。

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

* Sinatra を使っている場合

アプリケーション・ファイルまたは `config.ru` のいずれかに以下を挿入します。

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

セットアップが完了したら、Rubyアプリケーションを起動し、WOVN.ioライブラリが正常に動作していることを確認します。

## 2. パラメータ設定

以下に、WOVN.io Ruby ライブラリの有効なパラメータの一覧を示します。

パラメータ名       | 必須     | デフォルト設定
------------------ | -------- | ----------------
project_token      | yes      | ''
default_lang       | yes      | 'ja'
supported_langs    | yes      | ['ja', 'en']
url_pattern        | yes      | 'path'
lang_param_name    |          | 'wovn'
query              |          | []
ignore_class       |          | []
translate_fragment |          | true
ignore_paths       |          | []
custom_domain_langs|          | {}
insert_hreflangs   |          | true

### 2.1. project_token

WOVN.ioアカウントのプロジェクトトークンを設定します。このパラメータは必須です。

### 2.2. default_lang

これはRubyアプリケーションのデフォルト言語を設定します。デフォルト値は英語（'en'）です。

リクエストされたページで、デフォルトの言語パラメータが URL に含まれている場合、リクエストは翻訳前にリダイレクトされます。
このために `default_lang` パラメータを使用します。

`default_lang` が 'en' に設定されている時に、以下のURLへのリクエストを受信した場合。

	https://wovn.io/en/contact

ライブラリは以下のURLにリダイレクトされます。

	https://wovn.io/contact

### 2.3. supported_langs

これは、ウェブサイトで使用されている言語（翻訳元を含む）をライブラリに伝えます。
この設定では、SEO（検索エンジン最適化）に必要なメタデータを挿入することができます。

ウェブサイトが英語で、WOVN.ioを使って日本語にローカライズしている場合は、以下の設定にしてください。
```
:supported_langs => ['en', 'ja']
```
**注意:** 配列の言語の順番は関係ありません。

### 2.4. url_pattern

ライブラリはRubyアプリケーションの中で、翻訳されるURLを新たに追加することで動作します。
urlの種類は `url_pattern` パラメータで設定できます。設定できるタイプは4種類。


パラメータ        | 翻訳されたページのURL                | 備考
--------------- | -------------------------------   | -------
'path'          | https://wovn.io/ja/contact        | デフォルト値、何も設定されていない場合、 `url_pattern` のデフォルト値はこの値になります
'subdomain'     | https://ja.wovn.io/contact        | DNSの設定が必要です
'query'         | https://wovn.io/contact?wovn=ja   | セットアップを完了するために必要なアプリケーションへの変更の最小量
'custom_domain' | `custom_domain_langs`に設定された値 | [2.10.項](#210-custom_domain_langs)を参照してください。

※ 上記は、以下のURLを使用してライブラリが翻訳したURLの例です。

	https://wovn.io/contact

### 2.5. lang_param_name

このパラメータは `url_pattern` が `query` に設定されている場合のみ有効です。

ページの言語を指定するためのクエリパラメータ名を設定することができます。

この設定のデフォルト値は `wovn` であり、翻訳された英語のページのURLが `https://my-website.com/index.php?wovn=en` という形式になります。
代わりに `lang` に値を設定すると、URLの例は `https://my-website.com/index.php?lang=en` という形式になります。

### 2.6. query

WOVN.ioは翻訳されたページを検索する際にクエリパラメータを無視します。
翻訳ページのURLにクエリパラメータを追加したい場合は、`query` パラメータを設定する必要があります。(WOVN.ioも設定する必要があります)

	https://wovn.io/ja/contact?os=mac&keyboard=us

`default_lang` が `en` でクエリが空に設定されている場合、上記のURLは以下のURLに変更され、ページの翻訳を検索するようになります。

	https://wovn.io/contact

`default_lang` が `en` でクエリが `os` に設定されている場合、上記のURLは以下のURLに変更され、ページの翻訳を検索するようになります。

	https://wovn.io/contact?os=mac

### 2.7. ignore_class

これは「無視するクラス」を設定し、WOVNがこの配列に含まれるクラスを持つHTML要素を変換できないようにします。

### 2.8. translate_fragment

このオプションでは、部分的なHTMLコンテンツの翻訳を無効にすることができます。
デフォルトでは、部分的なHTMLコンテンツは翻訳されますが、ウィジェットのスニペットは追加されません。
`translate_fragment` を `false` に設定すると、HTMLの一部が翻訳されないようになります。

### 2.9. ignore_paths

このパラメータは、wovnrbが指定されたディレクトリ内のコンテンツをローカライズしないように指示します。
指定されたディレクトリは、URLパスの先頭にのみマッチします。
例えば、ウェブサイトの管理者ディレクトリをローカライズしたくない場合は、wovnrbの設定に次のように追加します。

```
'ignore_paths' => ['/admin/']
```

### 2.10. custom_domain_langs

このパラメータは、カスタムドメイン言語パターンの場合（`url_pattern = custom_domain` が設定されている場合）のみ有効です。
カスタムドメイン言語パターン使用時は必須パラメータです。
`supported_langs` で設定した全ての言語と元言語に、必ず `custom_domain_langs` を設定してください。

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

上記の例では、 `wovn.io/en/*` にマッチするリクエストは英語のリクエストとして扱われます。
それ以外の `ja.wovn.io/*` にマッチするリクエストは日本語のリクエストとして扱われます。
また、 `fr.wovn.co.jp/*` にマッチするリクエストはフランス語のリクエストとして扱われます。
例えば、`http://ja.wovn.io/about.html` の日本語ページは、`http://wovn.io/en/about.html` という英語ページのURLを持つことになります。

必ず `url_pattern = custom_domain`と`custom_domain_langs` は一緒に使用してください。

`supported_langs` で宣言された各言語に `custom_domain_langs` を与えなければなりません。

オリジナル言語のために宣言されたパスは、実際のウェブサーバーの構造と一致していなければなりません。
この設定を使用して、オリジナル言語のリクエストパスを変更することはできません。

### 2.11. insert_hreflangs
このパラメータはhreflang属性を持つlinkタグを挿入するかどうかを指定します。
例えば設定が有効の場合、`<link rel="alternate" hreflang="en" href="https://my-website.com/en/">`のように、公開されている言語のタグを挿入します。

設定が無効の場合はタグは挿入せず、元からあるhreflang属性を持ったタグに変更は加えません。
