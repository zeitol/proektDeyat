class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: "Комментарий добавлен!"
    else
      redirect_to post_path(@post), alert: "Не удалось отправить комментарий."
    end
  end

  def destroy
    if @comment.user == current_user || @post.user == current_user || current_user.admin?
      @comment.destroy
      redirect_to post_path(@post), notice: "Комментарий удален.", status: :see_other
    else
      redirect_to post_path(@post), alert: "У вас нет прав."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end