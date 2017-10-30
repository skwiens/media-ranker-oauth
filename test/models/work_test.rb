require 'test_helper'

describe Work do
  describe "relations" do

    it "has a list of votes" do
       thrill = works(:thrill)
       thrill.must_respond_to :votes
       thrill.votes.each do |vote|
         vote.must_be_kind_of Vote
       end
    end

    it "has a list of voting users" do
      thrill = works(:thrill)
      thrill.must_respond_to :ranking_users
      thrill.ranking_users.each do |user|
        user.must_be_kind_of User
      end
    end
  end

  describe "validations" do
    it "allows the three valid categories" do

      valid_categories = ['album', 'book', 'movie']
      valid_categories.each do |category|
        work = Work.new(title: "test", category: category)
        work.user = users(:dan)
        work.valid?.must_equal true
      end
    end

    it "fixes almost-valid categories" do
      categories = ['Album', 'albums', 'ALBUMS', 'books', 'mOvIeS']
      categories.each do |category|
        work = Work.new(title: "test", category: category, user: users(:dan))
        work.valid?.must_equal true
        work.category.must_equal category.singularize.downcase
      end
    end

    it "rejects invalid categories" do
      invalid_categories = ['cat', 'dog', 'phd thesis', 1337, nil]
      invalid_categories.each do |category|
        work = Work.new(title: "test", category: category, user: users(:dan))
        work.valid?.must_equal false
        work.errors.messages.must_include :category
      end
    end

    it "requires a title" do
      work = Work.new(category: 'ablum', user: users(:dan))
      work.valid?.must_equal false
      work.errors.messages.must_include :title
    end

    it "requires unique names w/in categories" do
      category = 'album'
      title = 'test title'
      work1 = Work.new(title: title, category: category, user: users(:dan))
      work1.save!

      work2 = Work.new(title: title, category: category, user: users(:dan))
      work2.valid?.must_equal false
      work2.errors.messages.must_include :title
    end

    it "does not require a unique name if the category is different" do
      title = 'test title'
      work1 = Work.new(title: title, category: 'album', user: users(:dan))
      work1.save!

      work2 = Work.new(title: title, category: 'book', user: users(:dan))
      work2.valid?.must_equal true
    end
  end

  describe "vote_count" do

    it "defaults to 0" do
      work = Work.create!(title: "test title", category: "movie", user: users(:dan))
      work.must_respond_to :vote_count
      work.vote_count.must_equal 0
    end

    it "tracks the number of votes" do
      work = Work.create!(title: "test title", category: "movie", user: users(:dan))
      4.times do |i|
        user = User.create!(username: "user#{i}", uid: rand(9999), provider: "github")
        Vote.create!(user: user, work: work)
      end
      work.vote_count.must_equal 4
      Work.find(work.id).vote_count.must_equal 4
    end
  end

  describe "top_ten" do

    before do
      # TODO DPR: This runs pretty slow. Fixtures?
      # Create users to do the voting
      test_users = []
      20.times do |i|
        test_users << User.create!(username: "user#{i}", uid: rand(9999), provider: "github")
      end

      # Create media to vote upon
      Work.where(category: "movie").destroy_all
      8.times do |i|
        work = Work.create!(category: "movie", title: "test movie #{i}", user: User.find_by(username: "user#{i}"))
        vote_count = rand(test_users.length)
        test_users.first(vote_count).each do |user|
          Vote.create!(work: work, user: user)
        end
      end
    end

    it "returns a list of media of the correct category" do
      movies = Work.top_ten("movie")
      movies.length.must_equal 8
      movies.each do |movie|
        movie.must_be_kind_of Work
        movie.category.must_equal "movie"
      end
    end

    it "orders media by vote count" do
      movies = Work.top_ten("movie")
      previous_vote_count = 100
      movies.each do |movie|
        movie.vote_count.must_be :<=, previous_vote_count
        previous_vote_count = movie.vote_count
      end
    end

    it "returns at most 10 items" do
      movies = Work.top_ten("movie")
      movies.length.must_equal 8
      user = User.create(username: "toocool", uid: rand(9999), provider: :github)

      Work.create(title: "phase 2 test movie 1", category: "movie", user: user)
      Work.top_ten("movie").length.must_equal 9

      Work.create(title: "phase 2 test movie 2", category: "movie", user: user)
      Work.top_ten("movie").length.must_equal 10

      Work.create(title: "phase 2 test movie 3", category: "movie", user: user)
      Work.top_ten("movie").length.must_equal 10
    end
  end
end
