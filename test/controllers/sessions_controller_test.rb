require "test_helper"

describe SessionsController do
  describe "login" do
    # This functionality is complex!
    # There are definitely interesting cases I haven't covered
    # here, but these are the cases I could think of that are
    # likely to occur. More test cases will be added as bugs
    # are uncovered.
    #
    # Note also: some more behavior is covered in the upvote tests
    # under the works controller, since that's the only place
    # where there's an interesting difference between a logged-in
    # and not-logged-in user.
    it "succeeds for a new user" do
      user = User.new(provider: "github", uid: 9999, username: "bob", email: "bob@gmail.com")

      proc {login(user, :github)}.must_change 'User.count', +1

      must_redirect_to root_path
      session[:user_id].must_equal User.find_by(username: "bob").id
    end

    it "succeeds for a returning user" do
      user = users(:dan)
      proc {login(user, :github)}.must_change 'User.count', 0

      must_redirect_to root_path
      session[:user_id].must_equal User.find_by(username: "dan").id
    end

    it "succeeds if a different user is already logged in" do
      user1 = users(:dan)
      user2 = users(:kari)

      login(user1, :github)
      must_redirect_to root_path

      login(user2, :github)
      must_redirect_to root_path

      session[:user_id].must_equal User.find_by(username: "kari").id
    end
  end

  describe "logout" do
    it "succeeds if the user is logged in" do
      # Gotta be logged in first
      user = users(:dan)
      login(user, :github)
      must_redirect_to root_path

      post logout_path
      must_redirect_to root_path
      session[:user_id].must_equal nil
    end

    it "succeeds if the user is not logged in" do
      post logout_path
      must_redirect_to root_path
    end
  end
end
