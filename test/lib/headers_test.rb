require 'wovnrb/headers'
require 'minitest/autorun'
require 'pry'

class HeadersTest < Minitest::Test

  ######################### 
  # INITIALIZE
  #########################

  def test_initialize
    h = Wovnrb::Headers.new(get_env, get_settings)
    refute_nil(h)
  end

  # def test_initialize_env
  #   env = get_env
  #   h = Wovnrb::Headers.new(env, {})
  #   binding.pry
  #   #assert_equal(''
  # end

  def test_initialize_with_simple_url
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io'), get_settings)
    assert_equal('wovn.io/', h.url)
  end

  def test_initialize_with_query_language
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=en'), get_settings('url_pattern' => 'query'))
    assert_equal('wovn.io/?', h.url)
  end

  def test_initialize_with_query_language_without_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=en'), get_settings('url_pattern' => 'query'))
    assert_equal('wovn.io/?', h.url)
  end

  def test_initialize_with_path_language
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en'), get_settings)
    assert_equal('wovn.io/', h.url)
  end

  def test_initialize_with_domain_language
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io/'), get_settings('url_pattern' => 'subdomain'))
    assert_equal('wovn.io/', h.url)
  end

  def test_initialize_with_path_language_with_query
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en/?wovn=zh-CHS'), get_settings)
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_initialize_with_domain_language_with_query
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io/?wovn=zh-CHS'), get_settings('url_pattern' => 'subdomain'))
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_initialize_with_path_language_with_query_without_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en?wovn=zh-CHS'), get_settings)
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_initialize_with_domain_language_with_query_without_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io?wovn=zh-CHS'), get_settings('url_pattern' => 'subdomain'))
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  ######################### 
  # GET SETTINGS
  #########################

  def test_get_settings_valid
    # TODO: check if get_settings is valid (store.rb, valid_settings)
    # s = Wovnrb::Store.new
    # settings = get_settings
    
    # settings_stub = stub
    # settings_stub.expects(:has_key).with(:user_token).returns(settings["user_token"])
    # s.valid_settings?
  end

  ######################### 
  # PATH LANG: SUBDOMAIN
  #########################

  def test_path_lang_subdomain_empty
    h = Wovnrb::Headers.new(get_env('url' => 'https://.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar
    h = Wovnrb::Headers.new(get_env('url' => 'https://ar.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://AR.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da
    h = Wovnrb::Headers.new(get_env('url' => 'https://da.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://DA.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl
    h = Wovnrb::Headers.new(get_env('url' => 'https://nl.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://NL.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://EN.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi
    h = Wovnrb::Headers.new(get_env('url' => 'https://fi.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://FI.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr
    h = Wovnrb::Headers.new(get_env('url' => 'https://fr.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://FR.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de
    h = Wovnrb::Headers.new(get_env('url' => 'https://de.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://DE.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el
    h = Wovnrb::Headers.new(get_env('url' => 'https://el.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://EL.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he
    h = Wovnrb::Headers.new(get_env('url' => 'https://he.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://HE.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id
    h = Wovnrb::Headers.new(get_env('url' => 'https://id.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://ID.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it
    h = Wovnrb::Headers.new(get_env('url' => 'https://it.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://IT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja
    h = Wovnrb::Headers.new(get_env('url' => 'https://ja.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://JA.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko
    h = Wovnrb::Headers.new(get_env('url' => 'https://ko.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://KO.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms
    h = Wovnrb::Headers.new(get_env('url' => 'https://ms.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://MS.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no
    h = Wovnrb::Headers.new(get_env('url' => 'https://no.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://NO.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl
    h = Wovnrb::Headers.new(get_env('url' => 'https://pl.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://PL.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt
    h = Wovnrb::Headers.new(get_env('url' => 'https://pt.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://PT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru
    h = Wovnrb::Headers.new(get_env('url' => 'https://ru.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://RU.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es
    h = Wovnrb::Headers.new(get_env('url' => 'https://es.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://ES.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv
    h = Wovnrb::Headers.new(get_env('url' => 'https://sv.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://SV.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th
    h = Wovnrb::Headers.new(get_env('url' => 'https://th.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://TH.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi
    h = Wovnrb::Headers.new(get_env('url' => 'https://hi.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://HI.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr
    h = Wovnrb::Headers.new(get_env('url' => 'https://tr.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://TR.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk
    h = Wovnrb::Headers.new(get_env('url' => 'https://uk.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://UK.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi
    h = Wovnrb::Headers.new(get_env('url' => 'https://vi.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://VI.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHS.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHS.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-chs.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-cht.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ar.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://AR.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://da.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://DA.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://nl.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://NL.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://EN.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://fi.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://FI.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://fr.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://FR.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://de.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://DE.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://el.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://EL.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://he.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://HE.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://id.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ID.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://it.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://IT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ja.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://JA.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ko.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://KO.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ms.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://MS.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://no.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://NO.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://pl.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://PL.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://pt.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://PT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ru.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://RU.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://es.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ES.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://sv.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://SV.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://th.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://TH.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://hi.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://HI.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://tr.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://TR.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://uk.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://UK.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://vi.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://VI.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHS.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHS.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-chs.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-cht.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ar.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://AR.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://da.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://DA.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://nl.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://NL.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://EN.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://fi.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://FI.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://fr.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://FR.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://de.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://DE.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://el.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://EL.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://he.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://HE.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://id.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ID.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://it.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://IT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ja.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://JA.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ko.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://KO.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ms.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://MS.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://no.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://NO.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://pl.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://PL.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://pt.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://PT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ru.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://RU.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://es.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ES.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://sv.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://SV.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://th.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://TH.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://hi.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://HI.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://tr.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://TR.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://uk.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://UK.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://vi.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://VI.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHS.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHS.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-chs.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-cht.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ar.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://AR.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://da.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://DA.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://nl.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://NL.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://EN.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://fi.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://FI.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://fr.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://FR.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://de.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://DE.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://el.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://EL.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://he.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://HE.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://id.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ID.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://it.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://IT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ja.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://JA.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ko.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://KO.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ms.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://MS.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://no.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://NO.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://pl.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://PL.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://pt.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://PT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ru.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://RU.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://es.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ES.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://sv.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://SV.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://th.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://TH.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://hi.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://HI.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://tr.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://TR.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://uk.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://UK.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://vi.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://VI.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHS.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHS.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-chs.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-CHT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://ZH-CHT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-cht.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ar.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://AR.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://da.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DA.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://nl.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NL.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://en.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EN.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fi.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FI.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FR.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://de.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DE.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://el.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EL.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://he.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HE.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://id.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ID.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://it.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://IT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ja.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://JA.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ko.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://KO.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ms.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://MS.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://no.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NO.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pl.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PL.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pt.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ru.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://RU.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://es.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ES.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://sv.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://SV.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://th.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TH.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://hi.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HI.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://tr.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TR.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://uk.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://UK.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://vi.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://VI.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHS.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHS.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-chs.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHT.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-cht.wovn.io'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ar.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://AR.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://da.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DA.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://nl.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NL.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://en.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EN.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fi.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FI.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FR.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://de.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DE.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://el.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EL.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://he.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HE.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://id.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ID.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://it.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://IT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ja.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://JA.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ko.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://KO.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ms.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://MS.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://no.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NO.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pl.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PL.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pt.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ru.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://RU.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://es.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ES.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://sv.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://SV.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://th.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TH.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://hi.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HI.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://tr.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TR.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://uk.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://UK.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://vi.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://VI.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHS.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHS.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-chs.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHT.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-cht.wovn.io/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ar.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://AR.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://da.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DA.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://nl.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NL.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://en.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EN.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fi.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FI.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FR.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://de.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DE.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://el.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EL.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://he.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HE.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://id.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ID.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://it.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://IT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ja.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://JA.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ko.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://KO.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ms.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://MS.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://no.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NO.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pl.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PL.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pt.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ru.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://RU.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://es.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ES.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://sv.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://SV.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://th.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TH.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://hi.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HI.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://tr.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TR.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://uk.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://UK.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://vi.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://VI.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHS.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHS.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-chs.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHT.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-cht.wovn.io:1234'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_empty_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_subdomain_ar_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ar.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_ar_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://AR.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_subdomain_da_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://da.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_da_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DA.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_subdomain_nl_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://nl.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_nl_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NL.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_subdomain_en_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://en.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_en_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EN.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_subdomain_fi_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fi.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fi_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FI.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_subdomain_fr_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_fr_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://FR.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_subdomain_de_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://de.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_de_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://DE.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_subdomain_el_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://el.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_el_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://EL.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_subdomain_he_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://he.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_he_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HE.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_subdomain_id_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://id.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_id_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ID.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_subdomain_it_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://it.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_it_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://IT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_subdomain_ja_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ja.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ja_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://JA.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_subdomain_ko_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ko.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ko_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://KO.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_subdomain_ms_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ms.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_ms_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://MS.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_subdomain_no_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://no.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_no_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://NO.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_subdomain_pl_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pl.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pl_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PL.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_subdomain_pt_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://pt.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_pt_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://PT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_subdomain_ru_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ru.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_ru_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://RU.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_subdomain_es_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://es.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_es_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ES.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_subdomain_sv_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://sv.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_sv_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://SV.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_subdomain_th_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://th.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_th_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TH.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_subdomain_hi_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://hi.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_hi_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://HI.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_subdomain_tr_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://tr.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_tr_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://TR.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_subdomain_uk_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://uk.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_uk_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://UK.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_subdomain_vi_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://vi.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_vi_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://VI.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHS.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHS.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHS_lowercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-chs.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-CHT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://ZH-CHT.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_subdomain_zh_CHT_lowercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-cht.wovn.io:1234/'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal('zh-CHT', h.path_lang)
  end

  ######################### 
  # PATH LANG: QUERY
  #########################

  def test_path_lang_query_empty
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_empty_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn='), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('', h.path_lang)
  end

  def test_path_lang_query_ar_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ar'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_ar_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=AR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_query_da_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=da'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_da_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=DA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_query_nl_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=nl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_nl_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=NL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_query_en_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=en'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_en_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=EN'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_query_fi_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=fi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fi_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=FI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_query_fr_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=fr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_fr_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=FR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_query_de_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=de'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_de_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=DE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_query_el_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=el'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_el_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=EL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_query_he_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=he'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_he_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=HE'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_query_id_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=id'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_id_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ID'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_query_it_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=it'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_it_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=IT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_query_ja_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ja'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ja_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=JA'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_query_ko_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ko'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ko_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=KO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_query_ms_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ms'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_ms_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=MS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_query_no_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=no'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_no_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=NO'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_query_pl_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=pl'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pl_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=PL'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_query_pt_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=pt'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_pt_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=PT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_query_ru_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ru'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_ru_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=RU'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_query_es_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=es'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_es_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ES'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_query_sv_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=sv'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_sv_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=SV'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_query_th_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=th'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_th_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=TH'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_query_hi_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=hi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_hi_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=HI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_query_tr_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=tr'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_tr_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=TR'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_query_uk_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=uk'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_uk_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=UK'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_query_vi_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=vi'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_vi_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=VI'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=zh-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ZH-CHS'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHS_lowercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=zh-chs'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=zh-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_uppercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=ZH-CHT'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_query_zh_CHT_lowercase_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/?wovn=zh-cht'), get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
    assert_equal('zh-CHT', h.path_lang)
  end

  ######################### 
  # PATH LANG: PATH
  #########################

  def test_path_lang_path_empty
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_empty_with_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_ar
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ar'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_ar_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/AR'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_da
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/da'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_da_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/DA'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_nl
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/nl'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_nl_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/NL'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_en
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_en_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/EN'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_fi
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/fi'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/FI'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fr
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/fr'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_fr_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/FR'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_de
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/de'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_de_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/DE'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_el
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/el'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_el_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/EL'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_he
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/he'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_he_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/HE'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_id
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/id'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_id_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ID'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_it
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/it'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_it_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/IT'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_ja
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ja'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ja_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/JA'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ko
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ko'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ko_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/KO'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ms
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ms'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_ms_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/MS'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_no
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/no'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_no_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/NO'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_pl
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/pl'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pl_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/PL'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pt
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/pt'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_pt_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/PT'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_ru
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ru'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_ru_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/RU'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_es
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/es'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_es_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ES'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_sv
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/sv'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_sv_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/SV'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_th
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/th'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_th_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/TH'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_hi
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/hi'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_hi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/HI'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_tr
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/tr'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_tr_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/TR'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_uk
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/uk'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_uk_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/UK'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_vi
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/vi'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_vi_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/VI'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_zh_CHS
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/zh-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ZH-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_lowercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/zh-chs'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHT
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/zh-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_uppercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/ZH-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_lowercase
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/zh-cht'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_empty_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_empty_with_slash_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_ar_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ar'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_ar_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/AR'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_da_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/da'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_da_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/DA'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_nl_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/nl'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_nl_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/NL'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_en_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/en'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_en_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/EN'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_fi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/fi'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/FI'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fr_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/fr'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_fr_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/FR'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_de_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/de'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_de_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/DE'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_el_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/el'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_el_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/EL'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_he_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/he'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_he_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/HE'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_id_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/id'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_id_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ID'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_it_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/it'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_it_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/IT'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_ja_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ja'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ja_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/JA'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ko_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ko'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ko_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/KO'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ms_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ms'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_ms_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/MS'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_no_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/no'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_no_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/NO'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_pl_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/pl'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pl_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/PL'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pt_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/pt'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_pt_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/PT'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_ru_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ru'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_ru_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/RU'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_es_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/es'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_es_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ES'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_sv_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/sv'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_sv_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/SV'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_th_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/th'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_th_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/TH'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_hi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/hi'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_hi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/HI'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_tr_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/tr'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_tr_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/TR'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_uk_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/uk'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_uk_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/UK'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_vi_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/vi'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_vi_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/VI'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/zh-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ZH-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_lowercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/zh-chs'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/zh-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_uppercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/ZH-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_lowercase_with_port
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io:1234/zh-cht'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_empty_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_empty_with_slash_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_ar_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ar'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_ar_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/AR'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_da_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/da'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_da_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/DA'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_nl_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/nl'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_nl_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/NL'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_en_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/en'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_en_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/EN'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_fi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/fi'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/FI'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fr_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/fr'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_fr_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/FR'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_de_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/de'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_de_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/DE'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_el_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/el'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_el_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/EL'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_he_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/he'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_he_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/HE'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_id_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/id'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_id_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ID'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_it_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/it'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_it_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/IT'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_ja_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ja'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ja_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/JA'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ko_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ko'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ko_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/KO'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ms_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ms'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_ms_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/MS'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_no_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/no'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_no_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/NO'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_pl_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/pl'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pl_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/PL'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pt_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/pt'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_pt_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/PT'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_ru_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ru'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_ru_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/RU'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_es_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/es'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_es_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ES'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_sv_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/sv'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_sv_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/SV'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_th_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/th'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_th_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/TH'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_hi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/hi'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_hi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/HI'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_tr_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/tr'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_tr_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/TR'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_uk_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/uk'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_uk_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/UK'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_vi_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/vi'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_vi_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/VI'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/zh-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ZH-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_lowercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/zh-chs'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/zh-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_uppercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/ZH-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_lowercase_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io/zh-cht'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_empty_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_empty_with_slash_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/'), get_settings)
    assert_equal('', h.path_lang)
  end

  def test_path_lang_path_ar_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ar'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_ar_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/AR'), get_settings)
    assert_equal('ar', h.path_lang)
  end

  def test_path_lang_path_da_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/da'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_da_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/DA'), get_settings)
    assert_equal('da', h.path_lang)
  end

  def test_path_lang_path_nl_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/nl'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_nl_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/NL'), get_settings)
    assert_equal('nl', h.path_lang)
  end

  def test_path_lang_path_en_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/en'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_en_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/EN'), get_settings)
    assert_equal('en', h.path_lang)
  end

  def test_path_lang_path_fi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/fi'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/FI'), get_settings)
    assert_equal('fi', h.path_lang)
  end

  def test_path_lang_path_fr_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/fr'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_fr_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/FR'), get_settings)
    assert_equal('fr', h.path_lang)
  end

  def test_path_lang_path_de_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/de'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_de_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/DE'), get_settings)
    assert_equal('de', h.path_lang)
  end

  def test_path_lang_path_el_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/el'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_el_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/EL'), get_settings)
    assert_equal('el', h.path_lang)
  end

  def test_path_lang_path_he_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/he'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_he_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/HE'), get_settings)
    assert_equal('he', h.path_lang)
  end

  def test_path_lang_path_id_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/id'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_id_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ID'), get_settings)
    assert_equal('id', h.path_lang)
  end

  def test_path_lang_path_it_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/it'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_it_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/IT'), get_settings)
    assert_equal('it', h.path_lang)
  end

  def test_path_lang_path_ja_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ja'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ja_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/JA'), get_settings)
    assert_equal('ja', h.path_lang)
  end

  def test_path_lang_path_ko_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ko'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ko_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/KO'), get_settings)
    assert_equal('ko', h.path_lang)
  end

  def test_path_lang_path_ms_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ms'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_ms_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/MS'), get_settings)
    assert_equal('ms', h.path_lang)
  end

  def test_path_lang_path_no_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/no'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_no_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/NO'), get_settings)
    assert_equal('no', h.path_lang)
  end

  def test_path_lang_path_pl_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/pl'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pl_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/PL'), get_settings)
    assert_equal('pl', h.path_lang)
  end

  def test_path_lang_path_pt_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/pt'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_pt_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/PT'), get_settings)
    assert_equal('pt', h.path_lang)
  end

  def test_path_lang_path_ru_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ru'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_ru_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/RU'), get_settings)
    assert_equal('ru', h.path_lang)
  end

  def test_path_lang_path_es_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/es'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_es_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ES'), get_settings)
    assert_equal('es', h.path_lang)
  end

  def test_path_lang_path_sv_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/sv'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_sv_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/SV'), get_settings)
    assert_equal('sv', h.path_lang)
  end

  def test_path_lang_path_th_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/th'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_th_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/TH'), get_settings)
    assert_equal('th', h.path_lang)
  end

  def test_path_lang_path_hi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/hi'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_hi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/HI'), get_settings)
    assert_equal('hi', h.path_lang)
  end

  def test_path_lang_path_tr_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/tr'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_tr_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/TR'), get_settings)
    assert_equal('tr', h.path_lang)
  end

  def test_path_lang_path_uk_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/uk'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_uk_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/UK'), get_settings)
    assert_equal('uk', h.path_lang)
  end

  def test_path_lang_path_vi_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/vi'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_vi_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/VI'), get_settings)
    assert_equal('vi', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/zh-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ZH-CHS'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHS_lowercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/zh-chs'), get_settings)
    assert_equal('zh-CHS', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/zh-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_uppercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/ZH-CHT'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  def test_path_lang_path_zh_CHT_lowercase_with_port_unsecure
    h = Wovnrb::Headers.new(get_env('url' => 'http://wovn.io:1234/zh-cht'), get_settings)
    assert_equal('zh-CHT', h.path_lang)
  end

  ######################### 
  # HELPERS
  #########################

  def get_settings(options={})
    settings = {}
    settings['user_token'] = 'OHYx9'
    settings['url_pattern'] = 'path'
    settings['url_pattern_reg'] = "/(?<lang>[^/.?]+)"
    settings['query'] = []
    settings['api_url'] = 'http://localhost/v0/values'
    settings['default_lang'] = 'en'
    settings['supported_langs'] = []
    settings['secret_key'] = ''
    return settings.merge(options)
  end

  def get_env(options={})
    env = {}
    env['rack.url_scheme'] = 'http'
    env['HTTP_HOST'] = 'wovn.io'
    env['REQUEST_URI'] = '/dashboard?param=val&hey=you'
    env['SERVER_NAME'] = 'wovn.io'
    env['HTTP_COOKIE'] = "olfsk=olfsk021093478426337242; hblid=KB8AAMzxzu2DSxnB4X7BJ26rBGVeF0yJ; optimizelyEndUserId=oeu1426233718869r0.5398541854228824; __zlcmid=UFeZqrVo6Mv3Yl; wovn_selected_lang=en; optimizelySegments=%7B%7D; optimizelyBuckets=%7B%7D; _equalizer_session=eDFwM3M2QUZJZFhoby9JZlArckcvSUJwNFRINXhUeUxtNnltQXZhV0tqdGhZQjJMZ01URnZTK05ydFVWYmM3U0dtMVN0M0Z0UnNDVG8vdUNDTUtPc21jY0FHREgrZ05CUnBTb0hyUlkvYlBWQVhQR3RZdnhjMWsrRW5rOVp1Z3V3bkgyd3NpSlRZQWU1dlZvNmM1THp6aUZVeE83Y1pWWENRNTBUVFIrV05WeTdDMlFlem1tUzdxaEtndFZBd2dtUjU2ak5EUmJPa3RWWmMyT1pSVWdMTm8zOVZhUWhHdGQ3L1c5bm91RmNSdFRrcC90Tml4N2t3ZWlBaDRya2lLT1I0S0J2TURhUWl6Uk5rOTQ4Y1MwM3VKYnlLMUYraEt5clhRdFd1eGdEWXdZd3pFbWQvdE9vQndhdDVQbXNLcHBURm9CbnZKenU2YnNXRFdqRVl0MVV3bmRyYjhvMDExcGtUVU9tK1lqUGswM3p6M05tbVRnTjE3TUl5cEdpTTZ4a2gray8xK0FvTC9wUDVka1JSeE5GM1prZmRjWDdyVzRhWW5uS2Mxc1BxOEVVTTZFS3N5bTlVN2p5eE5YSjNZWGI2UHd3Vzc0bDM5QjIwL0l5Mm85NmQyWFAwdVQ3ZzJYYk1QOHY2NVJpY2c9LS1KNU96eHVycVJxSDJMbEc4Rm9KVXpBPT0%3D--17e47555d692fb9cde20ef78a09a5eabbf805bb3; mp_a0452663eb7abb7dfa9c94007ebb0090_mixpanel=%7B%22distinct_id%22%3A%20%2253ed9ffa4a65662e37000000%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fp.dev-wovn.io%3A8080%2Fhttp%3A%2F%2Fdev-wovn.io%3A3000%22%2C%22%24initial_referring_domain%22%3A%20%22p.dev-wovn.io%3A8080%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpu%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D"
    env['HTTP_ACCEPT_LANGUAGE'] = 'ja,en-US;q=0.8,en;q=0.6'
    env['QUERY_STRING'] = 'param=val&hey=you'
    env['ORIGINAL_FULLPATH'] = '/dashboard?param=val&hey=you'
    #env['HTTP_REFERER'] = 
    env['REQUEST_PATH'] = '/dashboard'
    env['PATH_INFO'] = '/dashboard'

    if options['url']
      url = URI.parse(options['url'])
      env['rack.url_scheme'] = url.scheme
      env['HTTP_HOST'] = url.host
      if (url.scheme == 'http' && url.port != 80) || (url.scheme == 'https' && url.port != 443)
        env['HTTP_HOST'] += ":#{url.port}"
      end
      env['SERVER_NAME'] = url.host
      env['REQUEST_URI'] = url.request_uri
      env['ORIGINAL_FULLPATH'] = url.request_uri
      env['QUERY_STRING'] = url.query
      env['REQUEST_PATH'] = url.path
      env['PATH_INFO'] = url.path
    end

    return env.merge(options)
  end
end
