require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest
	include PostsHelper

	test "edit post" do
		@post = FactoryGirl.create(:post)
		get edit_post_path(@post)
		assert_response :success

		put_via_redirect post_path(@post), post: { title: 'This is a test title', content: 'Hey this is some content' }
		assert_equal post_path_with_slug(assigns(:post)), path
		assert_select "a[href=#{post_path_with_slug(assigns(:post))}]", 'This is a test title'
	end
end
