class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.integer :uid, :limit => 8

      t.timestamps
    end
  end
end
