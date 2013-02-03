class PostsController < ApplicationController
  before_filter :find_post, :only => [ :destroy, :edit, :show, :update ]

  def index
    @posts = Post.page params[:page]
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])

    if @post.save
      redirect_to @post, :notice => 'Post was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    if @post.update_attributes(params[:post])
      redirect_to @post, :notice => 'Post was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @post.destroy

    redirect_to posts_url
  end

  private

    def find_post
      @post = Post.find(params[:id])
    end
end
