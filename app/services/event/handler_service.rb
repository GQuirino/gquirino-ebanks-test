module Event
  class AccountNotFound < StandardError; end
  class InsuficientFunds < StandardError; end
  class InvalidOperationType < StandardError; end
  class MissingDestination < StandardError; end

  class HandlerService
    attr_accessor :amount, :origin, :destination

    def self.perform_for!(operation)
      Rails.application.eager_load! if Rails.env.development? || Rails.env.test?

      handler = HandlerService.descendants.find { |d| d.apply_to?(operation) }

      raise InvalidOperationType, "Invalid event type" unless handler

      handler
    end

    def initialize(amount:, destination: nil, origin: nil)
      @amount = amount&.to_i
      @destination = destination
      @origin = origin
    end

    def perform!(_accounts); end

    private

    def response(status, body)
      ::OpenStruct.new(status:, body:)
    end
  end
end
