class Game
  attr_reader :players

  def initialize(deck)
    @players = []
    @deck = deck
  end

  def start_game
    # プレイヤー数を指定
    register_player_count

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

  def register_player_count
    loop do
      print 'プレイヤーの人数を入力してください（2〜5）: '
      input = gets.chomp
      if input.match?(/\A[2-5]\z/)
        @player_count = input.to_i
        break
      end
      puts '2～5の数字を入力してください。'
    end
  end

  def make_players
    @player_count.times do |i|
      print "プレイヤー#{i + 1}の名前を入力してください: "
      player_name = gets.chomp
      @players << Player.new(player_name)
    end
  end

  def battle
    # 場札
    stacked_cards = []

    # 誰かの手札がなくなるまでゲームを続ける
    until empty_hand?
      puts '戦争！'
      battle_cards = draw_battle_cards(stacked_cards)
      winner = decide_winner(battle_cards)
      add_stacked_cards_to_winner(winner, stacked_cards)
    end

    add_taken_cards_to_hand
    show_players_hands
    result = calculate_result
    announce_result(result)
  end

  # 手札からカードをだす
  def draw_battle_cards(stacked_cards)
    battle_cards = []
    a_count = 0
    has_spade_a = false
    has_joker = false

    @players.each do |player|
      draw_card = player.hand.pop
      # Aの数をカウント、スペードのAの有無をチェック
      if draw_card.rank == :A
        a_count += 1
        has_spade_a = true if draw_card.suit == :スペード
      end
      # ジョーカーの有無をチェック
      has_joker = true if draw_card.suit == :ジョーカー

      stacked_cards << draw_card
      battle_cards << draw_card
    end

    # スペードのAが「世界一」の条件を満たすかチェック
    no_1 = a_count >= 2 && has_spade_a && !has_joker

    # 条件に応じて出力を切り替える
    battle_cards.each_with_index do |card, index|
      card_name = "#{card.suit}の#{card.rank}"
      if no_1 && card.rank == :A && card.suit == :スペード
        card_name = '世界一'
      elsif card.rank == :JOKER
        card_name = 'ジョーカー'
      end
      puts "#{@players[index].name}のカードは#{card_name}です。"
    end

    battle_cards
  end

  # 手札がなくなったプレイヤーがいないか確認
  def empty_hand?
    empty_exists = false
    @players.each do |player|
      # 手札が0枚のとき
      if player.hand.empty?
        # 取った場札がなければ終了
        if player.taken_cards.empty?
          puts "#{player.name}の手札がなくなりました。"
          empty_exists = true
        # あればシャッフルして回収
        else
          player.hand += player.taken_cards.shuffle
          player.taken_cards.clear
        end
      end
    end
    empty_exists
  end

  # 勝敗の判定。勝ったプレイヤーのインスタンスを返す。引き分けの場合はnilを返す。
  def decide_winner(battle_cards)
    highest_card, highest_player_index = battle_cards.each_with_index.max_by { |element, _| element.value }
    if battle_cards.count { |card| card.value == highest_card.value } >= 2
      puts '引き分けです。'
      return
    end
    players[highest_player_index]
  end

  # 勝ったプレイヤーに場札を渡す。引き分けの場合は何もしない。
  def add_stacked_cards_to_winner(winner, stacked_cards)
    unless winner.nil?
      puts "#{winner.name}が勝ちました。#{winner.name}はカードを#{stacked_cards.size}枚もらいました。"
      winner.taken_cards += stacked_cards
      stacked_cards.clear
    end
  end

  # 各プレイヤー場札から取ったカードを手札に加える
  def add_taken_cards_to_hand
    @players.each do |player|
      player.hand += player.taken_cards
      player.taken_cards.clear
    end
  end

  # 各Playerの手札を表示する
  def show_players_hands
    puts @players.map { |p| "#{p.name}の手札の枚数は#{p.hand.size}枚です。" }.join()
  end

  # Playerインスタンスを手札の枚数によって降順で並べる
  def calculate_result
    @players.sort { |a, b| b.hand.size <=> a.hand.size }
  end

  # 最終結果を表示する
  # 同じ枚数を持つプレイヤーには同じ順位を割り当てる
  def announce_result(result)
    ranks = [1]
    rank = 1

    # 隣同士のプレイヤーを比較し点数が違う場合順位を下げる
    result.each_cons(2).with_index do |(p1, p2), index|
      if p1.hand.size != p2.hand.size
        rank = index + 2
      end
      ranks << rank
    end

    puts result.map.with_index { |r, i| "#{r.name}が#{ranks[i]}位" }.join('、') + 'です。'
  end
end

class Player
  attr_reader :name
  attr_accessor :hand, :taken_cards

  def initialize(name)
    @name = name
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
    deck << Card.new(:ジョーカー, :JOKER)
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
  CARD_HASH = { A: 99, J: 11, Q: 12, K: 13, JOKER: 999 }

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
    # スペードのAの強さを100、他のマークのAの強さを99とする
    if suit == :スペード && rank == :A
      @value = 100
    else
      @value = CARD_HASH[rank] || rank
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(Deck.new)
  game.start_game
end
