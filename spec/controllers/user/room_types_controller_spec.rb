require "rails_helper"

RSpec.describe User::RoomTypesController, type: :controller do
  let(:room_type) { FactoryBot.create(:room_type, name: "Deluxe Room") }
  let(:room) { FactoryBot.create(:room, room_type: room_type, floor: 1) }

  describe "GET #index" do
    before do
      room_type
      room
    end

    context "with no parameters" do
      before { get :index }

      it "assigns @room_types" do
        expect(assigns(:room_types)).to include(room_type)
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end
    end

    context "with valid date parameters" do
      let(:params) do
        { checkin_date: (Time.zone.today + 1.day).to_s, checkout_date: (Time.zone.today + 2.days).to_s }
      end

      before { get :index, params: params }

      it "assigns @checkin_date and @checkout_date" do
        expect(assigns(:checkin_date)).to eq(Time.zone.today + 1.day)
        expect(assigns(:checkout_date)).to eq(Time.zone.today + 2.days)
      end

      it "assigns @available_rooms" do
        expect(assigns(:available_rooms)[room_type.id]).to eq(room_type.rooms.count)
      end
    end

    context "with invalid date parameters" do
      let(:params) { { checkin_date: "invalid-date", checkout_date: "2025-07-03" } }

      before { get :index, params: params }

      it "assigns @date_error_message" do
        expect(assigns(:date_error_message)).to eq(I18n.t("errors.invalid_date_format"))
      end
    end

    context "with search parameters" do
      before { get :index, params: { q: { search_value: "Deluxe" } } }

      it "assigns @room_types with search results" do
        expect(assigns(:room_types)).to include(room_type)
      end
    end
  end

  describe "GET #show" do
    context "when room type exists" do
      before { get :show, params: { id: room_type.id } }

      it "assigns @room_type" do
        expect(assigns(:room_type)).to eq(room_type)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when room type does not exist" do
      before { get :show, params: { id: 999 } }

      it "sets a flash danger message" do
        expect(flash[:danger]).to eq(I18n.t("room_type_not_found"))
      end

      it "redirects to user_room_types_path" do
        expect(response).to redirect_to(user_room_types_path)
      end
    end
  end

  describe "private methods" do
    describe "#assign_dates" do
      context "with no date parameters" do
        before { controller.params = {} }

        it "returns true" do
          expect(controller.send(:assign_dates)).to be true
        end
      end

      context "with valid dates" do
        before do
          controller.params = {
            checkin_date: (Time.zone.today + 1.day).to_s,
            checkout_date: (Time.zone.today + 2.days).to_s
          }
          controller.send(:assign_dates)
        end

        it "assigns @checkin_date and @checkout_date" do
          expect(assigns(:checkin_date)).to eq(Time.zone.today + 1.day)
          expect(assigns(:checkout_date)).to eq(Time.zone.today + 2.days)
        end
      end

      context "with invalid date format" do
        before do
          controller.params = { checkin_date: "invalid-date", checkout_date: "2025-07-03" }
          controller.send(:assign_dates)
        end

        it "assigns @date_error_message" do
          expect(assigns(:date_error_message)).to eq(I18n.t("errors.invalid_date_format"))
        end
      end

      context "with past checkin date" do
        before do
          controller.params = {
            checkin_date: (Time.zone.today - 1.day).to_s,
            checkout_date: (Time.zone.today + 1.day).to_s
          }
          controller.send(:assign_dates)
        end

        it "assigns @date_error_message" do
          expect(assigns(:date_error_message)).to eq(I18n.t("errors.checkin_date_in_past"))
        end
      end

      context "with invalid checkout date" do
        before do
          controller.params = {
            checkin_date: (Time.zone.today + 1.day).to_s,
            checkout_date: (Time.zone.today + 1.day).to_s
          }
          controller.send(:assign_dates)
        end

        it "assigns @date_error_message" do
          expect(assigns(:date_error_message)).to eq(I18n.t("errors.checkout_date_invalid"))
        end
      end
    end

    describe "#available_quantity_for_range" do
      let(:checkin_date) { Time.zone.today + 1.day }
      let(:checkout_date) { Time.zone.today + 2.days }

      context "with no bookings" do
        before { room_type; room } # Đảm bảo room_type và room được tạo

        it "returns total room count" do
          quantity = controller.send(:available_quantity_for_range, room_type, checkin_date, checkout_date)
          expect(quantity).to eq(room_type.rooms.count)
        end
      end

      context "with missing dates" do
        before { room_type } # Chỉ cần room_type

        it "returns 0" do
          quantity = controller.send(:available_quantity_for_range, room_type, nil, nil)
          expect(quantity).to eq(0)
        end
      end
    end

    describe "#build_ransack_params" do
      it "handles search_value with default name_cont" do
        controller.params[:q] = { search_value: "Deluxe" }
        params = controller.send(:build_ransack_params)
        expect(params).to eq({ "name_cont" => "Deluxe" })
      end

      it "handles search_type and search_value" do
        controller.params[:q] = { search_type: "description_cont", search_value: "Cozy" }
        params = controller.send(:build_ransack_params)
        expect(params).to eq({ "description_cont" => "Cozy" })
      end

      it "returns empty hash when no search params" do
        controller.params[:q] = {}
        params = controller.send(:build_ransack_params)
        expect(params).to eq({})
      end
    end
  end
end
