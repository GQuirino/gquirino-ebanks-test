Rails.application.routes.draw do
  get "/balance", to: "accounts#balance"
  post "/event", to: "accounts#event"

  post "/reset", to: "accounts#reset"
end
