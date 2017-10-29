require 'test_helper'

describe UsersController do
  describe "not logged in" do
    it "won't go to index" do
      get users_path
      must_redirect_to root_path
      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to do that"
    end
    it "won't go to show path" do
      get user_path(users(:dan))
      must_redirect_to root_path
      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to do that"
    end
  end
  
  describe "index" do
    before do
      @user = User.new(provider: "github", uid: 9999, username: "bob", email: "bob@gmail.com")
    end
    it "won't succeed if a user is not signed in" do
      get users_path
      must_respond_with :redirect
      must_redirect_to root_path
      flash[:status].must_equal :failure
    end

    it "succeeds with many users" do
      # Assumption: there are many users in the DB
      login(@user, :github)

      User.count.must_be :>, 0

      get users_path
      must_respond_with :success
    end

    it "succeeds with no users" do
      login(@user, :github)
      # Start with a clean slate
      Vote.destroy_all # for fk constraint
      User.destroy_all

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    before do
      @user = User.new(provider: "github", uid: 9999, username: "bob", email: "bob@gmail.com")
    end

    it "does not succeed for a user who is not signed in" do
      get user_path(User.first)
      must_respond_with :redirect
      must_redirect_to root_path
      flash[:status].must_equal :failure
    end

    it "succeeds for a signed in user" do
      login(@user, :github)
      get user_path(User.find_by(username: "bob"))
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user" do
      # User.last gives the user with the highest ID
      login(@user, :github)
      bogus_user_id = User.last.id + 1
      get user_path(bogus_user_id)
      must_respond_with :not_found
    end
  end
end
