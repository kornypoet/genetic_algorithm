require 'rubygems'
require 'genetic_algorithm'
require 'json'

VARIABLES = {
  'chrome_length' => 100,
  'target'        => 45.0,
  'pop_size'      => 100,
  'cross_rate'    => 0.7,
  'mutate_rate'   => 0.001
}

results   = []
c_results = []
m_results = []
TEST_RATE = 500
puts "Testing"
TEST_RATE.times do
  ga = GeneticAlgorithm.new VARIABLES
  ga.simulate!
  results << ga.generation
  c_results << ga.cross_amt
  m_results << ga.mutate_amt
  puts "#{ga.generation}:#{ga.cross_amt}:#{ga.mutate_amt}"
end

def average results
  results.inject(:+).to_f / TEST_RATE.to_f
end

def adjusted results
  drop_amt = (0.03 * TEST_RATE).ceil
  results.sort.slice(drop_amt..-(1 + drop_amt))
end

puts "mutations: " + average(adjusted m_results).to_s
puts "crossovers: " + average(adjusted c_results).to_s
puts "avg: " + average(results).to_s
puts average(adjusted results)

