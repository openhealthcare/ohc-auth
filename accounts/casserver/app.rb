$:.unshift File.dirname(__FILE__)

require 'casserver.rb'

# foo.rb
class CASServer::Server
  register Padrino::Helpers
  register Padrino::Admin::AccessControl
  register Padrino::Admin::Helpers

  enable :sessions
  set :session_id, "OHCSESS"

  class << self
    def dependencies; []; end
    def setup_application!; end
  end

  def login_email email
    account = Account.where(:email => email).first
    session["OHCSESS"] = account.id
    @current_account = account
  end

  get "/" do
    redirect "/cas/login"
  end

end
