module Capybara::RSpecMatchers
  def expect_sendgrid_header_data(current_email, field, value)
    sendgrid_header = JSON.parse( current_email.header['X-SMTPAPI'].to_s )

    expect( sendgrid_header[field] ).to eql( value )
  end
end
