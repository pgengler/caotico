class Admin::PostsController < ApplicationController
	include PostsHelper
	helper PostsHelper
	before_filter :find_post, only: [ :edit, :update, :destroy ]

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
			render action: "new"
		end
	end

	def edit
		@title = "Edit post #{@post.title}"
	end

	def update
		if @post.update_attributes(post_params)
			redirect_to post_path_with_slug(@post), notice: 'Post was successfully updated.'
		else
			render action: "edit"
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

		def post_params
			params.require(:post).permit(:title, :content, :tag_list)
		end

end
