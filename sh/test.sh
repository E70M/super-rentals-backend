#!/bin/bash
bundle exec rake db:reset RAILS_ENV=test
bundle exec rspec