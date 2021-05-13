class ZendeskTicket
  include ActiveModel::Model

  attr_accessor :subject, :comment, :email, :name, :technical_help, :attachment

  validates_presence_of :subject
  validates_presence_of :comment
  validates_presence_of :email
  validates :technical_help, acceptance: true

  def self.payload(params, browser_metadata)
    {
      :subject => params[:subject],
      :comment => { :value => params[:comment] },
      :requester => {
        :email => params[:email],
        :name => params[:name]
      },
      :custom_fields => [
        { 360053300454 => browser_metadata }
      ]
    }
  end
end
