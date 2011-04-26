require 'chromosome'

class GeneticAlgorithm

  attr_reader :chrome_length, :target, :pop_size, :chromosomes, :cross_rate, :mutate_rate, :generation

  Infinity = 1.0 / 0

  def initialize( options = {} )
    raise "Target needs to be a Float"            unless options['target'].instance_of? Float
    raise "Cross Rate must be between 0 and 1"    unless (0..1).include? options['cross_rate']
    raise "Mutation Rate must be between 0 and 1" unless (0..1).include? options['mutate_rate']
    @target        = options['target']
    @pop_size      = options['pop_size']
    @chrome_length = options['chrome_length']
    @cross_rate    = options['cross_rate']
    @mutate_rate   = options['mutate_rate']
    @chromosomes   = populate @pop_size, @chrome_length
    @total_fitness = total_fitness
    @generation    = 1
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

  def cross(x_chrome, y_chrome)
    cross_spot = rand x_chrome.size
    return [y_chrome, x_chrome] if cross_spot == 0
    crossed_y = y_chrome.slice(0..cross_spot-1) + x_chrome.slice(cross_spot..-1)
    crossed_x = x_chrome.slice(0..cross_spot-1) + y_chrome.slice(cross_spot..-1)
    [crossed_x, crossed_y]
  end

  def calculate_fitness actual, target
    fitness = (100.0 / (target - actual)).abs
    return fitness if fitness == Infinity
    fitness >= 100 ? 99.0 : ("%.4f" % fitness).to_f
  end

  def update_fitness! target
    @chromosomes.each { |chrome| chrome.fitness = calculate_fitness(chrome.numeric_value, target) }
  end

  def total_fitness
    total_fitness = 0.0
    @chromosomes.each do |chrome|
      total_fitness += chrome.fitness
    end
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

  def decide? rate
    rand < rate
  end

  def new_generation population
    @chromosomes.replace population
    @generation += 1
  end

  def simulate!

  end

  def state
    "Current Population: #{@pop_size}\nTotal Fitness: #{@total_fitness}\nCross Rate: #{@cross_rate}\nMutation Rate: #{@mutate_rate}\nCurrent Generation: #{@generation}"
  end
end

