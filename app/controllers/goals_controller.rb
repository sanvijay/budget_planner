class GoalsController < ApplicationController
  before_action :set_user
  before_action :set_goal, only: %i[show update destroy]

  # GET /goals
  def index
    @goals = @user.goals.map do |g|
      g[:planned] = g.planned_cash_flow
      g[:actual] = g.actual_cash_flow
      g
    end

    render json: @goals
  end

  # GET /goals/1
  def show
    render json: @goal
  end

  # POST /goals
  def create
    @goal = @user.goals.build(goal_params)

    if @goal.save
      @goal[:planned] = @goal.planned_cash_flow
      render json: @goal, status: :created
    else
      render json: @goal.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /goals/1
  def update
    if @goal.update(goal_params)
      render json: @goal
    else
      render json: @goal.errors, status: :unprocessable_entity
    end
  end

  # DELETE /goals/1
  def destroy
    @goal.destroy
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_goal
    @goal = @user.goals.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def goal_params
    params.require(:goal).permit(
      :description,
      :target,
      :start_date,
      :end_date,
      :score_weightage_out_of_100
    )
  end
end
