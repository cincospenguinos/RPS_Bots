# RPS
#
# Trying out different algorithms for RPS.

require 'yaml'

class RPSBot
	@@ACCEPTABLE_MOVES = [:r, :p, :s].freeze

	attr_reader :past_moves
	attr_reader :filename
	attr_reader :wins
	attr_reader :total_rounds

	def initialize
		@filename = ".#{self.class.name}.yaml"
		@total_rounds = 0
		@wins = 0
		load_moves
	end

	def save_moves
		File.open(@filename, 'w') {|f| f.write(@past_moves.to_yaml)}
	end

	def round(player_move)
		raise RuntimeError, "#{player_move} is not an acceptable move" unless is_acceptable(player_move.to_sym)
		@past_moves << player_move
		bot_move = execute_move
		round = declare_winner(bot_move, player_move)
		@total_rounds += 1
		@wins += 1 if round < 0
	end

	private

	def declare_winner(bot_move, player_move)
		return 0 if bot_move == player_move

		if bot_move == :r
			return 1 if player_move == :p
			return -1
		elsif bot_move == :p
			return 1 if player_move == :s
			return -1
		else
			return 1 if player_move == :r
			return -1
		end
	end

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












