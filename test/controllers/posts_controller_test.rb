require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
	include PostsHelper

	setup do
		# Create 15 sample posts to be able test multipage behavior
		15.times do |i|
			FactoryBot.create :post, title: "Factory #{i}", tag_list: "common, tag#{i}"
		end
		@post = Post.first
	end

	test "should get index" do
		get posts_path
		assert_response :success
	end

	test "should show post" do
		get post_path(@post)
		assert_response :success
	end

	test "index shows no more than 10 posts" do
		get posts_path

		assert_select 'section.post', 10
	end

	test "should show date created for posts" do
		get post_path(@post)

		assert_select 'time'
	end

	test "post titles should link to post page" do
		get posts_path

		assert_select "a[href='#{post_path_with_slug(@post)}']"
	end

	test "list of tags are included when viewing a post with tags" do
		get post_path(@post)

		assert_select 'ul.tags' do
			assert_select 'li a', 'common'
			assert_select 'li a', 'tag14'
		end
	end

	test "no list of tags is included for posts with no tags" do
		post = FactoryBot.create :post
		get post_path(post)

		assert_select 'ul.tags', 0
	end

	test "specifying a tag shows only posts matching that tag" do
		get tag_path('tag1')

		assert_select 'section.post', 1
	end
end
