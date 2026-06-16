class Users::SessionsController < Devise::SessionsController
  def new
    # Берем последние 3 поста, включая данные об авторах
    @recent_posts = Post.includes(:user).order(created_at: :desc).limit(3)
    super
  end
end