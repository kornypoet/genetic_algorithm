class Chromosome

  attr_accessor :bit_value, :string_value, :fitness

  Nan = 0.0 / 0.0

   @@bit_decoder = {
    '0000' => 0.0,
    '0001' => 1.0,
    '0010' => 2.0,
    '0011' => 3.0,
    '0100' => 4.0,
    '0101' => 5.0,
    '0110' => 6.0,
    '0111' => 7.0,
    '1000' => 8.0,
    '1001' => 9.0,
    '1010' => '+',
    '1011' => '-',
    '1100' => '*',
    '1101' => '/',
  }

  def initialize bits
    @bit_value = bits
    @string_value = parse @bit_value
    @fitness = 0.0
  end

  def to_s
    "Bit Value: #{@bit_value}\nString Value:#{@string_value}\nFitness: #{@fitness}"
  end

  def parse chromosome
    bit_string = ''
    looking_for = 'digit'
    chromosome.scan(/..../).each do |bit|
      case looking_for
      when 'digit'
        next unless @@bit_decoder[bit].respond_to? :ceil
        bit_string += @@bit_decoder[bit].to_s
        looking_for = 'symbol'
      when 'symbol'
        next unless @@bit_decoder[bit].respond_to? :scan
        bit_string += @@bit_decoder[bit]
        looking_for = 'digit'
      end
    end
    bit_string.gsub(/\D\z/, '')
  end

  def update_fitness! target
    begin
      value = eval @string_value
      @fitness = (1.0 / (target - value)).abs
      raise ZeroDivisionError if @fitness == Nan
    rescue ZeroDivisionError
      @fitness = 0.0
    end
  end

end
