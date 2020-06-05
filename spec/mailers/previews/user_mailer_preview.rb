# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def update_budget_plan_reminder
    UserMailer.with(user_id: User.first.to_param).update_budget_plan_reminder
  end

  def wish_for_birthday
    UserMailer.with(user_id: User.first.to_param).wish_for_birthday
  end
end
