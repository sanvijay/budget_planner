class BenefitsController < ApplicationController
  before_action :set_user
  before_action :set_benefit, only: %i[show update destroy]

  # GET /benefits
  def index
    @benefits = @user.benefits

    render json: @benefits
  end

  # GET /benefits/1
  def show
    render json: @benefit
  end

  # POST /benefits
  def create
    @benefit = @user.benefits.build(benefit_params)

    if @benefit.save
      render json: @benefit, status: :created
    else
      render json: @benefit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /benefits/1
  def update
    if @benefit.update(benefit_params)
      render json: @benefit
    else
      render json: @benefit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /benefits/1
  def destroy
    @benefit.destroy
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_benefit
    @benefit = @user.benefits.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def benefit_params
    params.require(:benefit).permit(
      :title,
      :value,
      :score_weightage_out_of_100
    )
  end
end
