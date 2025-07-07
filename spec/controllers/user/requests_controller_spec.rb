require "rails_helper"

RSpec.describe User::RequestsController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:user) { FactoryBot.create(:user, activated: true) }
  let(:room_type) { FactoryBot.create(:room_type, name: "Deluxe Room", price: 100.0) }
  let(:request) { FactoryBot.create(:pending_request, user: user, room_type: room_type) }
  let(:deposited_request) { FactoryBot.create(:request, user: user, room_type: room_type, status: "deposited") }

  before do
    sign_in user
    allow(controller).to receive(:authorize!).and_return(true) 
  end

  describe "GET #new" do
    it "assigns a new request with params" do
      get :new, params: { checkin_date: Date.today.to_s, checkout_date: Date.tomorrow.to_s, room_type_id: room_type.id, quantity: 2 }
      expect(assigns(:request)).to be_a_new(Request)
      expect(assigns(:request).checkin_date).to eq(Date.today)
      expect(assigns(:request).checkout_date).to eq(Date.tomorrow)
      expect(assigns(:request).room_type_id).to eq(room_type.id)
      expect(assigns(:request).quantity).to eq(2)
    end

    it "authorizes create action" do
      expect(controller).to receive(:authorize!).with(:create, Request)
      get :new
    end
  end

  describe "GET #index" do
    before { request }

    it "assigns paginated requests for current user" do
      get :index
      expect(assigns(:pagy)).to be_a(Pagy)
      expect(assigns(:requests)).to include(request)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) do
        {
          request: {
            checkin_date: Date.today.to_s,
            checkout_date: Date.tomorrow.to_s,
            room_type_id: room_type.id,
            quantity: 1
          }
        }
      end

      it "creates a new request and redirects" do
        expect {
          post :create, params: valid_params
        }.to change(Request, :count).by(1)
        expect(response).to redirect_to(user_request_path(assigns(:request)))
        expect(flash[:success]).to eq(I18n.t("request_successfull"))
      end
    end

    context "with invalid room_type_id" do
      let(:invalid_params) do
        {
          request: {
            checkin_date: Date.today.to_s,
            checkout_date: Date.tomorrow.to_s,
            room_type_id: nil,
            quantity: 0
          }
        }
      end

      it "redirects to user_room_types_path with flash error" do
        post :create, params: invalid_params
        expect(response).to redirect_to(user_room_types_path)
        expect(flash[:alert]).to eq(I18n.t("room_type.not_found"))
      end
    end

    context "without authorization" do
      before do
        allow(controller).to receive(:can?).with(:create, Request).and_return(false)
      end

      it "redirects to root with access denied" do
        post :create, params: { request: { room_type_id: room_type.id } }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("msg.access_denied"))
      end
    end
  end

  describe "GET #show" do
    context "when request exists" do
      context "when request is pending" do
        it "assigns @request" do
          get :show, params: { id: request.id }
          expect(assigns(:request)).to eq(request)
        end

        it "renders the show template" do
          get :show, params: { id: request.id }
          expect(response).to render_template(:show)
        end

        it "generates QR code" do
          get :show, params: { id: request.id }
          expect(assigns(:svg_qr)).to be_present
          expect(assigns(:confirm_url)).to include(request.token)
        end
      end

      context "when request is deposited" do
        it "redirects to root_path" do
          get :show, params: { id: deposited_request.id }
          expect(response).to redirect_to(root_path)
        end

        it "sets flash success if params[:success] is present" do
          get :show, params: { id: deposited_request.id, success: true }
          expect(flash[:success]).to eq(I18n.t("payment.deposit_success"))
        end
      end
    end

    context "when request does not exist" do
      it "sets a flash danger message" do
        get :show, params: { id: 999 }
        expect(flash[:danger]).to eq(I18n.t("request.not_found"))
      end

      it "redirects to root_path" do
        get :show, params: { id: 999 }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #confirm" do
    context "with valid token and pending status" do
      it "updates request to deposited and redirects" do
        get :confirm, params: { id: request.id, token: request.token }
        expect(request.reload.status).to eq("deposited")
        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to eq(I18n.t("payment.deposit_success"))
      end
    end

    context "with invalid token" do
      it "redirects with error" do
        get :confirm, params: { id: request.id, token: "invalid" }
        expect(response).to redirect_to(user_requests_path)
        expect(flash[:danger]).to eq(I18n.t("confirm_denied"))
      end
    end
  end

  describe "POST #expire" do
    context "when request is pending" do
      it "updates status to denied and returns JSON" do
        post :expire, params: { id: request.id }, format: :json
        expect(request.reload.status).to eq("denied")
        expect(JSON.parse(response.body)).to include(
          "redirect" => user_room_types_path,
          "flash" => { "danger" => I18n.t("payment.expired") }
        )
      end
    end
  end

  describe "GET #status_check" do
    context "when request is deposited" do
      it "returns deposited status with redirect" do
        get :status_check, params: { id: deposited_request.id }, format: :json
        expect(JSON.parse(response.body)).to include(
          "deposited" => true,
          "redirect" => user_requests_path,
          "flash" => { "success" => I18n.t("payment.deposit_success") }
        )
      end
    end

    context "when request is not deposited" do
      it "returns non-deposited status" do
        get :status_check, params: { id: request.id }, format: :json
        expect(JSON.parse(response.body)).to include("deposited" => false)
      end
    end
  end

  describe "private methods" do
    describe "#find_request" do
      context "when request is not found" do
        it "redirects to root with flash" do
          get :show, params: { id: 999 }
          expect(response).to redirect_to(root_path)
          expect(flash[:danger]).to eq(I18n.t("request.not_found"))
        end
      end
    end

    describe "#find_room_type" do
      before do
        allow(RoomType).to receive(:find_by).and_return(nil)
      end

      it "redirects when room type is not found" do
        get :show, params: { id: request.id }
        expect(response).to redirect_to(user_room_types_path)
        expect(flash[:danger]).to eq(I18n.t("room_type.not_found"))
      end
    end

    describe "#prepare_request_data" do
      it "assigns dates, room type, quantity, and calculates total price" do
        controller.params = {
          request: {
            checkin_date: Date.today.to_s,
            checkout_date: Date.tomorrow.to_s,
            room_type_id: room_type.id,
            quantity: 2
          }
        }
        controller.send(:prepare_request_data)
        expect(controller.instance_variable_get(:@checkin_date)).to eq(Date.today)
        expect(controller.instance_variable_get(:@stay_duration)).to eq(1)
        expect(controller.instance_variable_get(:@total_price)).to eq(room_type.price * 1 * 2)
      end
    end
  end
end
