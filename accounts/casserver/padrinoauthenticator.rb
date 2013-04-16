

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
      extract_extra(account)
      return true
     else
      return false
    end
  end

  ##
  # Set the extra_attributes we want
  #
  def extract_extra account
    @extra_attributes = {}
    %w[name surname email role].each do | attr |
      @extra_attributes[attr] = account.send(attr)
    end
    puts "extract_extra() #{@extra_attributes}"
  end

end
