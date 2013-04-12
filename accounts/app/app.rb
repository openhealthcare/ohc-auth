module Accounts
  class App < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers


    register Padrino::Admin::AccessControl
    register Padrino::Admin::Helpers

    enable :sessions
    set :session_id, "OHCSESS"

    layout :ohc

    ##
    # Caching support
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_app/locales)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #

    helpers do

      ##
      # Return the account matching ID or nil
      #
      def account id
        begin
          @account = Account.find id
        rescue ActiveRecord::RecordNotFound
          @account = nil
        end
      end

      ##
      # If ACCOUNT is not the current account, redirect to TARGET
      #
      def edit_unless_current account
        if account != current_account
          redirect current_account.edit_path
        end
      end


    end


    get "/" do

      if !logged_in?
        return redirect "/cas/login"
      end

      @services = App.services
      render 'home'
    end

    get :login do
      redirect "/cas" + request.fullpath
    end

    get :proxyValidate do
      redirect "/cas" + request.fullpath
    end

    get :logout do
      @next = params[:url]

      if logged_in?
        if @next.nil?
          @next = '/logout'
        end
        set_current_account(nil)
        redirect "/cas/logout?url=#{@next}"
      else
        if @next.nil?
          @next = '/'
        end
        redirect @next
      end
    end

    get :signup do
      if logged_in?
        redirect "/"
      end
      @user = Account.new
      render :signup
    end

    post :signup do
      @user = Account.new(params[:account])
      @user.role = 'user'
      if @user.save
        set_current_account @user
        @verifier = EmailVerification.new :user_id => @user.id
        if @verifier.save
          @verifier.send_verification_link
        end
        redirect "/"
      else
        render :signup
      end
    end

    get '/confirm-email/:key' do
      verifier = EmailVerification.where(:key => params[:key]).first
      user = verifier.user
      user.verified = true
      user.save
      set_current_account user
      flash[:notice] = "Congratulations, You have verifed your email!"
      redirect "/"
    end

    ##
    # Edit page for a user's own account
    #
    get '/edit/:userid' do
      logged_in? || redirect("/")

      @account = account params[:userid]
      edit_unless_current @account

      render :edit_profile
    end

    ##
    # Process form for user detail changes.
    #
    post '/edit/:userid' do
      logged_in? || redirect("/")

      @account = account params[:userid]
      edit_unless_current @account

      if @account.update_attributes params[:account]
        if @account.save
          redirect @account.profile_path
        end
      end

      render :edit_profile

    end

    ##
    # View public profiles
    #
    get '/profile/:id' do
      @account = account params[:id]
      render :profile_detail
    end

    ##
    # Allow users to change their passwords.
    #
    # get '/change-password' do
    #   logged_in?||redirect("/")


    # end

    ##
    # Process forgotten password helps
    #

  end
end
