module Event
  class WithdrawService < HandlerService
    OPERATION_NAME = "withdraw".freeze
    SPECIAL_LIMIT = -1000.freeze

    def self.apply_to?(operation)
      operation == OPERATION_NAME
    end

    def perform!(accounts)
      raise AccountNotFound unless accounts[origin]
      # raise InsuficientFunds unless has_found?(accounts[origin], amount) && !use_special_limit?(accounts[origin], amount)

      if has_found?(accounts[origin], amount)
        accounts[origin][:balance] -= amount
      elsif use_special_limit?(accounts[origin], amount)
        balance = accounts[origin][:balance]
        accounts[origin][:balance] -= amount if balance - amount >= SPECIAL_LIMIT
      end

      response(:created, origin: accounts[origin])
    end

    def use_special_limit?(account, amount)
      return false if has_found?(account, amount)

      account[:balance] <= 0
    end

    def has_found?(account, amount)
      account[:balance] >= amount
    end
  end
end
