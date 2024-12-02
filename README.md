Rails API

- start ngrok `ngrok http 3000`
- update `development.rb` to accept requests from ngrok
  
  ```ruby
  #development.rb
  
  Rails.application.configure do
    config.hosts << "ngrok host"
  end
  ```
  
- start server locally `rails server`

- test the application here: https://ipkiss.pragmazero.com/
