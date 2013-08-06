require 'test_helper'

class Admin::PostsControllerTest < ActionController::TestCase
  include PostsHelper

  setup do
    @post = FactoryGirl.create(:post, title: "Factory Post")
  end

  test "has a 'new' action" do
    get :new
    assert_response :success
  end

  test "creates posts via 'create' action" do
    assert_difference('Post.count') do
      post :create, post: @post.attributes
    end

    assert_redirected_to post_path_with_slug(assigns(:post))
    assert_equal 'Post was successfully created.', flash[:notice]
  end

  test "has an 'edit' action" do
    get :edit, id: @post.to_param
    assert_response :success
  end

  test "updates posts via the 'update' action" do
    put :update, id: @post.to_param, post: @post.attributes

    assert_redirected_to post_path_with_slug(assigns(:post))
    assert_equal 'Post was successfully updated.', flash[:notice]
  end

  test "destroys posts via the 'destroy' action" do
    assert_difference('Post.count', -1) do
      delete :destroy, id: @post.to_param
    end

    assert_redirected_to posts_path
  end
end
