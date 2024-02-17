class Game
  def start_game
    puts '戦争を開始します。'
  end
end

if __FILE__ == $0
  game = Game.new
  game.start_game
end