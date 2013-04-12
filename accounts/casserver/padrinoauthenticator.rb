

class CASServer::Authenticators::Padrino < CASServer::Authenticators::Base

  include Padrino::Admin::Helpers::AuthenticationHelpers

  # Main logic goes here.
  # takes a single hash argument. When the user
  # submits the login form, the username and password they entered is passed to
  # validate() as a hash under :username and :password keys.
  def validate(credentials)
    @session = credentials[:session]

    if account = Account.authenticate(credentials[:username], credentials[:password])
      @session["OHCSESS"] = account.id
      @current_account = account
      return true
     else
      # Logout logic
      # @session["OHCSESS"] = nil
      # @current_account = nil

      return false
    end
  end

end
