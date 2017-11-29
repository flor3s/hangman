require "json"

class Hangman
  def initialize
  	@guesses_remaining = 6
  	@guess_word = guess_word
  	@chosen_letters = []
  	@board = @guess_word.each_char.map {|l| "-"}.join("")
  	@game_over = false
  	start_game
  end

  def start_game
  	puts "Welcome to Hangman! To start a new game, just press enter. To load a saved game, type 'load'."
  	print "> "
    answer = gets.chomp
    if answer.empty?
    	player_turn
    elsif answer == "load"
    	if Dir.exists? "saved_games"
    		puts "Saved Games:"
      	files = Dir.glob("./saved_games/*")
      	files.each do |file|
      		puts file.split("/")[2]
      	end
      	puts "\n"
      	puts "Please enter the name of the game you would like to load:"
      	print "> "
      	saved_game = gets.chomp
      	load_game(saved_game)
      else
    	  puts "There are no saved games! Starting new game. . ."
        player_turn
      end
    else
    	puts "Invalid entry! Restarting. . ."
    	start_game
    end
  end

  def guess_word
  	word = ""
  	all_words = File.readlines("wordlist.txt")

  	until word.length > 5
  		word = all_words.sample
  	end
  	
  	word
  end

  def incorrect_guess(letter)
  	if @guesses_remaining > 1
  		@guesses_remaining -= 1
  		@chosen_letters << letter

  		if @guesses_remaining > 1
  		  puts "You have #{@guesses_remaining.to_s} incorrect guesses remaining."
  		  puts "Used letters: #{@chosen_letters.join}"
    	  puts @board
  		else
  			puts "You have 1 incorrect guess remaining."
  			puts "Used letters: #{@chosen_letters.join}"
    	  puts @board
  		end
  	else
  		puts "Game over!"
  		puts @board
  		puts "The correct word was: #{@guess_word}"
  		@game_over = true
  	end
  end

  def correct_guess(letter, index)
  	@board[index] = letter
  	if @board == @guess_word
  	  puts "Congratulations! You won!"
  	  @game_over = true
  	end
  end

  def save_game(filename)
  	new_file = JSON.dump ({
  		:guesses_remaining => @guesses_remaining,
  		:guess_word => @guess_word,
  		:chosen_letters => @chosen_letters,
  		:board => @board,
  		:game_over => @game_over
  		})
    
    Dir.mkdir "saved_games" unless Dir.exists? "saved_games"
    File.open("./saved_games/#{filename}", "w") { |line| line.puts new_file }
  end

  def load_game(filename)
  	game_data = File.read("./saved_games/#{filename}")
  	save = JSON.load(game_data)
  	save.each{ |key, value| self.instance_variable_set("@#{key}", value) }
  	player_turn
  end

  def player_turn
  	puts "Please guess a letter, or type 'save' to save your game: "
  	print "> "
    input = gets.chomp
    
    while @game_over == false && input != "save"
      if @guess_word.include?(input)
      	0.upto(@guess_word.length - 1).each do |index|
    		  correct_guess(input, index) if @guess_word[index] == input
    	  end

    	  puts @board
      else
    	  incorrect_guess(input)
      end
      
      player_turn if @game_over == false
    end

    if input == "save"
    	puts "Please enter a name for the file:"
    	print "> "
    	filename = gets.chomp
      save_game(filename)
      puts "Game saved! You can use Ctrl+C to exit, or you may continue below."
      player_turn
    end
  end
end

Hangman.new