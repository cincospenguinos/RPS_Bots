# RPS
#
# Trying out different algorithms for RPS.

require 'yaml'

class RPSBot
	@@ACCEPTABLE_MOVES = [:r, :p, :s].freeze

	attr_reader :past_moves
	attr_reader :filename

	def initialize
		@filename = ".#{self.class.name}.yaml"
		load_moves
	end

	def save_moves
		File.open(@filename, 'w') {|f| f.write(@past_moves.to_yaml)}
	end

	def round(move)
		raise RuntimeError, "#{move} is not an acceptable move" unless is_acceptable(move.to_sym)
		@past_moves << move
		execute_move
	end

	private

	def execute_move
		raise RuntimeError, 'This must be implemented in child class'
	end

	def load_moves
		if File.exists?(@filename)
			@past_moves = YAML.load_file(@filename)
		else
			@past_moves = []
		end
	end

	def is_acceptable(move)
		@@ACCEPTABLE_MOVES.include?(move)
	end
end

class RandomBot < RPSBot

	def execute_move
		@@ACCEPTABLE_MOVES[rand(3)]
	end
end

bot1 = RandomBot.new
puts bot1.round(:s)












