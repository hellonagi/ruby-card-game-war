require 'minitest/autorun'
require_relative 'war'

class GameTest < MiniTest::Test
  def setup
    @game = Game.new
  end

  def test_start_game
    assert_output("戦争を開始します。\nカードが配られました。\n") { @game.start_game }

    # プレイヤー数は2人か
    assert_equal 2, @game.players.size

    # プレイヤーの手札数はそれぞれ26枚か
    @game.players.each do |player|
      assert_equal 26, player.hand.size
    end
  end
end

class DeckTest < MiniTest::Test
  def setup
    @deck = Deck.new
  end

  # デッキのカード枚数は52か
  def test_deck_has_52_cards
    assert_equal 52, @deck.cards.size
  end
end

class CardTest < MiniTest::Test
  # J,Q,K,Aがそれぞれ11, 12, 13, 99という値を持っているか
  def test_card_rank_has_expected_value
    card_2 = Card.new(:ダイヤ, 2)
    assert_equal 2, card_2.value
    card_j = Card.new(:ダイヤ, :J)
    assert_equal 11, card_j.value
    card_q = Card.new(:ダイヤ, :Q)
    assert_equal 12, card_q.value
    card_k = Card.new(:ダイヤ, :K)
    assert_equal 13, card_k.value
    card_a = Card.new(:ダイヤ, :A)
    assert_equal 99, card_a.value
  end
end
