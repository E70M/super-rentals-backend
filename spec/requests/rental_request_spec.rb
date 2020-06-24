require 'rails_helper'

api_headers = { "Content-Type" => "application/vnd.api+json" }

RSpec.describe "Rentals" do
  describe 'GET #index' do
    it "returns empty rental list" do
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:success)
      expect(res_hash[:data].count).to eq(0)
    end
  end

  describe 'POST #create' do
    it "creates rental" do
      rental = create(:rental)
      get "/rentals/#{rental.id}", { headers: api_headers }
      expect(response).to have_http_status(:success)
    end

    it "increases rental count by 1" do
      expect{ create(:rental) }.to change{ Rental.count }.by(1)
    end

    it "does not create duplicate rental" do
      # GET all available rentals, find count
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      comp_size = res_hash[:data].count + 1
      # POST same rental twice - expect to raise error
      rental = create(:rental)
      expect{create(:rental, title: rental.title, owner: rental.owner, city: rental.city,
        category: rental.category, bedrooms: rental.bedrooms)}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not create rental with missing information" do
      expect{create(:rental, title: "")}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'GET #show' do
    let!(:rental) { create(:rental) }

    it "returns rental" do
      get "/rentals/#{rental.id}", { headers: api_headers }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let!(:rental) { create(:rental) }
    let(:params) do
      {
        "data": {
          "id": rental.id,
          "type": "rentals",
          "attributes": {
            "city": Faker::Address.city
          }
        }
      }
    end

    it "updates rental" do
      patch "/rentals/#{rental.id}", { params: params.to_json, headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:success)
      expect(rental.reload.city).to eq(params[:data][:attributes][:city])
    end

    it "does not change rental count" do
      expect do
        patch "/rentals/#{rental.id}", { params: params.to_json, headers: api_headers }
      end.to change{ Rental.count }.by(0)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE #destroy' do
    let!(:rental) { create(:rental) }
    before { get "/rentals", { headers: api_headers } }

    it "deletes rental" do
      delete "/rentals/#{rental.id}", { headers: api_headers }
      # GET rental by id, check it has been deleted
      get "/rentals/#{rental.id}", { headers: api_headers }
      expect(response).to have_http_status(:missing)
    end

    it "decreases rental count by 1" do
      res_hash = JSON.parse(response.body, symbolize_names: true)
      comp_size = res_hash[:data].count - 1
      delete "/rentals/#{rental.id}", { headers: api_headers }
      # GET all available rentals, check collection size has decreased by 1
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:success)
      expect(res_hash[:data].count).to eq(comp_size)
    end

    it "does not delete a non-existent record" do
      delete "/rentals/#{rental.id}", { headers: api_headers }
      # DELETE same rental - expect to raise error
      delete "/rentals/#{rental.id}", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(response).not_to have_http_status(:success)
      expect(res_hash[:errors][0][:title]).to eq("Record not found")
    end
  end
end