require_relative "../../../app/api"
require "rack/test"

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods
    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:app) { API.new(ledger: ledger) }

    describe "POST /expenses.json" do
      before do
        header "Accept", "application/json"
        header "Content-Type", "application/json"
      end

      context "when the expense is successfully recorded" do
        let(:expense) { { "some" => "data" } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it "responds with a 200 (OK)" do
          post "/expenses", JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end

        it "returns the expense id" do
          post "/expenses", JSON.generate(expense)

          expect(parsed_response).to include("expense_id" => 417)
        end
      end

      context "when the expense fails validation" do
        let(:expense) { { "some" => "data" } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, nil, "Expense incomplete"))
        end

        it "responds with a 422 (Unprocessable entity)" do
          post "/expenses", JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end

        it "returns an error message" do
          post "/expenses", JSON.generate(expense)

          expect(parsed_response).to include("error" => "Expense incomplete")
        end
      end
    end

    describe "POST /expenses.xml" do
      before do
        header "Accept", "application/xml"
        header "Content-Type", "application/xml"
      end

      context "when the expense is successfully recorded" do
        let(:expense) { { "some" => "data" } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it "responds with a 200 (OK)" do
          post "/expenses", Ox.dump(expense)
          expect(last_response.status).to eq(200)
        end

        it "returns the expense id" do
          post "/expenses", Ox.dump(expense)

          expect(parsed_xml_response).to include("expense_id" => 417)
        end
      end

      context "when the expense fails validation" do
        let(:expense) { { "some" => "data" } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, nil, "Expense incomplete"))
        end

        it "responds with a 422 (Unprocessable entity)" do
          post "/expenses", Ox.dump(expense)
          expect(last_response.status).to eq(422)
        end

        it "returns an error message" do
          post "/expenses", Ox.dump(expense)

          expect(parsed_xml_response).to include("error" => "Expense incomplete")
        end
      end
    end

    describe "POST /expenses without headers" do
      let(:expense) { { "some" => "data" } }

      it "responds with a 406 (OK)" do
        post "/expenses", Ox.dump(expense)
        expect(last_response.status).to eq(406)
      end
    end

    describe "POST /expenses.html" do
      let(:expense) { "" }

      before do
        header "Accept", "text/html"
        header "Content-Type", "text/html"
      end

      it "responds with a 200 (OK)" do
        post "/expenses", expense
        expect(last_response.status).to eq(406)
      end
    end

    describe "GET /expenses/:date.json" do
      before do
        header "Accept", "application/json"
        header "Content-Type", "application/json"
      end

      context "when expenses exist on given date" do
        let(:expenses) { [ { "some" => "data" } ] }
        let(:date) { "2014-12-10" }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(expenses)
        end

        it "responds with a 200" do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end

        it "returns the expense records as JSON" do
          get "/expenses/#{date}"
          expect(parsed_response).to match_array(expenses)
        end
      end

      context "when there are no expenses on the given date" do
        let(:date) { "2073-10-12" }
        let(:expenses) { [] }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(expenses)
        end

        it "responds with a 200" do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end

        it "returns an empty array as JSON" do
          get "/expenses/#{date}"
          expect(parsed_response).to be_empty
        end
      end
    end

    describe "GET /expenses/:date.xml" do
      before do
        header "Accept", "application/xml"
        header "Content-Type", "application/xml"
      end

      context "when expenses exist on given date" do
        let(:expenses) { [ { "some" => "data" } ] }
        let(:date) { "2014-12-10" }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(expenses)
        end

        it "responds with a 200" do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end

        it "returns the expense records as JSON" do
          get "/expenses/#{date}"
          expect(parsed_xml_response).to match_array(expenses)
        end
      end

      context "when there are no expenses on the given date" do
        let(:date) { "2073-10-12" }
        let(:expenses) { [] }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(expenses)
        end

        it "responds with a 200" do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end

        it "returns an empty array as JSON" do
          get "/expenses/#{date}"
          expect(parsed_xml_response).to be_empty
        end
      end
    end

    describe "GET /expenses/:date.html" do
      let(:date) { "2073-10-12" }

      before do
        header "Accept", "text/html"
        header "Content-Type", "text/html"
      end

      it "responds with a 406" do
        get "/expenses/#{date}"
        expect(last_response.status).to eq(406)
      end
    end

    describe "GET /expenses/:date without headers" do
      let(:date) { "2073-10-12" }

      it "responds with a 406" do
        get "/expenses/#{date}"
        expect(last_response.status).to eq(406)
      end
    end
  end
end
