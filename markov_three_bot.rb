class MarkovThreeBot < RPSBot

  def execute_move
    if @past_moves.size < 4
      @@ACCEPTABLE_MOVES[rand(3)]
    else
      # Grab all the chains and put them in the markov set
      markov = get_markov_chain

      # Get the most recent chain
      size = @past_moves.size
      most_recent = [ @past_moves[size - 3], @past_moves[size - 2], @past_moves[size - 1] ]

      # If the most recent chain is nil, do something random. Otherwise,
      # get the one that is most likely to beat the current move
      if markov[most_recent].nil?
        @@ACCEPTABLE_MOVES[rand(3)]
      else
        player_move = markov[most_recent].max_by { |k, v| v }[0]
        get_winner_against(player_move)
      end
    end
  end
end