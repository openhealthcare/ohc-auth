# Our customisations to the Ruby CAS server
module CASServer
  class Server < CASServer::Base

    # config = HashWithIndifferentAccess.new(
    #   :maximum_unused_login_ticket_lifetime => 5.minutes,
    #   :maximum_unused_service_ticket_lifetime => 5.minutes, # CAS Protocol Spec, sec. 3.2.1 (recommended expiry time)
    #   :maximum_session_lifetime => 2.days, # all tickets are deleted after this period of time
    #   :log => {:file => 'casserver.log', :level => 'DEBUG'},
    #   :uri_path => ""
    # )
    # set :config, config

    # load_config_file CONFIG_FILE

    # puts config

    womble_conf = config

    get /^#{uri_path}\/?$/ do

      # make sure there's no caching
      headers['Pragma'] = 'no-cache'
      headers['Cache-Control'] = 'no-store'
      headers['Expires'] = (Time.now - 1.year).rfc2822

      accounts =  womble_conf['accounts_url']

      ticket = params['ticket']
      if ticket
        redirect accounts
      end

      if tgc = request.cookies['tgt']
        tgt, tgt_error = validate_ticket_granting_ticket(tgc)
      end

      puts womble_conf


      if !tgt or tgt_error
        redirect "/login?service=#{accounts}", 303
        return
      end

      @authenticated_username = tgt.username
      @authenticated = true

      @services =  womble_conf['ohc_services']
      render @template_engine,  :home
    end

  end
end
