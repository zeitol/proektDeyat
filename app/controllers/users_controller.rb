class UsersController < ApplicationController
  before_action :authenticate_user!
  # Добавляем :edit и :update в список экшенов, где нужен поиск юзера
  before_action :set_user, only: [:show, :edit, :update]
  # Проверяем, что текущий залогиненный юзер редактирует именно себя
  before_action :ensure_correct_user, only: [:edit, :update]

  def show
    @posts = @user.posts
                  .includes(:comments, :likes, user: :avatar_attachment)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(10)
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

  def follow
    @user = User.find(params[:id])
    current_user.follow(@user)
    redirect_to user_path(@user), notice: "Вы подписались на @#{@user.username}"
  end

  def unfollow
    @user = User.find(params[:id])
    current_user.unfollow(@user)
    redirect_to user_path(@user), notice: "Вы отписались от @#{@user.username}"
  end

  private

def set_user
    # find_by не вызывает ошибку, а возвращает nil, если пользователь не найден
    @user = User.find_by(id: params[:id])
    
    # Если @user равен nil (пользователь удален), перенаправляем на главную
    if @user.nil?
      redirect_to root_path, alert: "Запрашиваемый пользователь не найден или его аккаунт был удален."
    end
  end

  def ensure_correct_user
    unless current_user == @user
      redirect_to root_path, alert: "У вас нет прав для редактирования этого профиля."
    end
  end

  def user_params
    params.require(:user).permit(:bio, :avatar) 
  end
end