class Chromosome

  attr_reader :bit_value, :string_value, :numeric_value, :fitness

   @@bit_encoding = {
    '0000' => '0',
    '0001' => '1',
    '0010' => '2',
    '0011' => '3',
    '0100' => '4',
    '0101' => '5',
    '0110' => '6',
    '0111' => '7',
    '1000' => '8',
    '1001' => '9',
    '1010' => '+',
    '1011' => '-',
    '1100' => '*',
    '1101' => '/',
  }

  def initialize bits
    raise "Bit string must be binary encoded" if bits.match(/[^01]/)
    @bit_value = bits
    @string_value = correct(decode @bit_value)
    @numeric_value = compute @string_value
    @fitness = 0.0
  end

  def decode bits
    decoded = bits.scan(/..../).map { |gene| @@bit_encoding[gene] }.compact
  end

  def correct decoded
    corrected   = ""
    looking_for = 'digit'
    decoded.each do |gene|
      case looking_for
      when 'digit'
        next unless gene.match(/[0-9]/)
        corrected += gene.to_f.to_s
        looking_for = 'symbol'
      when 'symbol'
        next unless gene.match(/[\+\-\*\/]/)
        corrected += gene
        looking_for = 'digit'
      end
    end
    corrected.gsub(/\D\z/, '')
  end

  def compute numeric_string
    value = eval numeric_string
    ("%.4f" % value).to_f
  end

  def fitness= number
    raise "Can only assign fitness a Float" unless number.instance_of? Float
    @fitness = number
  end

  def to_s
    "Bit Value: #{@bit_value}\nString Value: #{@string_value}\nNumeric Value: #{@numeric_value}\nFitness: #{@fitness}"
  end

end
