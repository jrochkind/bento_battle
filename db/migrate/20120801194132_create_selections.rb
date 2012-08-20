class CreateSelections < ActiveRecord::Migration
  def change
    create_table :selections do |t|
      t.string :option_a
      t.string :option_b
      t.string :choice

      t.timestamps
    end
  end
end
