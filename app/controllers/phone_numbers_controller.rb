class PhoneNumbersController < ApplicationController
  before_action :set_user
  before_action :verified_number, except: %i[index]

  def index
    render json: { phone_number: @user.phone_number,
                   verified: @user.phone_verified },
           status: :ok
  end

  def create
    @user.update!(phone_number: params[:phone_number])
    @user.generate_and_send_phone_pin!

    render json: { success: true }, status: :created
  end

  def verify
    if @user.phone_number != params[:phone_number]
      render json: { phone_number: ["wrong number received."] },
             status: :bad_request

    elsif @user.verify_phone(params[:pin])
      render json: { success: true }, status: :ok

    else # !@user.verify_phone(params[:pin])
      render json: { pin: ["wrong PIN entered."] },
             status: :unprocessable_entity

    end
  end

  private

  def verified_number
    return unless @user.phone_verified?

    render json: { phone_number: ["already verified."] },
           status: :bad_request
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
