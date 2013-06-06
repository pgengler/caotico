require 'test_helper'

class PostTest < ActiveSupport::TestCase

	setup do
		FactoryGirl.create :post, created_at: 1.week.ago
		@newest = FactoryGirl.create(:post, created_at: 1.day.ago)
		FactoryGirl.create :post, created_at: 10.years.ago
	end

	test "requires a title" do
		assert_raises ActiveRecord::RecordInvalid do
			Post.create! content: 'Lorem ipsum sin dolor amit'
		end
	end

	test "requires some content" do
		assert_raises ActiveRecord::RecordInvalid do
			Post.create! title: 'Some title'
		end
	end

	test "orders posts with newest ones first" do
		assert_equal @newest, Post.first
	end

end
