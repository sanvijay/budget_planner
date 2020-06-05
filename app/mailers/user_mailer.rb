class UserMailer < ApplicationMailer
  # month end reminder
  def update_budget_plan_reminder
    @user = User.find(params[:user_id])
    return unless @user.user_profile.month_end_reminder?

    mail(to: @user.email, subject: "It's Month End. Plan your budget")
  end

  # birthday reminder
  def wish_for_birthday
    @user = User.find(params[:user_id])
    return unless @user.user_profile.month_end_reminder?

    mail(to: @user.email, subject: "finsey. wishes you a very happy birthday!")
  end
end
