namespace :one_time do
  desc "Backfill account field in all place"
  task backfill_account: :environment do
    User.all.each do |user|
      next unless user.enabled?

      puts "Working on #{user.user_profile.first_name} ..."
      account = user.accounts.last || user.accounts.create(name: "Default")

      user.monthly_budgets.each do |mb|
        unless mb.prev_month_bal_actual.zero?
          mb.prev_month_bal_actuals = {
            account.to_param => mb.prev_month_bal_actual
          }
        end

        mb.actual_cash_flow_logs.each do |acfl|
          acfl.account_id = account.id
          acfl.save!
        end

        mb.save!
      end
    end
  end
end
