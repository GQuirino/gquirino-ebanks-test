module Event
  class DepositService < HandlerService
    OPERATION_NAME = "deposit".freeze

    def self.apply_to?(operation)
      operation == OPERATION_NAME
    end

    def perform!(accounts)
      accounts[destination] ||= { id: destination, balance: 0 }
      accounts[destination][:balance] += amount

      response(:created, destination: accounts[destination])
    end
  end
end
