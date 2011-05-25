require 'test_helper'

class PostTest < ActiveSupport::TestCase

	test "requires a title" do
		assert_raises ActiveRecord::RecordInvalid do
			Post.create! :content => 'Lorem ipsum sin dolor amit'
		end
	end

	test "requires some content" do
		assert_raises ActiveRecord::RecordInvalid do
			Post.create! :title => 'Some title'
		end
	end

end
