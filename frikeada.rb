require 'launchpad'
require 'pry'

interaction = Launchpad::Interaction.new

RED =   { :red => :high, :green => :off  }
GREEN = { :red => :off,  :green => :high }

OFF = { :red => :off, :green => :off }

$quiz = []

def generate_quiz(interaction, size)
  size.times do | time |
    $quiz << {x: rand(8), y: rand(8)}
    interaction.device.change :grid, $quiz.last.merge(GREEN)
  end
end

generate_quiz interaction, 4

interaction.response_to(:grid, :down) do |interaction, action|

  puts $quiz.inspect

  foo= {
    :x => action[:x],
    :y => action[:y]
  }

  if $quiz.include?(foo)
    interaction.device.change :grid, foo.merge(OFF)
    $quiz.delete foo

    if $quiz.empty?
      generate_quiz interaction, 4
    end
  else
    interaction.device.change :grid, foo.merge(RED)
  end

end

interaction.start
