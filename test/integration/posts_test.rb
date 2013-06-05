require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest
	fixtures :all

	test "edit post" do
		@post = posts(:sample)
		get edit_post_path(@post)
		assert_response :success

		put_via_redirect post_path(@post), post: { title: 'This is a test title', content: 'Hey this is some content' }
		assert_equal post_path(@post), path
		assert_select "a[href=#{post_path(@post)}/this-is-a-test-title]", 'This is a test title'
	end
end
