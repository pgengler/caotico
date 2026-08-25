require 'test_helper'

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
	include PostsHelper

	setup do
		@post = FactoryBot.create(:post, title: "Factory Post")
	end

	test "has an 'index' action" do
		get admin_posts_path
		assert_response :success
	end

	test "'index' action shows a table with a row for each post" do
		get admin_posts_path
		assert_select 'tbody > tr', Post.count
	end

	test "has a 'new' action" do
		get new_admin_post_path
		assert_response :success
	end

	test "creates posts via 'create' action" do
		assert_difference('Post.count') do
			post admin_posts_path, params: { post: { title: 'Created post', content: 'Some content' } }
		end

		created_post = Post.order(created_at: :desc).first
		assert_redirected_to post_path_with_slug(created_post)
		assert_equal 'Post was successfully created.', flash[:notice]
	end

	test "has an 'edit' action" do
		get edit_admin_post_path(@post)
		assert_response :success
	end

	test "updates posts via the 'update' action" do
		patch admin_post_path(@post), params: { post: { title: 'Updated title', content: 'Updated content' } }

		@post.reload
		assert_redirected_to post_path_with_slug(@post)
		assert_equal 'Post was successfully updated.', flash[:notice]
	end

	test "destroys posts via the 'destroy' action" do
		assert_difference('Post.count', -1) do
			delete admin_post_path(@post)
		end

		assert_redirected_to posts_path
	end
end
