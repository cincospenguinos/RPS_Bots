class RandomBot < RPSBot

	def execute_move
		@@ACCEPTABLE_MOVES[rand(3)]
	end
end