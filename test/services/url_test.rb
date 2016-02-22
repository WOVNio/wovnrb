require 'wovnrb/services/url'

class URLTest < Minitest::Test



   def test_prepend_path
     assert_equal('http://www.google.com/new_dir/test/', Wovnrb::URL.prepend_path('http://www.google.com/test/', 'new_dir'))
   end 
 
   def test_prepend_path_long_path
     assert_equal('http://www.google.com/new_dir/test/try/again/', Wovnrb::URL.prepend_path('http://www.google.com/test/try/again/', 'new_dir'))
   end

   def test_prepend_path_no_trailing_slash
     assert_equal('http://www.google.com/new_dir/test', Wovnrb::URL.prepend_path('http://www.google.com/test', 'new_dir'))
   end

   def test_prepend_path_long_path_no_trailing_slash
     assert_equal('http://www.google.com/new_dir/test/try/again', Wovnrb::URL.prepend_path('http://www.google.com/test/try/again', 'new_dir'))
   end

   def test_prepend_path_no_path
     assert_equal('http://www.google.com/new_dir/', Wovnrb::URL.prepend_path('http://www.google.com/', 'new_dir'))
   end

   def test_prepend_path_no_path_no_trailing_slash
     assert_equal('http://www.google.com/new_dir', Wovnrb::URL.prepend_path('http://www.google.com', 'new_dir'))
   end  
  


   def test_prepend_path_no_host
     assert_equal('http://google.com/new_dir/test/', Wovnrb::URL.prepend_path('http://google.com/test/', 'new_dir'))
   end 
 
   def test_prepend_path_no_host_long_path
     assert_equal('http://google.com/new_dir/test/try/again/', Wovnrb::URL.prepend_path('http://google.com/test/try/again/', 'new_dir'))
   end

   def test_prepend_path_no_host_no_trailing_slash
     assert_equal('http://google.com/new_dir/test', Wovnrb::URL.prepend_path('http://google.com/test', 'new_dir'))
   end

   def test_prepend_path_no_host_long_path_no_trailing_slash
     assert_equal('http://google.com/new_dir/test/try/again', Wovnrb::URL.prepend_path('http://google.com/test/try/again', 'new_dir'))
   end

   def test_prepend_path_no_host_no_path
     assert_equal('http://google.com/new_dir/', Wovnrb::URL.prepend_path('http://google.com/', 'new_dir'))
   end

   def test_prepend_path_no_host_no_path_no_trailing_slash
     assert_equal('http://google.com/new_dir', Wovnrb::URL.prepend_path('http://google.com', 'new_dir'))
   end  



   def test_prepend_path_no_protocol
     assert_equal('www.facebook.com/dir/test/', Wovnrb::URL.prepend_path('www.facebook.com/test/', 'dir'))
   end

   def test_prepend_path_no_protocol_long_path
     assert_equal('www.facebook.com/dir/test/try/again/', Wovnrb::URL.prepend_path('www.facebook.com/test/try/again/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_trailing_slash
     assert_equal('www.facebook.com/dir/test', Wovnrb::URL.prepend_path('www.facebook.com/test', 'dir'))
   end  

   def test_prepend_path_no_protocol_long_path_no_trailing_slash
     assert_equal('www.facebook.com/dir/test/try/again', Wovnrb::URL.prepend_path('www.facebook.com/test/try/again', 'dir'))
   end

   def test_prepend_path_no_protocol_no_path
     assert_equal('www.facebook.com/dir/', Wovnrb::URL.prepend_path('www.facebook.com/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_path_no_trailing_slash
     assert_equal('www.facebook.com/dir', Wovnrb::URL.prepend_path('www.facebook.com', 'dir'))
   end



   def test_prepend_path_no_protocoli_no_host
     assert_equal('facebook.com/dir/test/', Wovnrb::URL.prepend_path('facebook.com/test/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_long_path
     assert_equal('facebook.com/dir/test/try/again/', Wovnrb::URL.prepend_path('facebook.com/test/try/again/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_no_trailing_slash
     assert_equal('facebook.com/dir/test', Wovnrb::URL.prepend_path('facebook.com/test', 'dir'))
   end  

   def test_prepend_path_no_protocol_no_host_long_path_no_trailing_slash
     assert_equal('facebook.com/dir/test/try/again', Wovnrb::URL.prepend_path('facebook.com/test/try/again', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_no_path
     assert_equal('facebook.com/dir/', Wovnrb::URL.prepend_path('facebook.com/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_no_path_no_trailing_slash
     assert_equal('facebook.com/dir', Wovnrb::URL.prepend_path('facebook.com', 'dir'))
   end



   def test_prepend_path_no_protocol_with_double_slash
     assert_equal('//www.yahoo.com/dir/test/', Wovnrb::URL.prepend_path('//www.yahoo.com/test/', 'dir'))
   end

   def test_prepend_path_no_protocol_long_path_with_double_slash
     assert_equal('//www.yahoo.com/dir/test/try/again/', Wovnrb::URL.prepend_path('//www.yahoo.com/test/try/again/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_trailing_slash_with_double_slash
     assert_equal('//www.yahoo.com/dir/test', Wovnrb::URL.prepend_path('//www.yahoo.com/test', 'dir'))
   end

   def test_prepend_path_no_protocol_long_path_no_trailing_slash_with_double_slash
     assert_equal('//www.yahoo.com/dir/test/try/again', Wovnrb::URL.prepend_path('//www.yahoo.com/test/try/again', 'dir'))
   end
     
   def test_prepend_path_no_protocol_no_path_with_double_slash
     assert_equal('//www.yahoo.com/dir/', Wovnrb::URL.prepend_path('//www.yahoo.com/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_path_no_trailing_slash_with_double_slash
     assert_equal('//www.yahoo.com/dir', Wovnrb::URL.prepend_path('//www.yahoo.com', 'dir'))
   end



   def test_prepend_path_no_protocol_no_host_with_double_slash
     assert_equal('//yahoo.com/dir/test/', Wovnrb::URL.prepend_path('//yahoo.com/test/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_long_path_with_double_slash
     assert_equal('//yahoo.com/dir/test/try/again/', Wovnrb::URL.prepend_path('//yahoo.com/test/try/again/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_no_trailing_slash_with_double_slash
     assert_equal('//yahoo.com/dir/test', Wovnrb::URL.prepend_path('//yahoo.com/test', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_long_path_no_trailing_slash_with_double_slash
     assert_equal('//yahoo.com/dir/test/try/again', Wovnrb::URL.prepend_path('//yahoo.com/test/try/again', 'dir'))
   end
     
   def test_prepend_path_no_protocol_no_host_no_path_with_double_slash
     assert_equal('//yahoo.com/dir/', Wovnrb::URL.prepend_path('//yahoo.com/', 'dir'))
   end

   def test_prepend_path_no_protocol_no_host_no_path_no_trailing_slash_with_double_slash
     assert_equal('//yahoo.com/dir', Wovnrb::URL.prepend_path('//yahoo.com', 'dir'))
   end



end
