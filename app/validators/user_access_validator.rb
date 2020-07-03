class UserAccessValidator < ActiveModel::Validator
  def validate(record)
    return unless (user = record.user)

    class_string = record.class.to_s.underscore.pluralize.to_sym
    count = user.public_send(class_string).count
    return if user.user_model[class_string] > count

    record.errors[:base] << "#{class_string} count exceeded"
  end
end
