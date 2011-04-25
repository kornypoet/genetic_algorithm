require 'genetic_algorithm'

def test_options
  { 'chrome_length' => 20, 'target' => 20.0, 'pop_size' => 20 }
end

describe GeneticAlgorithm do
  before :each do
    @test_ga = GeneticAlgorithm.new test_options
  end

  it "should be able to be initiated with a specified chromosome length, population size, and target" do
    @test_ga.target.should        == test_options['target']
    @test_ga.pop_size.should      == test_options['pop_size']
    @test_ga.chrome_length.should == test_options['chrome_length']
  end

  it "should ONLY be initiated with target as a Float" do
    options = { 'chrome_length' => 10, 'target' => 20, 'pop_size' => 2 }
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
    mutated.should == '001100110011'
  end

  it "should be able to cross two binary strings at a specified crossover point" do
    pending "Don't know how to test this yet"
  end

  it "should be able calculate fitness score based on an actual and a target value" do
    test_target  = 50.0
    test_val_one = 48.0
    test_val_two = 49.5
    fitness_one  = @test_ga.calculate_fitness test_val_one, test_target
    fitness_two  = @test_ga.calculate_fitness test_val_two, test_target
    fitness_one.should == 50.0
    fitness_two.should == 99.0
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
  end

  it "should be able to use roulette wheel selection to choose an eligible chromosome" do
    pending "Don't know how to test this yet"
  end

end


