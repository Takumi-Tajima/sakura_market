class Admins::ApplicationController < ActionController::Base
  allow_browser versions: :modern
  layout 'admin'
end
