##
# Setup global project settings
#
$:.unshift File.dirname(__FILE__)
require "mail"
begin
  require "local_settings"
rescue LoadError
  module LocalSettings end
end

Padrino.configure_apps do
  set :sessions,
    :key          => '__my_app_name_unique',
    :secret       => Digest::SHA1.hexdigest(['no_the_best_secret_key'].pack('m')),
    :expire_after => 1.year
  set :protection, true
  set :protect_from_csrf, true

  mailopts = {
    :address              => 'smtp.gmail.com',
    :port                 => 587,
    :domain               => 'openhealthcare.org.uk',
    :user_name            => LocalSettings::USER,
    :password             => LocalSettings::PASS,
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

  Mail.defaults do
    delivery_method :smtp, mailopts
  end

  if Padrino.env == :production
    set :services,  [
                     {
                       :name => "Open Prescribing",
                       :logo => "http://www.openprescribing.org/static//img/op-logo.png",
                       :url => "http://www.openprescribing.org/login"
                     },
                     {
                       :name => "Open Formulary",
                       :logo => "http://formulary.openhealthcare.org.uk/static/img/logo2.png",
                       :url => "http://formulary.openhealthcare.org.uk/login"
                     },
                     {
                       :name => "Randomise Me",
                       :logo => "http://byta.randomizeme.org/static/img/randomisemelogo.png",
                       :url => "http://byta.randomizeme.org/cas/login",
                       :admin => true
                     }
                    ]
        ENV['CONFIG_FILE'] = File.expand_path('config/cas.production.yml')
  else
    set :services,  [
                     {
                       :name => "Open Prescribing",
                       :logo => "http://www.openprescribing.org/static/img/op-logo.png",
                       :url => "http://localhost:8080/login"
                     },
                     {
                       :name => "Open Formulary",
                       :logo => "http://formulary.openhealthcare.org.uk/static/img/logo2.png",
                       :url => "http://localhost:5000/login"
                     },
                     {
                       :name => "Randomise Me",
                       :logo => "http://byta.randomizeme.org/static/img/randomisemelogo.png",
                       :url => "http://localhost:5555/cas/login",
                       :admin => true
                     }
                    ]
    ENV['CONFIG_FILE'] = File.expand_path('config/cas.yml')
  end
  ENV['CUSTOM_VIEWS'] = File.expand_path('casserver/casserver/views')
end


# Mounts the core application for this project
Padrino.mount('Accounts::App', :app_file => Padrino.root('app/app.rb')).to('/')

Padrino.mount("Accounts::Admin", :app_file => File.expand_path('../../admin/app.rb', __FILE__)).to("/admin")

Padrino.mount("CASServer::Server",  :app_file => File.expand_path('casserver/app.rb')).to("/cas")
