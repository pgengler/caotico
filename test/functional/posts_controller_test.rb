require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  include PostsHelper

  setup do
    # Create 15 sample posts to be able test multipage behavior
    15.times do |i|
      FactoryGirl.create :post, title: "Factory #{i}", tag_list: "common, tag#{i}"
    end
    @post = Post.first
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post :create, post: @post.attributes
    end

    assert_redirected_to post_path_with_slug(assigns(:post))
    assert_equal 'Post was successfully created.', flash[:notice]
  end

  test "should show post" do
    get :show, id: @post.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @post.to_param
    assert_response :success
  end

  test "should update post" do
    put :update, id: @post.to_param, post: @post.attributes

    assert_redirected_to post_path_with_slug(assigns(:post))
    assert_equal 'Post was successfully updated.', flash[:notice]
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete :destroy, id: @post.to_param
    end

    assert_redirected_to posts_path
  end

	test "index shows no more than 10 posts" do
		get :index

		assert_select 'article', 10
	end

	test "should show date created for posts" do
		get :show, id: @post.to_param

		assert_select 'time'
	end

	test "post titles should link to post page" do
		get :index

		assert_select "a[href=#{post_path_with_slug(@post)}]"
	end

	test "list of tags are included when viewing a post with tags" do
		get :show, id: @post.to_param

		assert_select 'ul.tags' do
			assert_select 'li', 'common'
			assert_select 'li', 'tag14'
		end
	end

	test "no list of tags is included for posts with no tags" do
		post = FactoryGirl.create :post
		get :show, id: post.to_param

		assert_select 'ul.tags', 0
	end
end
