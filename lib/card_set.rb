class CardSet
  attr_reader :set_name, :set_code, :block_name, :block_code, :border, :release_date, :printings
  def initialize(data)
    @set_name     = data["set_name"]
    @set_code     = data["set_code"]
    @block_name   = data["block_name"]
    @block_code   = data["block_code"] && data["block_code"].downcase
    @border       = data["border"]
    @release_date = data["release_date"] && Date.parse(data["release_date"])
    @printings    = Set[]
  end

  # core set or expansion
  def regular?
    if @regular.nil?
      regular_sets = Set[*%W[
        10e 4e 5dn 5e 6e 7e 8e 9e bfz ai al ala an ap aq arb avr
        be bng bok cfx chk cs dgm di dk dka ds dtk eve ex fe frf
        fut gp gtc hl ia in isd jou ju ktk le lg lw m10 m11 m12
        m13 m14 m15 mbs mi mm mr mt ne nph od on ori pc pr ps rav
        roe rtr rv sc sh shm sok som ths tp tr ts tsts ud ul
        un us vi wl wwk zen
      ]]
      @regular = regular_sets.include?(set_code)
    end
    @regular
  end

  include Comparable
  def <=>(other)
    set_code <=> other.set_code
  end

  def hash
    @set_code.hash
  end
end
