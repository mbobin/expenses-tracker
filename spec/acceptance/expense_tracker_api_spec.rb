require "rack/test"
require "json"
require_relative "../../app/api"

module ExpenseTracker
  RSpec.describe "Expense Tracker API", :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post "/expenses", JSON.generate(expense)
      expect(last_response.status).to eq(200)

      expect(parsed_response).to include("expense_id" => a_kind_of(Integer))
      expense.merge("id" => parsed_response["expense_id"])
    end

    before do
      header "Accept", "application/json"
      header "Content-Type", "application/json"
    end

    it "records submitted expenses" do
      coffee = post_expense(
        "payee" => "Starbucks",
	      "amount" => 5.75,
	      "date" => "2014-10-17"
      )

      zoo = post_expense(
        "payee" => "Zoo",
        "amount" => 15.25,
        "date" => "2014-10-17"
      )

      groceries = post_expense(
        "payee" => "Whole Foods",
        "amount" => 95.20,
        "date" => "2014-10-18"
      )

      get "/expenses/2014-10-17"
      expect(last_response.status).to eql(200)
      expect(parsed_response).to contain_exactly(coffee, zoo)
    end
  end
end

