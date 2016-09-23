class OracleVerifier
  def initialize
    @versions = {}
  end

  def add(set_code, card_data)
    name = card_data["name"]
    @versions[name] ||= []
    @versions[name] << [set_code, card_data]
  end

  def validate_and_report!(card_name, versions)
    # All versions are same, no reason to dig deeper
    return if versions.map(&:last).uniq.size == 1
    # Something failed
    keys = versions.map(&:last).map(&:keys).inject(&:|)
    keys.each do |key|
      # This key is fine
      next if versions.map(&:last).map{|version| version[key]}.uniq.size == 1
      # This key is broken
      variants = {}
      versions.each do |set_code, version|
        variant = version[key]
        variants[variant] ||= []
        variants[variant] << set_code
      end
      puts "Key #{key} of card #{card_name} is inconsistent between versions"
      variants.each do |variant, printings|
        puts "* #{variant.inspect} - #{printings.join(" ")}"
      end
      puts ""
    end
  end

  def report!
    @versions.each do |card_name, versions|
      validate_and_report!(card_name, versions)
    end
  end
end
