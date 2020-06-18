class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController
  
  skip_before_action :verify_authenticity_token
end