class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def index
    @post = Post.new
    @posts = Post.includes(:comments, :likes, user: :avatar_attachment).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @post = Post.includes(comments: :user).find(params[:id])
  end

  def create
    @post = current_user.posts.build(post_params)
    @posts = Post.includes(:comments, :likes, user: :avatar_attachment).order(created_at: :desc).page(params[:page]).per(10)

    if @post.save
      redirect_to root_path, notice: "Пост опубликован"
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to root_path, notice: "Пост успешно обновлен"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to root_path, notice: "Пост удален", status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def ensure_correct_user
    unless @post.user == current_user
      redirect_to root_path, alert: "Вы не являетесь автором этого поста!"
    end
  end

  def post_params
    params.require(:post).permit(:content)
  end
end