class UsersController < ApplicationController
  before_action :authenticate_user!
  # Добавляем :edit и :update в список экшенов, где нужен поиск юзера
  before_action :set_user, only: [:show, :edit, :update]
  # Проверяем, что текущий залогиненный юзер редактирует именно себя
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @posts = @user.posts.order(created_at: :desc)
  end

  def edit
    # Этот экшен просто откроет форму edit.html.erb
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Профиль успешно обновлен!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Защита: не даем редактировать чужие профили через URL
  def ensure_correct_user
    unless current_user == @user
      redirect_to root_path, alert: "У вас нет прав для редактирования этого профиля."
    end
  end

  # Разрешаем изменять только поле bio
  def user_params
    params.require(:user).permit(:bio, :avatar) 
  end
end