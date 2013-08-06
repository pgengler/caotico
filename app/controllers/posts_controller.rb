class PostsController < ApplicationController
  include PostsHelper

  def index
    if params[:tag]
      @posts = Post.tagged_with(params[:tag]).page(params[:page])
    else
      @posts = Post.page(params[:page])
    end

    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
    @post = Post.find(params[:id])
    @title = @post.title
  end
end
