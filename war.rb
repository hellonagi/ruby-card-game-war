class Game
  attr_reader :players

  def initialize(deck)
    @players = []
    @deck = deck
  end

  def start_game(player_count: 2)
    @player_count = player_count
    # プレイヤー数だけPlayerインスタンスを作成
    make_players

    # 開始メッセージ
    puts '戦争を開始します。'

    # カードを配る
    @deck.deal_cards(@players)

    # ゲームの主要機能
    battle

    # 終了メッセージ
    puts '戦争を終了します。'
  end

  def make_players
    @player_count.times do |i|
      @players << Player.new(i + 1)
    end
  end

  def battle
    stacked_cards = []

    winner = nil
    until winner
      puts '戦争！'
      battle_cards = draw_battle_cards(stacked_cards)
      winner = decide_winner(battle_cards)
      break if empty_hand_exists
    end

    add_stacked_cards_to_winner(winner, stacked_cards)
    announce_winner(winner)
  end

  def draw_battle_cards(stacked_cards)
    battle_cards = []
    @players.each do |player|
      draw_card = player.hand.pop
      puts "#{player.name}のカードは#{draw_card.suit}の#{draw_card.rank}です。"
      stacked_cards << draw_card
      battle_cards << draw_card
    end
    battle_cards
  end

  def empty_hand_exists
    empty_exists = false
    @players.each do |player|
      if player.hand.empty?
        puts "#{player.name}の手札がなくなりました。"
        empty_exists = true
      end
    end
    empty_exists
  end

  def decide_winner(battle_cards)
    highest_card, highest_player_index = battle_cards.each_with_index.max_by { |element, _| element.value }
    if battle_cards.count { |card| card.value == highest_card.value } >= 2
      puts '引き分けです。'
      return
    end
    players[highest_player_index]
  end

  def add_stacked_cards_to_winner(winner, stacked_cards)
    winner.taken_cards += stacked_cards unless winner.nil?
  end

  def announce_winner(winner)
    if winner
      puts "#{winner.name}が勝ちました。"
    else
      puts '無効試合です。'
    end
  end
end

class Player
  attr_reader :name, :hand
  attr_accessor :taken_cards

  def initialize(num)
    @name = "プレイヤー#{num}"
    @hand = []
    @taken_cards = []
  end
end

class Deck
  attr_reader :cards

  SUITS = [:クラブ, :ダイヤ, :ハート, :スペード]
  RANKS = (2..10).to_a + [:J, :Q, :K, :A]

  def initialize(cards = nil, do_shuffle = true)
    @cards = cards || build_deck
    shuffle_cards if do_shuffle
  end

  def build_deck
    deck = []
    SUITS.each do |suit|
      RANKS.each do |rank|
        deck << Card.new(suit, rank)
      end
    end
    deck
  end

  def shuffle_cards
    @cards = @cards.shuffle
  end

  def deal_cards(players)
    num_card = @cards.size / players.size

    players.each do |player|
      num_card.times do
        player.hand << @cards.pop
      end
    end

    puts 'カードが配られました。'
  end
end

class Card
  attr_reader :suit, :rank, :value

  # カードの絵札を強さとして数値に変換するためのハッシュ
  CARD_HASH = { A: 99, J: 11, Q: 12, K: 13 }

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
    @value = CARD_HASH[rank] || rank
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(Deck.new)
  game.start_game
end
