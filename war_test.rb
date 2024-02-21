require 'minitest/autorun'
require 'minitest/mock'
require_relative 'war'

# GameTestでは出力結果に一貫性を持たせるためにデッキのシャッフルはしない
# Deck.newの第二引数をfalseと指定することでシャッフルを無効
class GameTest < MiniTest::Test
  # テスト用デッキとキャプチャーのセットアップ
  def custom_setup(deck)
    game = Game.new(deck)
    output, _stderr = capture_io do
      game.start_game
    end
    output
  end

  # 初期状態ののしデッキ
  # 26回の引き分けで終了
  # デッキの並び順: [2, 3, ..., J, Q, K, A]*4
  def test_start_game_with_test_deck_1
    test_deck = Deck.new(nil, false)
    output = custom_setup(test_deck)

    assert_match(/プレイヤー1の手札がなくなりました。/, output)
    assert_match(/プレイヤー2の手札がなくなりました。/, output)
    assert_match(/プレイヤー1の手札の枚数は0枚です。プレイヤー2の手札の枚数は0枚です。/, output)
    assert_match(/プレイヤー1が1位、プレイヤー2が1位です。/, output)
  end

  # プレイヤー1が勝利
  # デッキの並び順: [3, 8]
  def test_start_game_with_test_deck_2
    test_deck = Deck.new([Card.new(:ダイヤ, 3), Card.new(:ダイヤ, 8)], false)
    output = custom_setup(test_deck)

    assert_match(/プレイヤー2の手札がなくなりました。/, output)
    assert_match(/プレイヤー1の手札の枚数は2枚です。プレイヤー2の手札の枚数は0枚です。/, output)
    assert_match(/プレイヤー1が1位、プレイヤー2が2位です。/, output)
  end

  # プレイヤー2が勝利
  # デッキの並び順: [A, J]
  def test_start_game_with_mini_deck_3
    test_deck = Deck.new([Card.new(:ダイヤ, :A), Card.new(:ダイヤ, :J)], false)
    output = custom_setup(test_deck)

    assert_match(/プレイヤー1の手札がなくなりました。/, output)
    assert_match(/プレイヤー1の手札の枚数は0枚です。プレイヤー2の手札の枚数は2枚です。/, output)
    assert_match(/プレイヤー2が1位、プレイヤー1が2位です。/, output)
  end

  # 引き分けしてからプレイヤー1が勝利
  # デッキの並び順: [Q, 7, Q, 10]
  def test_start_game_with_mini_deck_4
    test_deck = Deck.new([Card.new(:スペード, :Q), Card.new(:ダイヤ, 7), Card.new(:クラブ, :Q), Card.new(:ハート, 10)], false)
    output = custom_setup(test_deck)

    assert_match(/プレイヤー2の手札がなくなりました。/, output)
    assert_match(/プレイヤー1の手札の枚数は4枚です。プレイヤー2の手札の枚数は0枚です。/, output)
    assert_match(/プレイヤー1が1位、プレイヤー2が2位です。/, output)
  end
end

class DeckTest < MiniTest::Test
  def setup
    @deck = Deck.new
  end

  # デッキのカード枚数は52
  def test_deck_has_52_cards
    assert_equal 52, @deck.cards.size
  end
end

class CardTest < MiniTest::Test
  # J, Q, K, Aがそれぞれ11, 12, 13, 99という値を持っている
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
