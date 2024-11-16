require "test_helper"
require "minitest/spec"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  setup do
    silence_warnings do
      @accounts = {
        "100" => { id: "100", balance: 50 },
        "200" => { id: "200", balance: 100 }
      }
      AccountsController.const_set("ACCOUNTS", @accounts)
    end
  end

  def teardown
    silence_warnings do
      AccountsController.const_set("ACCOUNTS", @original_accounts)
    end
  end

  describe "get /balance" do
    test "should return balance for existing account" do
      get balance_path, params: { account_id: "100" }
      assert_response :ok
      assert_equal "50", @response.body
    end

    test "should return 0 for non-existing account" do
      get balance_path, params: { account_id: "300" }
      assert_response :not_found
      assert_equal "0", @response.body
    end
  end

  describe "post /event #deposit" do
    test "should deposit into existing account" do
      post event_path, params: { type: "deposit", destination: "100", amount: 50 }
      assert_response :created
      assert_equal({ destination: { id: "100", balance: 100 } }.to_json, @response.body)
      assert_equal 100, @accounts["100"][:balance]
    end

    test "should create a new account and deposit initial balance" do
      post event_path, params: { type: "deposit", destination: "200", amount: 50 }
      assert_response :created
      assert_equal({ destination: { id: "200", balance: 150 } }.to_json, @response.body)
      assert_equal 150, @accounts["200"][:balance]
    end
  end


  describe "post /event #withdraw" do
    test "should withdraw from existing account" do
      post event_path, params: { type: "withdraw", origin: "100", amount: 30 }
      assert_response :created
      assert_equal({ origin: { id: "100", balance: 20 } }.to_json, @response.body)
      assert_equal 20, @accounts["100"][:balance]
    end

    test "should return error for insufficient funds" do
      post event_path, params: { type: "withdraw", origin: "100", amount: 100 }
      assert_response :unprocessable_entity
      assert_equal({ error: "Insufficient funds" }.to_json, @response.body)
    end

    test "should return error for non-existing account" do
      post event_path, params: { type: "withdraw", origin: "300", amount: 100 }
      assert_response :not_found
      assert_equal("0", @response.body)
    end
  end


  describe "post /event #transfer" do
    test "should transfer between @accounts" do
      @accounts["200"] = { id: "200", balance: 10 }

      post event_path, params: { type: "transfer", origin: "100", destination: "200", amount: 40 }
      assert_response :created
      assert_equal(
        { origin: { id: "100", balance: 10 }, destination: { id: "200", balance: 50 } }.to_json,
        @response.body
      )
      assert_equal 10, @accounts["100"][:balance]
      assert_equal 50, @accounts["200"][:balance]
    end

    test "should return error for transfer from non-existing account" do
      post event_path, params: { type: "transfer", origin: "300", destination: "100", amount: 50 }
      assert_response :not_found
      assert_equal "0", @response.body
    end
  end

  describe "post /event #invalid_type" do
    test "should return error for invalid operation type" do
      post event_path, params: { type: "invalid_type" }
      assert_response :unprocessable_entity
      assert_equal({ error: "Invalid event type" }.to_json, @response.body)
    end
  end
end
