#!/bin/bash
rails db:environment:set RAILS_ENV=test
bundle exec rspec