class ZendeskTicketsController < ApplicationController
  skip_before_action :authenticate_user!
  # before_action :validate_local_zendesk_ticket, only: [:create]

  def create
    ts = ZendeskAPI::Ticket.new(ZendeskClient.instance, ZendeskTicket.payload(
      form_params,
      request.env["HTTP_USER_AGENT"])
    )
    binding.remote_pry
    ts.comment.uploads << form_params[:attachment].tempfile if form_params[:attachment].present?
    response = ts.save

    render json: response

    # end
    # respond 
    # if ts
    #   flash[:success] = 'Successfully submitted help ticket'
    #   redirect_back(fallback_location: root_path)
    # else
    #   flash[:error] = ts.errors['base'].collect{ |x| x['description'] }.join(", ")
    #   redirect_back(fallback_location: root_path)
    # end
  end

  private

  def form_params
    params.require(:zendesk_ticket).permit!
  end

  def validate_local_zendesk_ticket
    local_zendesk_ticket = ZendeskTicket.new(form_params)

    unless local_zendesk_ticket.valid?
      flash[:error] = local_zendesk_ticket.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  def browser_metadata
    #TODO: MERGE INTO.
    # Use `browser` gem
    {
      name: request.env["HTTP_USER_AGENT"],
      project: 'ECFR',
    }
  end
end
