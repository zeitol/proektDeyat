class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

def index
    @post = Post.new
    @posts = fetch_filtered_posts
    
    # Если активирована вкладка "Мои подписки", подгружаем подписки
    if params[:feed_scope] == 'following' && user_signed_in?
      @following_users = current_user.following.includes(:avatar_attachment)
    end

    # --- НОВАЯ ЛОГИКА ПОИСКА ПОЛЬЗОВАТЕЛЕЙ ---
    if params[:query].present?
      # Стираем лишние пробелы и переводим в нижний регистр для надежности
      search_query = params[:query].strip.downcase
      
      # Ищем по юзернейму частичные совпадения (защищено от SQL-инъекций)
      @search_results = User.where('LOWER(username) LIKE ?', "%#{search_query}%")
                            .includes(:avatar_attachment)
                            .limit(10) # Ограничим 10 пользователями, чтобы не перегружать страницу
    end
  end

  def show
    @post = Post.includes(comments: :user).find(params[:id])
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to root_path, notice: "Пост опубликован"
    else
      # ИСПРАВЛЕНО: Если пост не валидный, перерендерим главную с сохранением фильтров
      @posts = fetch_filtered_posts
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

  # --- НОВЫЙ МЕТОД ДЛЯ ФИЛЬТРАЦИИ, СОРТИРОВКИ И ПАГИНАЦИИ ---
  def fetch_filtered_posts
    # Стартовый ленивый запрос к БД с защитой от N+1
    posts = Post.includes(:comments, :likes, user: :avatar_attachment)

    # 1. Фильтр по области видимости (Все посты / Только подписки)
    if params[:feed_scope] == 'following' && user_signed_in?
      posts = posts.where(user_id: current_user.following_ids)
    end

    # 2. Фильтр по дате (Сначала старые / Сначала новые)
    if params[:sort] == 'old'
      posts = posts.order(created_at: :asc)
    else
      posts = posts.order(created_at: :desc) # Дефолтный вариант
    end

    # 3. Накладываем пагинацию на отфильтрованный результат
    posts.page(params[:page]).per(10)
  end

  def set_post
    # Твой стандартный поиск поста для edit/update/destroy
    @post = Post.find(params[:id])
  end

  def ensure_correct_user
    unless @post.user == current_user || current_user&.admin?
      redirect_to root_path, alert: "Вы не являетесь автором этого поста!"
    end
  end

  def post_params
    params.require(:post).permit(:content)
  end
end