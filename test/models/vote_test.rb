require 'test_helper'

describe Vote do
  describe "relations" do
    it "has a user" do
      v = votes(:one)
      v.must_respond_to :user
      v.user.must_be_kind_of User
    end

    it "has a work" do
      v = votes(:one)
      v.must_respond_to :work
      v.work.must_be_kind_of Work
    end
  end

  describe "validations" do
    let (:user1) { User.create(username: 'chris', uid: rand(9999), provider: "github") }
    let (:user2) { User.create(username: 'dee', uid: rand(9999), provider: "github") }
    let (:work1) { Work.create(category: 'book', title: 'House of Leaves') }
    let (:work2) { Work.create(category: 'book', title: 'For Whom the Bell Tolls') }

    it "allows one user to vote for multiple works" do
      user = User.create(username: 'chris', uid: rand(9999), provider: "github")

      work1 = Work.create(category: 'book', title: 'House of Leaves')
      work2 = Work.create(category: 'book', title: 'For Whom the Bell Tolls')

      vote1 = Vote.new(user: user1, work: work1)
      vote1.save
      puts "#{vote1.work.id}"

      vote2 = Vote.new(user: user1, work: work2)
      puts "#{vote2.work.id}"
      # vote2.save
      vote2.valid?.must_equal true
    end

    it "allows multiple users to vote for a work" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user2, work: work1)
      vote2.valid?.must_equal true
    end

    it "doesn't allow the same user to vote for the same work twice" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user1, work: work1)
      vote2.valid?.must_equal false
      vote2.errors.messages.must_include :user
    end
  end
end
