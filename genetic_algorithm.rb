require 'chromosome'

class GeneticAlgorithm

  attr_reader :chrome_length, :target, :pop_size, :chromosomes

  Infinity = 1.0 / 0

  def initialize( options = {} )
    raise "Target needs to be a Float" unless options['target'].instance_of? Float
    @target        = options['target']
    @pop_size      = options['pop_size']
    @chrome_length = options['chrome_length']
    @chromosomes   = populate @pop_size, @chrome_length
    @total_fitness = total_fitness
  end

  def random_gen length
    bin_string = (1..length).inject("") { |str, foo| str += rand(2).to_s }
  end

  def populate size, length
    population = []
    size.times { population.push Chromosome.new(random_gen length) }
    population
  end

  def mutate bin_string
    bin_string = bin_string.gsub(/1/,'a').gsub(/0/,'1').gsub(/a/,'0')
  end

  def crossover(x_chrome, y_chrome)
    cross_spot = rand(x_chrome.bit_value.size)
    crossed_y = y_chrome.bit_value.slice(0..cross_spot-1) + x_chrome.bit_value.slice(cross_spot..-1)
    crossed_x = x_chrome.bit_value.slice(0..cross_spot-1) + y_chrome.bit_value.slice(cross_spot..-1)
    [crossed_x, crossed_y]
  end

  def calculate_fitness actual, target
    fitness = (100.0 / (target - actual)).abs
    fitness >= 100 ? 99.0 : ("%.4f" % fitness).to_f
  end

  def update_fitness! target
    @chromosomes.each { |chrome| chrome.fitness = calculate_fitness(chrome.numeric_value, target) }
  end

  def total_fitness
    total_fitness = 0.0
    @chromosomes.each { |chrome| total_fitness += chrome.fitness }
    total_fitness
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

