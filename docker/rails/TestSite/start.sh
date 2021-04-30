cd /usr/src/app
gem update --system
gem uninstall bundler
rm /usr/local/bin/bundle
rm /usr/local/bin/bundler
gem install bundler:2.1.4
update --bundler
bundle install
apt update
apt install npm -y
npm install --global yarn
yarn install --check-files
bin/rails server -b 0.0.0.0 -e development -p 4000