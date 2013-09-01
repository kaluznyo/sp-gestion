SP-Gestion
==========

Prerequisites
=============

* Ruby 1.9.3
* Mysql (with Timezone informations loaded !)
* memcached
* ImageMagick
* HTTP server with ruby support (Pow, Apache/Nginx+Passenger, Webrick, Thin...)

Setup
=====

* checkout source :
`git clone ssh://git@gitlab.imagineapp.com:9228/sp-gestion.git
* go into master :
`cd sp-gestion
* install bundler :
`gem install bundler
* install all required gem :
`bundle install
* edit config/database.yml (if necessary)
* create database, load schema and import seed data :
`rake db:setup
* setup local dns or host file for *.dev resolution (native with Pow) and configure sp-gestion.dev
  Add 127.0.0.1       cpi-demo.sp-gestion.dev and 127.0.0.1  www.sp-gestion.dev in your hosts unless you have Pow
* copy `config/sp-gestion.sample.yml` to `config/sp-gestion.yml` and change its content to fit your setup
* browse www.sp-gestion.dev for home
* browse demo.sp-gestion.dev for a sample account (login : demo@sp-gestion.dev | pass : demospg)

Tests
=====

* run `rspec`

Production
==========

* if you want to use newrelic you must have an account () and generate the
`config/newrelic.yml` file by running `newrelic install` in the root folder of
the application