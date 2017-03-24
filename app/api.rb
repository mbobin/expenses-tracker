require "sinatra/base"
require_relative "ledger"
require_relative "responder"

module ExpenseTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    post "/expenses" do
      responder = Responder.build(request)
      error 406 unless responder
      headers "Content-Type" => responder.content_type

      expense = responder.deserialize(request.body.read)
      result = @ledger.record(expense)
      if result.success?
        responder.serialize("expense_id" => result.expense_id)
      else
        status 422
        responder.serialize("error" => result.error_message)
      end
    end

    get "/expenses/:date" do
      responder = Responder.build(request)
      error 406 unless responder
      headers "Content-Type" => responder.content_type

      result = @ledger.expenses_on(params["date"])
      responder.serialize(result)
    end
  end
end
