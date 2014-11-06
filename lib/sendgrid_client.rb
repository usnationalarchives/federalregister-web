class SendgridClient
  include HTTParty
  base_uri 'https://sendgrid.com'
  format :json

  default_params :api_user => SECRETS['sendgrid']['username'], :api_key => SECRETS['sendgrid']['password']

  def remove_from_bounce_list(email)
    self.class.get('/api/bounces.delete.json', :query => {:email => email}).parsed_response
  rescue
    nil
  end
end
