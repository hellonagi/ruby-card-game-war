require 'minitest/autorun'
require 'minitest/mock'
require_relative 'war'

# GameTestでは出力結果に一貫性を持たせるためにデッキのシャッフルはしない
# Deck.newの第二引数をfalseと指定することでシャッフルを無効
class GameTest < MiniTest::Test
  # テスト用デッキとキャプチャーのセットアップ
  def custom_setup(deck, input)
    $stdin = StringIO.new(input)
    game = Game.new(deck)
    output, _stderr = capture_io do
      game.start_game
    end
    output
  end

  # デッキの並び順: [JOKER] + [2, 3, ..., J, Q, K, A]*4
  # プレイヤー数: 2
  # 名前: たろう, はなこ
  # 26回引き分けして終了
  def test_start_game_with_2_players_without_shuffle
    test_deck = Deck.new(nil, false)
    output = custom_setup(test_deck, "2\nたろう\nはなこ\n")

    assert_match(/たろうの手札がなくなりました。/, output)
    assert_match(/はなこの手札がなくなりました。/, output)
    assert_match(/たろうの手札の枚数は0枚です。はなこの手札の枚数は0枚です。/, output)
    assert_match(/たろうが1位、はなこが1位です。/, output)
    $stdin = STDIN
  end

  # デッキの並び順: [JOKER] + [2, 3, ..., J, Q, K, A]*4
  # プレイヤー数: 4
  # 名前: たろう, じろう, さぶろう, しろう
  # 13回引き分けして終了
  def test_start_game_with_4_players_without_shuffle
    test_deck = Deck.new(nil, false)
    output = custom_setup(test_deck, "4\nたろう\nじろう\nさぶろう\nしろう\n")

    assert_match(/たろうの手札がなくなりました。/, output)
    assert_match(/じろうの手札がなくなりました。/, output)
    assert_match(/さぶろうの手札がなくなりました。/, output)
    assert_match(/しろうの手札がなくなりました。/, output)
    assert_match(/たろうの手札の枚数は0枚です。じろうの手札の枚数は0枚です。さぶろうの手札の枚数は0枚です。しろうの手札の枚数は0枚です。/, output)
    assert_match(/たろうが1位、じろうが1位、さぶろうが1位、しろうが1位です。/, output)
    $stdin = STDIN
  end

  # デッキの並び順: [3, 8]
  # プレイヤー数: 2
  # 名前: John, Bob
  def test_start_game_with_2_players
    test_deck = Deck.new([Card.new(:ダイヤ, 3), Card.new(:ダイヤ, 8)], false)
    output = custom_setup(test_deck, "2\nJohn\nBob\n")

    assert_match(/Bobの手札がなくなりました。/, output)
    assert_match(/Johnの手札の枚数は2枚です。Bobの手札の枚数は0枚です。/, output)
    assert_match(/Johnが1位、Bobが2位です。/, output)
  end

  # デッキの並び順: [A, 4, J]
  # プレイヤー数: 3
  # 名前: John, Bob, Mike
  def test_start_game_with_3_players
    test_deck = Deck.new([Card.new(:ハート, :A), Card.new(:ダイヤ, 4), Card.new(:クラブ, :J)], false)
    output = custom_setup(test_deck, "3\nJohn\nBob\nMike\n")

    assert_match(/Johnの手札がなくなりました。/, output)
    assert_match(/Bobの手札がなくなりました。/, output)
    assert_match(/Johnの手札の枚数は0枚です。Bobの手札の枚数は0枚です。Mikeの手札の枚数は3枚です。/, output)
    assert_match(/Mikeが1位、Johnが2位、Bobが2位です。/, output)
  end

  # デッキの並び順: [A, 4, J, 10, A, 2, K, 8]
  # プレイヤー数: 4
  # 名前: John, Bob, Mike, Mary
  def test_start_game_with_4_players
    test_deck = Deck.new([Card.new(:ハート, :A), Card.new(:ダイヤ, 4),
                          Card.new(:クラブ, :J), Card.new(:ハート, 10),
                          Card.new(:ダイヤ, :A), Card.new(:クラブ, 2),
                          Card.new(:ダイヤ, :K), Card.new(:クラブ, 8)], false)
    output = custom_setup(test_deck, "4\nJohn\nBob\nMike\nMary\n")

    assert_match(/Mikeが勝ちました。Mikeはカードを8枚もらいました。/, output)
    assert_match(/Johnの手札がなくなりました。/, output)
    assert_match(/Bobの手札がなくなりました。/, output)
    assert_match(/Maryの手札がなくなりました。/, output)
    assert_match(/Johnの手札の枚数は0枚です。Bobの手札の枚数は0枚です。Mikeの手札の枚数は8枚です。Maryの手札の枚数は0枚です。/, output)
    assert_match(/Mikeが1位、Johnが2位、Bobが2位、Maryが2位です。/, output)
  end

  # デッキの並び順: [A, 4, J, 10, A, 2, K, 8]
  # プレイヤー数: 5
  # 名前: John, Bob, Mike, Mary, Emma
  def test_start_game_with_5_players
    test_deck = Deck.new([Card.new(:ハート, 10), Card.new(:ダイヤ, 4),
                          Card.new(:クラブ, :J), Card.new(:ハート, :Q),
                          Card.new(:ダイヤ, 2), Card.new(:クラブ, 3),
                          Card.new(:ダイヤ, :K), Card.new(:クラブ, 8),
                          Card.new(:ダイヤ, 6), Card.new(:クラブ, 9)], false)
    output = custom_setup(test_deck, "5\nJohn\nBob\nMike\nMary\nEmma\n")

    assert_match(/Johnの手札がなくなりました。/, output)
    assert_match(/Mikeの手札がなくなりました。/, output)
    assert_match(/Emmaの手札がなくなりました。/, output)
    assert_match(/Johnの手札の枚数は0枚です。Bobの手札の枚数は5枚です。Mikeの手札の枚数は0枚です。Maryの手札の枚数は5枚です。Emmaの手札の枚数は0枚です。/, output)
    assert_match(/Bobが1位、Maryが1位、Johnが3位、Mikeが3位、Emmaが3位です。/, output)
  end

  # デッキの並び順: [A, JOKER]
  # プレイヤー数: 2
  # 名前: John, Bob
  def test_joker
    test_deck = Deck.new([Card.new(:ハート, :A), Card.new(:ジョーカー, :JOKER)], false)
    output = custom_setup(test_deck, "2\nJohn\nBob\n")

    assert_match(/JohnのカードはジョーカーのJOKERです。/, output)
    assert_match(/BobのカードはハートのAです。/, output)
    assert_match(/Johnが勝ちました。Johnはカードを2枚もらいました。/, output)
    assert_match(/Bobの手札がなくなりました。/, output)
    assert_match(/Johnの手札の枚数は2枚です。Bobの手札の枚数は0枚です。/, output)
    assert_match(/Johnが1位、Bobが2位です。/, output)
  end
end

class DeckTest < MiniTest::Test
  def setup
    @deck = Deck.new
  end

  # デッキのカード枚数は53
  def test_deck_has_53_cards
    assert_equal 53, @deck.cards.size
  end
end

class CardTest < MiniTest::Test
  # J, Q, K, A, JOKERがそれぞれ11, 12, 13, 99, 999という値を持っている
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
    card_a = Card.new(:ジョーカー, :JOKER)
    assert_equal 999, card_a.value
  end
end
