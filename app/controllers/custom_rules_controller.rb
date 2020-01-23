class CustomRulesController < ApplicationController
  before_action :set_user, :set_custom_rule, only: %i[show update]

  # GET /users/1/user_profiles
  def show
    render json: @custom_rule
  end

  # PATCH/PUT /categories/1
  def update
    if @custom_rule.update(custom_rule_params)
      render json: @custom_rule
    else
      render json: @custom_rule.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_custom_rule
    @custom_rule = @user.custom_rule
  end

  def custom_rule_params
    params.require(:custom_rule).permit(
      :emergency_corpus,
      :emergency_corpus_score_weightage_out_of_100,
      { outflow_split_percentage: {} },
      :outflow_split_score_weightage_out_of_100
    )
  end
end
