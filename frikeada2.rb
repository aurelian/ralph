require 'launchpad'
require 'pry'

srand Time.now.to_i

interaction = Launchpad::Interaction.new

red =   { :red => :high, :green => :off  }
green = { :red => :off,  :green => :high }
off =   { :red => :off,  :green => :off  }

colors = []
quiz   = []
grid   = [
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1]
]

(0..7).each do | x |
  (0..7).each do | y |
    colors << {x: x, y: y}.merge(red)
  end
end

interaction.device.change_all colors


interaction.response_to(:grid, :down) do | interaction, action |

  hit= {:x => action[:x], :y => action[:y]}

  if quiz.include?(hit)
    interaction.device.change :grid, hit.merge(off)
    quiz.delete hit
    grid[action[:x]][action[:y]] = 0
  else
    interaction.device.change :grid, hit.merge(red)
    grid[action[:x]][action[:y]] = 1
  end

  next unless quiz.empty?

  # end game condition.
  i = 0
  grid.each do | k |
    i += k.inject(:+)
  end

  if i == 0
    puts "WIN!!"
    interaction.stop
    exit
  end

  # generate new quiz.
  while quiz.size < 1 do
    entry = {x: rand(8), y: rand(8)}
    unless quiz.include?(entry)
      quiz << entry
      interaction.device.change :grid, entry.merge(green)
      grid[entry[:x]][entry[:y]] = 1
    end
  end

end

interaction.start

