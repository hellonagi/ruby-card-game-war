require 'minitest/autorun'
require_relative 'war'

class GameTest < MiniTest::Test
  def setup
    @game = Game.new
  end

  def test_start_game
    assert_output("戦争を開始します。\n") { @game.start_game }
  end
end
