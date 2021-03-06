require 'test_helper'

class PostsControllerTest < ActionController::TestCase
	include PostsHelper

	setup do
		# Create 15 sample posts to be able test multipage behavior
		15.times do |i|
			FactoryBot.create :post, title: "Factory #{i}", tag_list: "common, tag#{i}"
		end
		@post = Post.first
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:posts)
	end

	test "should show post" do
		get :show, params: { id: @post.to_param }
		assert_response :success
	end

	test "index shows no more than 10 posts" do
		get :index

		assert_select 'section.post', 10
	end

	test "should show date created for posts" do
		get :show, params: { id: @post.to_param }

		assert_select 'time'
	end

	test "post titles should link to post page" do
		get :index

		assert_select "a[href='#{post_path_with_slug(@post)}']"
	end

	test "list of tags are included when viewing a post with tags" do
		get :show, params: { id: @post.to_param }

		assert_select 'ul.tags' do
			assert_select 'li a', 'common'
			assert_select 'li a', 'tag14'
		end
	end

	test "no list of tags is included for posts with no tags" do
		post = FactoryBot.create :post
		get :show, params: { id: post.to_param }

		assert_select 'ul.tags', 0
	end

	test "specifying a tag shows only posts matching that tag" do
		get :index, params: { tag: 'tag1' }

		assert_select 'section.post', 1
	end
end
