require "rails_helper"

RSpec.describe ServicesController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { FactoryBot.create(:user, admin: true) }
  let!(:service) { FactoryBot.create(:service) }

  before do
    sign_in admin
    allow(controller).to receive(:current_user).and_return(admin)
  end

  describe "GET #index" do
    it "renders index and assigns services" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:services)).to include(service)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    it "assigns new service" do
      get :new
      expect(assigns(:service)).to be_a_new(Service)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) do
        {
          service: {
            name: "Spa",
            description: "Relaxing spa service",
            price: 200_000
          }
        }
      end

      it "creates service and redirects" do
        expect {
          post :create, params: valid_params
        }.to change(Service, :count).by(1)
        expect(response).to redirect_to(services_path)
        expect(flash[:success]).to eq(I18n.t("msg.service_created"))
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          service: {
            name: "",
            description: "",
            price: nil
          }
        }
      end

      it "renders :new with unprocessable_entity" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #edit" do
    it "renders the edit template" do
      get :edit, params: { id: service.id }
      expect(response).to render_template(:edit)
      expect(assigns(:service)).to eq(service)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the service and redirects" do
        patch :update, params: { id: service.id, service: { name: "New Name" } }
        expect(response).to redirect_to(services_path)
        expect(flash[:success]).to eq(I18n.t("msg.service_updated"))
        expect(service.reload.name).to eq("New Name")
      end
    end

    context "with invalid params" do
      it "renders edit with unprocessable_entity" do
        patch :update, params: { id: service.id, service: { name: "" } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when destroy successful" do
      it "deletes the service and redirects" do
        expect {
          delete :destroy, params: { id: service.id }
        }.to change(Service, :count).by(-1)
        expect(response).to redirect_to(services_path)
        expect(flash[:success]).to eq(I18n.t("msg.service_deleted"))
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Service).to receive(:destroy).and_return(false)
      end

      it "shows error flash and redirects" do
        delete :destroy, params: { id: service.id }
        expect(response).to redirect_to(services_path)
        expect(flash[:error]).to eq(I18n.t("msg.service_delete_failed"))
      end
    end
  end
end
