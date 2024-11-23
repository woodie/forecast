# forecast
Weather forecast for a given address.

### Setup and configuration

Requested an API key and store the value.
```sh
cat.env
openweather_api_key=0123456789abcdef0123456789abcdef
```

### Installing software

Rails 8.0.0 requires Ruby version >= 3.2.0.
```sh
rvm install 3.2.0 --with-openssl-dir=$(brew --prefix openssl@1.1)
gem install rails
rails new forecast --skip-git
```

More rubygems added (including rspec) to Gemfile.
```
rails generate rspec:install
```
