namespace :reminder do
  desc "Send reminder on updating budget planning sheet"
  task update_budget_plan: :environment do
    User.all.each do |u|
      next unless u.user_profile.month_end_reminder?

      UserMailer.with(user_id: u.to_param)
                .update_budget_plan_reminder
                .deliver_later
    end
  end
end
