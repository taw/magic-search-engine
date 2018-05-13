describe "Opening packs smoke test" do
  include_context "db"

  it "Opening packs should return something" do
    db.sets.each do |set_code, set|
      pack = Pack.for(db, set_code)
      next unless pack
      pack.open
    end
  end
end
