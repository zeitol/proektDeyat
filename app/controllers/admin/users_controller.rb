class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def index
    # Загружаем всех пользователей, кроме самого админа, чтобы он случайно себя не удалил
    @users = User.where.not(id: current_user.id).order(created_at: :desc)
  end

  def destroy
    @user = User.find(params[:id])
    
    # Удаляем пользователя из базы данных
    if @user.destroy
      redirect_to admin_users_path, notice: "Пользователь @#{@user.username} и все его данные успешно удалены."
    else
      redirect_to admin_users_path, alert: "Не удалось удалить пользователя."
    end
  end

  private

  # Жесткая проверка: если юзер не админ — разворачиваем его на главную
  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Доступ запрещен! У вас нет прав администратора."
    end
  end
end