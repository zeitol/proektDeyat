class Follow < ApplicationRecord
  # Тот, кто подписывается, является пользователем
  belongs_to :follower, class_name: 'User'
  # Тот, на кого подписываются, тоже является пользователем
  belongs_to :followed, class_name: 'User'

  # Валидация, чтобы нельзя было подписаться на самого себя
  validate :cannot_follow_self

  private

  def cannot_follow_self
    if follower_id == followed_id
      errors.add(:base, "Вы не можете подписаться на самого себя.")
    end
  end
end