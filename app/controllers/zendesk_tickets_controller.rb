class ZendeskTicketsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    ticket = ZendeskAPI::Ticket.new(ZendeskClient.instance, ZendeskTicket.payload(
      form_params,
      params[:browser_metadata]
    ))
    if form_params[:attachment].present?
      ticket.comment.uploads << {
        :filename => form_params[:attachment].original_filename,
        :file     => form_params[:attachment].tempfile,
      }
    end

    if params[:browser_metadata].blank?
      Honeybadger.notify('Missing browser metadata', context: form_params)
      render json: {}
    elsif ticket.save
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
