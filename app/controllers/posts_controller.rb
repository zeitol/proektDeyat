class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @post = Post.new
    @posts = Post.includes(:user).order(created_at: :desc)
  end

  def create
    @post = current_user.posts.build(post_params)
    @posts = Post.includes(:user).order(created_at: :desc)

    if @post.save
      redirect_to root_path, notice: "Пост опубликован"
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end