module Api
  module V1
    class RoomTypesController < BaseController
      before_action :set_room_type, only: [:check]
      skip_before_action :authenticate_user, only: [:check]

      def check
        checkin_date, checkout_date = parse_dates(params[:checkin_date],
                                                  params[:checkout_date])
        return unless checkin_date && checkout_date

        return render_checkin_after_checkout if checkin_date >= checkout_date
        return render_invalid_date if date_in_past?(checkin_date,
                                                    checkout_date)

        available_rooms = @room_type.get_available_rooms(checkin_date,
                                                         checkout_date)
        render json: {
          available_rooms: available_rooms.count,
          room_type: @room_type
        }
      rescue ArgumentError
        render_invalid_date_format
      end

      private

      def set_room_type
        @room_type = RoomType.find_by(id: params[:room_type_id])
        return if @room_type

        render json: {errors: [Settings.error.room_type_not_found]},
               status: :not_found
      end

      def parse_dates checkin_str, checkout_str
        [Date.parse(checkin_str), Date.parse(checkout_str)]
      rescue ArgumentError
        render_invalid_date_format
        [nil, nil]
      end

      def date_in_past? checkin, checkout
        checkin < Time.zone.today || checkout < Time.zone.today
      end

      def render_checkin_after_checkout
        render json: {errors: [Settings.messages.error.checkin_after_checkout]},
               status: :unprocessable_entity
      end

      def render_invalid_date
        render json: {errors: [Settings.messages.error.invalid_date_format]},
               status: :unprocessable_entity
      end

      def render_invalid_date_format
        render json: {
          errors: [Settings.messages.invalid_date_format]
        }, status: :unprocessable_entity
      end
    end
  end
end
