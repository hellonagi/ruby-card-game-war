class Game
  attr_reader :players

  def initialize
    @players = []
    @deck = Deck.new
  end

  def start_game(player_count: 2)
    @player_count = player_count
    # プレイヤー数だけPlayerインスタンスを作成
    make_players

    # 開始メッセージ
    puts '戦争を開始します。'

    # カードを配る
    @deck.deal_cards(@players)
  end

  def make_players
    @player_count.times do |i|
      @players << Player.new(i + 1)
    end
  end
end

class Player
  attr_reader :hand

  def initialize(num)
    @name = "プレイヤー#{num}"
    @hand = []
  end
end

class Deck
  attr_reader :cards

  SUITS = [:クラブ, :ダイヤ, :ハート, :スペード]
  RANKS = (2..10).to_a + [:A, :J, :Q, :K]

  def initialize
    @cards = []
    SUITS.each do |suit|
      RANKS.each do |rank|
        @cards << Card.new(suit, rank)
      end
    end
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
  attr_reader :value

  CARD_HASH = { A: 99, J: 11, Q: 12, K: 13 }

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
    @value = CARD_HASH[rank] || rank
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.start_game
end
