require 'rspec/autorun'
class NumberGenerator
  def create
    if find == 1
      puts "as"
      return 2
    end
    puts "assdf"

    return 3
  end

  def find
    return 12
  end
end

class Contr
  def initialize(ng = NumberGenerator.new)
    @ng = ng
  end

  def use
    a = @ng.create

    b = nil
    if a == 3
      puts "hurraaay"
      b = @ng.find
    end
    puts a
    puts b.nil?

    return a
  end
end

RSpec.describe "Random" do
  it "generates a random number" do
    ng = NumberGenerator.new
    g = Contr.new(ng)
    allow(ng).to receive(:find) do
      puts "sdfsdfsdfsd"
      1
    end
    expect(g.use).to eq(2)

  end
end