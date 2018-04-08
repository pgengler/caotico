require 'test_helper'

class Admin::PostsControllerTest < ActionController::TestCase
	include PostsHelper

	setup do
		@post = FactoryBot.create(:post, title: "Factory Post")
	end

	test "has an 'index' action" do
		get :index
		assert_response :success
	end

	test "'index' action shows a table with a row for each post" do
		get :index
		assert_select 'tbody > tr', Post.count
	end

	test "has a 'new' action" do
		get :new
		assert_response :success
	end

	test "creates posts via 'create' action" do
		assert_difference('Post.count') do
			post :create, params: { post: @post.attributes }
		end

		assert_redirected_to post_path_with_slug(assigns(:post))
		assert_equal 'Post was successfully created.', flash[:notice]
	end

	test "has an 'edit' action" do
		get :edit, params: { id: @post.to_param }
		assert_response :success
	end

	test "updates posts via the 'update' action" do
		put :update, params: { id: @post.to_param, post: @post.attributes }

		assert_redirected_to post_path_with_slug(assigns(:post))
		assert_equal 'Post was successfully updated.', flash[:notice]
	end

	test "destroys posts via the 'destroy' action" do
		assert_difference('Post.count', -1) do
			delete :destroy, params: { id: @post.to_param }
		end

		assert_redirected_to posts_path
	end
end
