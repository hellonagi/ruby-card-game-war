class Game
  attr_reader :players

  def initialize
    @players = []
  end

  def start_game(player_count: 2)
    @player_count = player_count
    # プレイヤー数だけPlayerインスタンスを作成
    make_players

    # 開始メッセージ
    puts '戦争を開始します。'
  end

  def make_players
    @player_count.times do |i|
      @players << Player.new(i + 1)
    end
  end
end

class Player
  def initialize(num)
    @name = "プレイヤー#{num}"
    @hand = []
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.start_game
end
