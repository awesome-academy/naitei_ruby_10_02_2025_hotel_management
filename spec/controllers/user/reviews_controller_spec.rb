require "rails_helper"

RSpec.describe User::ReviewsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:review) { FactoryBot.build(:review, user: user, score: Settings.reviews_score, content: Settings.reviews_content) }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          review: {
            score: Settings.reviews_score,
            content: Settings.reviews_content
          }
        }
      end

      it "creates a new review and redirects" do
        expect {
          post :create, params: valid_params
        }.to change(Review, :count).by(1)
        expect(response).to redirect_to(user_room_types_path)
        expect(flash[:success]).to eq(I18n.t("reviews.created"))
      end

      it "authorizes create action" do
        expect(controller).to receive(:authorize!).with(:create, instance_of(Review)).at_least(:once)
        post :create, params: valid_params
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          review: {
            score: nil,
            content: ""
          }
        }
      end

      it "does not create a review and redirects" do
        expect {
          post :create, params: invalid_params
        }.not_to change(Review, :count)
        expect(response).to redirect_to(user_room_types_path)
        expect(flash[:danger]).to eq(I18n.t("reviews.create_failed"))
      end
    end

    context "when user is not authenticated" do
      before do
        sign_out user
        post :create, params: { review: { score: Settings.reviews_score, content: Settings.reviews_content } }
      end

      it "redirects to sign in page" do
        expect(response.location).to match(/\/user\/sign_in/)
      end
    end

    context "without authorization" do
      before do
        allow(controller).to receive(:authorize!).and_raise(CanCan::AccessDenied)
      end
      
      it "redirects to root with access denied" do
        post :create, params: { review: { score: Settings.reviews_score, content: "Nope" }, locale: :en }
        expect(response).to redirect_to root_path(locale: :en)
        expect(flash[:danger]).to eq Settings.access_denied
      end
      
    end
  end

  describe "private methods" do
    describe "#review_params" do
      let(:params) do
        ActionController::Parameters.new(
          review: {
            score: Settings.reviews_score,
            content: Settings.reviews_content,
            unauthorized_field: "malicious"
          }
        )
      end

      before do
        allow(controller).to receive(:params).and_return(params)
      end

      it "permits only score and content from REVIEW_PARAMS" do
        expect(controller.send(:review_params)).to eq(
          ActionController::Parameters.new(score: Settings.reviews_score, content: Settings.reviews_content).permit(:score, :content)
        )
      end
    end
  end
end


