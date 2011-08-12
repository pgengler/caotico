require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    @post = posts(:sample)
		@post_with_pullquote = posts(:pullquote)
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
      post :create, :post => @post.attributes
    end

    assert_redirected_to post_path(assigns(:post))
  end

  test "should show post" do
    get :show, :id => @post.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @post.to_param
    assert_response :success
  end

  test "should update post" do
    put :update, :id => @post.to_param, :post => @post.attributes
    assert_redirected_to post_path(assigns(:post))
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @post.to_param
    end

    assert_redirected_to posts_path
  end

	test "index shows no more than 10 posts" do
		get :index

		num_posts = 10
		if Post.count < 10
			num_posts = Post.count
		end

		assert_select 'article', num_posts
	end

	test "should show date created for posts" do
		get :show, :id => @post.to_param

		assert_select 'time'
	end

	test "post titles should link to post page" do
		get :index

		assert_select "a[href=#{post_path(@post)}]"
	end

	test "should include pullquotes for posts with them" do
		get :show, :id => @post_with_pullquote.to_param

		assert_select 'aside', 1
	end

	test "should not include pullquotes for posts without them" do
		get :show, :id => @post.to_param

		assert_select 'aside', 0
	end
end
