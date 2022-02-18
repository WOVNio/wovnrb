# ./wovnrb should not be cached
echo "gem 'wovnrb', path: './wovnrb'" >> Gemfile
bundle install
bin/rails server -b 0.0.0.0 -e development -p 4000