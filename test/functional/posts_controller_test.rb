require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    @post = posts(:sample)
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

    assert_redirected_to post_path(assigns(:post))
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

    assert_redirected_to post_path(assigns(:post))
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

		assert_select "a[href=#{post_path(@post)}]"
	end
end
