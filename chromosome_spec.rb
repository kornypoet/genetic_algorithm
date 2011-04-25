require 'chromosome'

def test_bits
  '10100110110010001111101000101011101'
end

describe Chromosome do
  before :each do
    @test_chrome = Chromosome.new test_bits
  end

  it "should be initiated ONLY with a string of binary-encoded bits" do
    begin
      @bad_chrome_two = Chromosome.new 11001100
    rescue
    end
    @bad_chrome.should be nil
    begin
      @bad_chrome_one = Chromosome.new '1100aabb'
    rescue
    end
    @bad_chrome.should be nil
  end

  it "should be able to display its bit value" do
    @test_chrome.bit_value.should == test_bits
  end

  it "should be able to decode its bit value" do
    bits = @test_chrome.bit_value
    @test_chrome.decode(bits).should == ['+','6','*','8','+','2','-']
  end

  it "should be able to correct decoded bits into an evaluatable string" do
    decoded_bits = @test_chrome.decode test_bits
    @test_chrome.correct(decoded_bits).should == "6.0*8.0+2.0"
  end

  it "should be able to display its string value" do
    @test_chrome.string_value.should == "6.0*8.0+2.0"
  end

  it "should be able to correctly compute a numeric string" do
    test_val_one   = "6.0*8.0+2.0"
    test_val_two   = "4.0+6.0/9.0"
    test_val_three = "5.0-0.0/0.0"
    test_val_four  = "5.0/0.0+2.0"
    test_val_five  = ""
    @test_chrome.compute(test_val_one).should   == 50.0
    @test_chrome.compute(test_val_two).should   == 4.6667
    @test_chrome.compute(test_val_three).should == 0.0
    @test_chrome.compute(test_val_four).should  == 0.0
    @test_chrome.compute(test_val_five).should  == 0.0
  end

  it "should be able to display its numeric value" do
    @test_chrome.numeric_value.should == 50.0
  end

  it "should begin with a fitness score of 0.0" do
    @test_chrome.fitness.should == 0.0
  end

  it "should be able to update its fitness ONLY if given a Float" do
    test_val_one = 5
    test_val_two = 5.0
    begin
      @test_chrome.fitness = test_val_one
    rescue
    end
    @test_chrome.fitness.should == 0.0
    begin
      @test_chrome.fitness = test_val_two
    rescue
    end
    @test_chrome.fitness.should == test_val_two
  end

end

