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
		@markov_filename = ".#{self.class.name}_markov.yaml"
		@total_rounds = 0
		@wins = 0
		load_moves
	end

	def report
		puts "#{self.class.name}"
		puts "\tROUNDS:\t#{@total_rounds}"
		puts "\tWINS:\t#{@wins}"
		puts "\tWIN%:\t#{(@wins.to_f / @total_rounds.to_f) * 100.0}%"
	end

	## Manages a round
	def round(player_move)
		raise RuntimeError, "#{player_move} is not an acceptable move" unless is_acceptable(player_move.to_sym)
		@past_moves << player_move
		bot_move = execute_move
		round = declare_winner(bot_move, player_move)
		# puts "Round: #{round}"
		@total_rounds += 1
		@wins += 1 if round < 0
		save_moves
		round
	end

	## Returns all the available bots
	def self.get_all_available_bots
		ObjectSpace.each_object(Class).select {|c| c < self }
	end

	protected

	## -1 if bot won, 0 if draw, 1 if player won
	def declare_winner(bot_move, player_move)
		return 0 if bot_move == player_move

		if bot_move == :r && player_move == :p
			1
		else
			-1
		end

		if bot_move == :p && player_move == :s
			1
		else
			-1
		end

		if bot_move == :s && player_move == :r
			1
		else
			-1
		end
	end

	## Abstract function required to be implemented by children
	def execute_move
		raise RuntimeError, 'This must be implemented in child class'
	end

	## Loads up all the old moves
	def load_moves
		if File.exists?(@filename)
			@past_moves = YAML.load_file(@filename)
		else
			@past_moves = []
		end
	end

	## Saves all the old moves
	def save_moves
		File.open(@filename, 'w') {|f| f.write(@past_moves.to_yaml)}
	end

	## Checks to see if the move provided is acceptable
	def is_acceptable(move)
		@@ACCEPTABLE_MOVES.include?(move)
	end

	# Returns the winner against the move provided
	def get_winner_against(move)
		if move == :r
			:p
		elsif move == :p
			:s
		else
			:r
		end
	end

	## Returns markov chain based upon the list of all past moves
	def get_markov_chain
    markov = nil

    if File.exists?(@markov_filename)
      markov = YAML.load_file(@markov_filename)
    else
      markov = {}
      i = 0

      while i < @past_moves.size - 3
        chain = [ @past_moves[i], @past_moves[i + 1], @past_moves[i + 2]]

        if markov[chain].nil?
          markov[chain] = {
            :r => 0,
            :p => 0,
            :s => 0
          }
        end

        next_move = @past_moves[i + 3]
        markov[chain][next_move] += 1

        i += 1
      end
    end

    markov
  end
end

# Get all the bots
Dir['*_bot.rb'].each { |f| require_relative f }
bots = []
RPSBot.get_all_available_bots.each { |b| bots << b.new }

# Play the game
while true
	print '> '
	move = gets.chomp.to_sym
	break if move == :quit

	begin
		bots.each do |bot|
			res = bot.round(move)

			if res < 0
				puts "#{bot.class.name} won"
			elsif res == 0
				puts "#{bot.class.name} drew"
			else
				puts "#{bot.class.name} lost"
			end
		end
	rescue RuntimeError
		puts "#{move} is not an acceptable move!"
		next
	end
end

bots.each do |bot|
	bot.report
end








