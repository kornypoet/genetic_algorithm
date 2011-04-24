require 'chromosome'

class GeneticAlgorithm

  attr_accessor :chromosomes, :target, :max_generations, :crossover_rate, :mutation_rate

  Infinity = 1.0 / 0

  def initialize( options = {} )
    @target = options['target']
    @max_generations = options['max_generations']
    @chromosomes = []
    options['pop_size'].times do |n|
      chrome = Chromosome.new random_bits(options['chrome_length'])
      @chromosomes.push chrome
    end
  end

  def random_bits length
    chromosome = ''
    length.times { |n| chromosome += rand(2).to_s }
    chromosome
  end

  def crossover(x_chrome, y_chrome)
    cross_spot = rand(x_chrome.bit_value.size)
    crossed_y = y_chrome.bit_value.slice(0..cross_spot-1) + x_chrome.bit_value.slice(cross_spot..-1)
    crossed_x = x_chrome.bit_value.slice(0..cross_spot-1) + y_chrome.bit_value.slice(cross_spot..-1)
    [crossed_x, crossed_y]
  end

  def mutate! chromosome
    chromosome.bit_value = chromosome.bit_value.gsub(/1/,'a').gsub(/0/,'1').gsub(/a/,'0')
  end

  def roulette total_fitness
    current_fitness = 0.0
    slice = rand(total_fitness.ceil)
    @chromosomes.each do |chrome|
      current_fitness += chrome.fitness
      return chrome if current_fitness >= slice
    end
  end

  def start!
    iterations = 0
    catch :found do
      while iterations <= @max_generations
        puts "Iterations: #{iterations}"
        current_fitness = 0.0
        @chromosomes.each do |chrome|
          chrome.update_fitness! @target
          puts chrome.fitness
          if chrome.fitness == Infinity
            puts chrome
            throw :found
          end
          current_fitness += chrome.fitness
        end
        puts "Current fitness: #{current_fitness}"
        next_generation = []
        (@chromosomes.size / 2).times do
          parent1 = roulette current_fitness
          parent2 = roulette current_fitness
          crossover(parent1, parent2).each do |bits|
            child = Chromosome.new(bits)
            # mutate! child
            next_generation.push child
          end
        end
        @chromosomes = next_generation
        iterations += 1
      end
    end
  end

end

ga = GeneticAlgorithm.new({'pop_size'=> 100, 'chrome_length' => 100, 'target' => 56, 'max_generations' => 100 })
ga.start!
