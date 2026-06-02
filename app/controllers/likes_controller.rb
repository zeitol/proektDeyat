class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    # Пытаемся создать лайк, только если его еще нет
    @post.likes.create(user: current_user)
    redirect_back fallback_location: root_path
  end

  def destroy
    # Ищем конкретный лайк текущего юзера под этим постом
    @like = @post.likes.find_by(user: current_user)
    @like.destroy if @like
    redirect_back fallback_location: root_path
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end