require 'spec_helper'

describe Game do

  describe "validation" do

    it "should require a map" do
      game = FactoryGirl.build(:game, :map_id => nil)
      game.should_not be_valid
      game.should have_at_least(1).error_on(:map_id)
      game.errors[:map_id].should include("can't be blank")
    end

    it "should require a team" do
      game = FactoryGirl.build(:game, :team_id => nil)
      game.should_not be_valid
      game.should have_at_least(1).error_on(:team_id)
      game.errors[:team_id].should include("can't be blank")
    end

    it "should validate the moves are correct" do
      game = FactoryGirl.build(:game, :moves => 1)
      game.should_not be_valid
      game.should have(1).error_on(:moves)
      game.errors[:moves].should == ["INVALID_MOVE"]
    end

  end

  describe "states" do

    it "should begin in pending" do
      game = FactoryGirl.create(:game)
      game.pending?.should be_true
    end

    it "should progress from pending to in_progress" do
      game = FactoryGirl.create(:game)
      game.start!
      game.in_progress?.should be_true
    end

    it "should progress from in_progress to complete" do
      game = FactoryGirl.create(:game)
      game.start!
      game.end!
      game.completed?.should be_true
    end

    it "should mark the total moves when game is completed" do
      game = FactoryGirl.create(:game)
      game.start!
      game.play([0,0])
      game.play([3,5])
      game.end!
      game.total_moves.should == 2
    end

    it "should progress from in_progress to complete with forfeit" do
      game = FactoryGirl.create(:game)
      game.start!
      game.forfeit!
      game.completed?.should be_true
    end

    it "should progress from pending to complete with forfeit" do
      game = FactoryGirl.create(:game)
      game.forfeit!
      game.completed?.should be_true
    end

    it "should mark total moves as 100 after forfeit" do
      game = FactoryGirl.create(:game)
      game.forfeit!
      game.total_moves.should == 100
    end

    it "should show all in progress games" do
      game1 = FactoryGirl.create(:game)
      game2 = FactoryGirl.create(:game)
      game2.update_attribute(:state, 'completed')
      game3 = FactoryGirl.create(:game)
      game3.update_attribute(:state, 'in_progress')
      Game.non_complete.should == [game1, game3]
    end


  end

  describe "#play" do

    before(:each) do
      @game = FactoryGirl.create(:game)
    end

    it "should return a hit if the move hits a boat" do
      success, result = @game.play([0,0])
      success.should be_true
      result['status'].should == 'hit'
    end

    it "should return a hit_and_destroyed if the move hits a boat and destroys it"

    it "should return a miss if the move fails to hit a boat" do
      success, result = @game.play([0,1])
      success.should be_true
      result['status'].should == 'miss'
    end

    it "should return a miss if the move falls outside the board" do
      success, result = @game.play([0,11])
      success.should be_true
      result['status'].should == 'miss'
    end

  end

  describe "game ending" do

    before(:each) do
      @game = FactoryGirl.create(:game)
    end

    it "should end the game if all the ships have been sunk"

    it "should change the state to complete if moves reach 100" do
      @game.start!
      99.times do
        @game.moves << [0,0]
      end
      @game.play([0,0])
      @game.completed?.should be_true
    end

  end


end
