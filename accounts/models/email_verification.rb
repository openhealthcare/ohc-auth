##
# Verification model
#
require 'haml'
require 'mail'
require 'securerandom'

##
# Create the  string
#
def html_message verify_url
  tpl_file = File.expand_path(File.dirname(__FILE__) + '/../app/views/email_verification.haml')
  engine = Haml::Engine.new File.read(tpl_file)
  engine.render(Object.new, :verify_url => verify_url)
end

class EmailVerification < ActiveRecord::Base

  # Validations
  validates_presence_of :user_id

  # Callbacks
  before_create :generate_key

  ##
  # Send the user an email with their verification link
  #
  def send_verification_link
    account = self.user
    target = self.verify_link
    html_msg = html_message target

    Mail.deliver do
      to account.email
      from "Open Health Care Accounts <hello@openhealthcare.org.uk>"
      subject "Verify your Open Health Care account"

      text_part do
        body "Please visit the following URL in your web browser \n #{target}"
      end

      html_part do
        content_type 'text/html; charset=UTF-8'
        body html_msg
      end
    end

    self.sent = DateTime.now
  end

  def user
    Account.find self.user_id
  end

  ##
  # Generate the link for this verification
  #
  def verify_link
    "http://auth.openhealthcare.org.uk/confirm-email/#{self.key}"
  end

  private

  ##
  # Generate the Unique key for our verification
  #
  def generate_key
    self.key = SecureRandom.hex 32
    self.created = DateTime.now
  end

end
