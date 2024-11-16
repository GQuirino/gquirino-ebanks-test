module Event
  class TransferService < HandlerService
    OPERATION_NAME = "transfer".freeze

    def self.apply_to?(operation)
      operation == OPERATION_NAME
    end

    def perform!(accounts)
      raise AccountNotFound unless accounts[origin]
      raise InsuficientFunds if amount > accounts[origin][:balance]

      accounts[origin][:balance] -= amount
      accounts[destination] ||= { id: destination, balance: 0 }
      accounts[destination][:balance] += amount

      response(:created, origin: accounts[origin], destination: accounts[destination])
    end
  end
end
