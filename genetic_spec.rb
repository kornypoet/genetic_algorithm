require 'genetic_algorithm'

def test_options
  { 'chrome_length' => 20, 'target' => 20.0, 'pop_size' => 20, 'cross_rate' => 0.7, 'mutate_rate' => 0.1 }
end

Infinity = 1.0 / 0.0

describe GeneticAlgorithm do
  before :each do
    @test_ga = GeneticAlgorithm.new test_options
  end

  it "should be able to be initiated with a specified chromosome length, population size, and target" do
    @test_ga.target.should        == test_options['target']
    @test_ga.pop_size.should      == test_options['pop_size']
    @test_ga.chrome_length.should == test_options['chrome_length']
    @test_ga.cross_rate.should    == test_options['cross_rate']
    @test_ga.mutate_rate.should   == test_options['mutate_rate']
  end

  it "should be initiated with a starting generation of 1" do
    @test_ga.generation.should == 1
  end

  it "should ONLY be initiated with target as a Float" do
    options = { 'chrome_length' => 10, 'target' => 20, 'pop_size' => 2 }
    begin
      test_ga = GeneticAlgorithm.new options
    rescue
    end
    test_ga.should be nil
  end

  it "should ONLY be initiated with crossover rate between 0 and 1" do
    { 'chrome_length' => 20, 'target' => 20.0, 'pop_size' => 20, 'cross_rate' => 50.0, 'mutate_rate' => 0.1 }
    begin
      test_ga = GeneticAlgorithm.new options
    rescue
    end
    test_ga.should be nil
  end

  it "should ONLY be initiated with mutation rate between 0 and 1" do
    { 'chrome_length' => 20, 'target' => 20.0, 'pop_size' => 20, 'cross_rate' => 0.7, 'mutate_rate' => 50.0 }
    begin
      test_ga = GeneticAlgorithm.new options
    rescue
    end
    test_ga.should be nil
  end

  it "should be able to generate a random binary string of bits of n length" do
    bin_string = @test_ga.random_gen 10
    bin_string.size.should be 10
    bin_string.match(/[^01]/).should be nil
  end

  it "should be able to populate an array of chromosomes of specified bit value length and population size" do
    size, length = test_options['pop_size'], test_options['chrome_length']
    population = @test_ga.populate size, length
    population.size.should == size
    population.each { |chrome| chrome.bit_value.size.should == length }
  end

  it "should be initiated with a population of chromosomes with a specified population size" do
    @test_ga.chromosomes.size.should == test_options['pop_size']
  end

  it "should be able to mutate a binary string by flipping its bits" do
    mutated = @test_ga.mutate '110011001100'
    mutated.should         == '001100110011'
  end

  it "should be able to cross two binary strings at a random crossover point" do
    bin_string_one, bin_string_two = '0000', '1111'
    cross_one, cross_two = @test_ga.cross bin_string_one, bin_string_two
    case cross_one
    when '1111'
      cross_two.should == '0000'
    when '0111'
      cross_two.should == '1000'
    when '0011'
      cross_two.should == '1100'
    when '0001'
      cross_two.should == '1110'
    end
  end

  it "should be able calculate fitness score based on an actual and a target value" do
    test_target    = 50.0
    test_val_one   = 48.0
    test_val_two   = 49.5
    test_val_three = 50.0
    fitness_one    = @test_ga.calculate_fitness test_val_one, test_target
    fitness_two    = @test_ga.calculate_fitness test_val_two, test_target
    fitness_three  = @test_ga.calculate_fitness test_val_three, test_target
    fitness_one.should   == 50.0
    fitness_two.should   == 99.0
    fitness_three.should == Infinity
  end

  it "should be able to update all chromosomes with a new fitness score based on a specified target" do
    test_target = 20.0
    pre_scores = @test_ga.chromosomes.map { |c| c.fitness }
    @test_ga.update_fitness! test_target
    updated_scores = @test_ga.chromosomes.map { |c| c.fitness }
    updated_scores.should_not eql pre_scores
  end

  it "should be able to return the total fitness of the chromosome population" do
    @test_ga.total_fitness.should == 0.0
    @test_ga.update_fitness! 20.0
    @test_ga.total_fitness.should > 0.0
    @test_ga.total_fitness.should < 100.0 * @test_ga.pop_size ||
      @test_ga.total_fitness.should == Infinity
  end

  it "should be able to use roulette wheel selection to choose an eligible chromosome" do
    @test_ga.update_fitness! @test_ga.target
    unless @test_ga.total_fitness == Infinity
      selection = @test_ga.roulette @test_ga.total_fitness
      @test_ga.chromosomes.should include selection
    end
  end

  it "should be more likely to select a chromosome with a higher fitness score using roulette" do
    @test_ga.update_fitness! @test_ga.target
    roulette_scores = []
    unless @test_ga.total_fitness == Infinity
      100.times do
        selection = @test_ga.roulette @test_ga.total_fitness
        roulette_scores.push selection.fitness
      end
      roulette_avg   = roulette_scores.inject(:+) / 100.0
      population_avg = @test_ga.total_fitness / @test_ga.pop_size
      roulette_avg.should be > population_avg
    end
  end

  it "should be able to decide to perform an action based on a given rate between 0 and 1" do
    test_rate = 0.5
    test_range = ((test_rate - 0.1)..(test_rate + 0.1))
    results = 0
    100.times do
      results += 1 if @test_ga.decide? test_rate
    end
    percentage = results / 100.0
    test_range.should include percentage
  end

  it "should be able to produce two children from two parents" do
    @test_ga.update_fitness! @test_ga.target
    p_one, p_two = @test_ga.roulette, @test_ga.roulette
    c_one, c_two = @test_ga.create_children(p_one, p_two)
  end

  it "should be able to replace the current population with a new generation" do
    test_pop = ['1111', '0000', '1111', '0000']
    @test_ga.new_generation test_pop
    @test_ga.chromosomes.should == test_pop
    @test_ga.generation.should  == 2
  end

  it "should be able to display its current state" do
    @test_ga.state.should be_instance_of String
  end

end


