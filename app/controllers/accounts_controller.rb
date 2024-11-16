class AccountsController < ApplicationController
  ACCOUNTS = {}

  def reset
    ACCOUNTS.clear
    render json: "OK", status: :ok
  end

  def balance
    account_id = params[:account_id]
    if ACCOUNTS[account_id]
      render json: ACCOUNTS[account_id][:balance], status: :ok
    else
      render json: 0, status: :not_found
    end
  end

  def event
    operation = event_params.delete(:type)
    handler = Event::HandlerService.perform_for!(operation)
    response = handler.new(**event_params).perform!(ACCOUNTS)

    render json: response.body, status: response.status
  rescue ::Event::InvalidOperationType
    render json: { error: "Invalid event type" }, status: :unprocessable_entity
  rescue ::Event::AccountNotFound
    render json: 0, status: :not_found
  rescue ::Event::InsuficientFunds
    render json: { error: "Insufficient funds" }, status: :unprocessable_entity
  end

  private

  def event_params
    @event_params ||= params.permit(:type, :destination, :origin, :amount).to_h.symbolize_keys
  end
end
