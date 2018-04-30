# bundle exec rails runner 'TestMailer.ping("somebody@greenriver.com").deliver_now'

class TestMailer < DatabaseMailer#ActionMailer::Base
  default from: 'noreply@greenriver.com'

  def ping(email)
    mail({
      to: [email],
      subject: 'test'
    }) do |format|
      format.text { render plain: "Test #{SecureRandom.hex(6)}" }
    end
  end
end
