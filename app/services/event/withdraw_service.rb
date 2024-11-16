module Event
  class WithdrawService < HandlerService
    OPERATION_NAME = "withdraw".freeze

    def self.apply_to?(operation)
      operation == OPERATION_NAME
    end

    def perform!(accounts)
      raise AccountNotFound unless accounts[origin]
      raise InsuficientFunds if amount > accounts[origin][:balance]

      accounts[origin][:balance] -= amount
      response(:created, origin: accounts[origin])
    end
  end
end
