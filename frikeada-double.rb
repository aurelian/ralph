require 'launchpad'
require 'pry'

interaction = Launchpad::Interaction.new

RED =   { :red => :high, :green => :off  }
GREEN = { :red => :off,  :green => :high }

OFF = { :red => :off, :green => :off }

class Map
  def initialize
    @map = []
  end

  def add(pos)
    @map << pos
  end

  def rem(pos)
    @map.delete(pos)
  end

  def free?(pos)
    !@map.include?(pos)
  end
end

class Player
  attr_accessor :name, :color, :quiz

  def initialize(name, interaction, map, color)
    @name = name
    @color = color
    @map = map
    @interaction = interaction
    @quiz = []
    @score = 0
  end

  def generate_quiz(size)
    size.times do | time |
      add_alive_cell
      @interaction.device.change :grid, @quiz.last.merge(@color)
    end
  end

  def update(hit, interaction)
    if @quiz.include?(hit)
      interaction.device.change :grid, hit.merge(OFF)
      @quiz.delete hit
      @map.rem(hit)
    end
    if @quiz.empty?
      @score = @score + 1
      generate_quiz 4
    end
  end

  def add_alive_cell
    pos = {x: rand(8), y: rand(8)}
    if @map.free?(pos)
      @quiz << pos
      @map.add(pos)
    else
      add_alive_cell
    end
  end
end

map = Map.new
player1 = Player.new("player1", interaction, map , RED)
player2 = Player.new("player2", interaction, map, GREEN)

player1.generate_quiz 4
player2.generate_quiz 4

interaction.response_to(:grid, :down) do |interaction, action|

  hit= {:x => action[:x], :y => action[:y]}

  player1.update hit, interaction
  player2.update hit, interaction

end

interaction.start

at_exit do
  puts "player1 score is #{player1.score}"
  puts "player2 score is #{player2.score}"
end

