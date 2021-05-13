class ZendeskTicketsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    ticket = ZendeskAPI::Ticket.new(ZendeskClient.instance, ZendeskTicket.payload(
      form_params,
      params[:browser_metadata]
    ))
    ticket.comment.uploads << form_params[:attachment].tempfile if form_params[:attachment].present?

    if ticket.save
      render json: {}
    else
      render json: {errors: ticket.errors}, status: 422
    end
  end

  private

  def form_params
    params.require(:zendesk_ticket).permit!
  end

end
