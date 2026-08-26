class Admin::PostsController < ApplicationController
	include PostsHelper
	helper PostsHelper
	before_action :find_post, only: [ :edit, :update, :destroy ]

	def index
		@posts = Post.all
	end

	def new
		@post = Post.new
		@title = 'New post'
	end

	def create
		@post = Post.new(post_params)

		if @post.save
			redirect_to post_path_with_slug(@post), notice: 'Post was successfully created.'
		else
			render :new, status: :unprocessable_entity
		end
	end

	def edit
		@title = "Edit post #{@post.title}"
	end

	def update
		if @post.update(post_params)
			redirect_to post_path_with_slug(@post), notice: 'Post was successfully updated.'
		else
			render :edit, status: :unprocessable_entity
		end
	end

	def destroy
		@post.destroy

		redirect_to posts_url, status: :see_other
	end

	private

		def find_post
			@post = Post.find(params[:id])
		end

		def post_params
			params.require(:post).permit(:title, :content, :tag_list)
		end

end
