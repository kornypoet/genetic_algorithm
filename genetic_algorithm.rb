require 'rubygems'
require 'chromosome'
require 'json'

class GeneticAlgorithm

  attr_reader :chrome_length, :target, :pop_size, :chromosomes, :cross_rate, :mutate_rate,
              :generation, :cross_amt, :mutate_amt

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
    @cross_amt     = 0
    @mutate_amt    = 0
    @chromosomes   = populate @pop_size, @chrome_length
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
    @mutate_amt += 1
    bin_string = bin_string.gsub(/1/,'a').gsub(/0/,'1').gsub(/a/,'0')
  end

  def cross(x_chrome, y_chrome)
    @cross_amt += 1
    cross_spot = rand x_chrome.size
    return [y_chrome, x_chrome] if cross_spot == 0
    crossed_y = y_chrome.slice(0..cross_spot-1) + x_chrome.slice(cross_spot..-1)
    crossed_x = x_chrome.slice(0..cross_spot-1) + y_chrome.slice(cross_spot..-1)
    [crossed_x, crossed_y]
  end

  def calculate_fitness actual, target
    fitness = (100.0 / (target - actual)).abs
    return Infinity if fitness == Infinity
    fitness >= 100 ? 99.0 : ("%.4f" % fitness).to_f
  end

  def update_fitness! target
    @chromosomes.each do |chrome|
      chrome.fitness = calculate_fitness(chrome.numeric_value, target)
      throw :win_condition if chrome.fitness == Infinity
    end
  end

  def total_fitness
    total_fitness = 0.0
    @chromosomes.each do |chrome|
      total_fitness += chrome.fitness
    end
    total_fitness
  end

  def roulette (fit_level = total_fitness)
    current_fitness = 0.0
    slice = rand(fit_level.ceil)
    @chromosomes.each do |chrome|
      current_fitness += chrome.fitness
      return chrome if current_fitness >= slice
    end
  end

  def decide? rate
    rand < rate.to_f
  end

  def new_generation population
    @chromosomes.replace population
    @generation += 1
  end

  def create_children parent_one, parent_two
    if decide? @cross_rate
      offspring_one, offspring_two = cross(parent_one.bit_value, parent_two.bit_value)
    else
      decide? @mutate_rate ? offspring_one = mutate(parent_one.bit_value) : offspring_one = parent_one.bit_value
      decide? @mutate_rate ? offspring_two = mutate(parent_two.bit_value) : offspring_two = parent_two.bit_value
    end
    return [offspring_one, offspring_two]
  end

  def simulate!
    catch :win_condition do
      while true do
        update_fitness! @target
        new_pop = []
        (@pop_size / 2).times do
          child_one, child_two = create_children(roulette, roulette)
          new_pop << Chromosome.new(child_one) << Chromosome.new(child_two)
        end
        new_generation new_pop
      end
    end
  end

  def stats &block
    stats = {
      :pop_size      => @pop_size,
      :total_fitness => @total_fitness,
      :cross_rate    => @cross_rate,
      :mutate_rate   => @mutate_rate,
      :current_gen   => @generation,
      :mutate_amt    => @mutate_amt,
      :cross_amt     => @cross_amt
    }
    yield stats
  end

end

