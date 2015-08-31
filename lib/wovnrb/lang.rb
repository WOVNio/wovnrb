# -*- encoding: UTF-8 -*-
module Wovnrb
  class Lang
    LANG = {
      #http://msdn.microsoft.com/en-us/library/hh456380.aspx
      'ar' => {name: 'العربية',           code: 'ar',     en: 'Arabic'},
      'zh-CHS' => {name: '简体中文',      code: 'zh-CHS', en: 'Simp Chinese'},
      'zh-CHT' => {name: '繁體中文',      code: 'zh-CHT', en: 'Trad Chinese'},
      'da' => {name: 'Dansk',             code: 'da',     en: 'Danish'},
      'nl' => {name: 'Nederlands',        code: 'nl',     en: 'Dutch'},
      'en' => {name: 'English',           code: 'en',     en: 'English'},
      'fi' => {name: 'Suomi',             code: 'fi',     en: 'Finnish'},
      'fr' => {name: 'Français',          code: 'fr',     en: 'French'},
      'de' => {name: 'Deutsch',           code: 'de',     en: 'German'},
      'el' => {name: 'Ελληνικά',          code: 'el',     en: 'Greek'},
      'he' => {name: 'עברית',             code: 'he',     en: 'Hebrew'},
      'id' => {name: 'Bahasa Indonesia',  code: 'id',     en: 'Indonesian'},
      'it' => {name: 'Italiano',          code: 'it',     en: 'Italian'},
      'ja' => {name: '日本語',            code: 'ja',     en: 'Japanese'},
      'ko' => {name: '한국어',            code: 'ko',     en: 'Korean'},
      'ms' => {name: 'Bahasa Melayu',     code: 'ms',     en: 'Malay'},
      'no' => {name: 'Norsk',             code: 'no',     en: 'Norwegian'},
      'pl' => {name: 'Polski',            code: 'pl',     en: 'Polish'},
      'pt' => {name: 'Português',         code: 'pt',     en: 'Portuguese'},
      'ru' => {name: 'Русский',           code: 'ru',     en: 'Russian'},
      'es' => {name: 'Español',           code: 'es',     en: 'Spanish'},
      'sv' => {name: 'Svensk',            code: 'sv',     en: 'Swedish'},
      'th' => {name: 'ภาษาไทย',           code: 'th',     en: 'Thai'},
      'hi' => {name: 'हिन्दी',               code: 'hi',     en: 'Hindi'},
      'tr' => {name: 'Türkçe',            code: 'tr',     en: 'Turkish'},
      'uk' => {name: 'Українська',        code: 'uk',     en: 'Ukrainian'},
      'vi' => {name: 'Tiếng Việt',        code: 'vi',     en: 'Vietnamese'},

=begin
      * denotes no Google support
      *{name: 'Urdu', code: 'ur', en: 'Urdu'},
      {name: 'Català', code: 'ca'},
      {name: 'Čeština', code: 'cs'},
      {name: 'Български', code: 'bg'},
      {name: 'Estonian', code: 'et'},
      *{name: 'Haitian Creoloe', code: 'ht'},
      *{name: 'Hmong Daw', code: 'mww'},
      {name: 'Hungarian', code: 'hu'},
      *{name: 'Klingon', code: 'tlh'},
      *{name: 'Klingon (plqaD)', code: 'tlh-Qaak'},
      {name: 'Latvian', code: 'lv'},
      {name: 'Lithuanian', code: 'lt'},
      {name: 'Maltese', code: 'mt'},
      {name: 'Persian', code: 'fa'},
      {name: 'Romanian', code: 'ro'},
      {name: 'Slovak', code: 'sk'},
      {name: 'Slovenian', code: 'sl'},
      {name: 'Ukranian', code: 'uk'},
      {name: 'Welsh', code: 'cy'},
=end
    }

    def self.get_code(lang_name)
      return nil if lang_name.nil?
      return lang_name if LANG[lang_name]
      LANG.each do |k, l|
        if lang_name.downcase == l[:name].downcase || lang_name.downcase == l[:en].downcase || lang_name.downcase == l[:code].downcase
          return l[:code]
        end
      end
      return nil
    end

  end
end
