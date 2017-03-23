require_relative "../config/sequel"

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def record(expense)
      unless valid?(expense)
        message = "Invalid expense: #{@errors.join(', ')} "

        return RecordResult.new(false, nil, message)
      end

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    private

    def self.fields
      @fields ||= %w| payee amount date |.freeze
    end

    def fields
      self.class.fields
    end

    def valid?(expense)
      @errors ||= fields.reject { |field| expense.key?(field) }
        .map { |field| "`#{field}` is required" }
      @errors.empty?
    end
  end
end
