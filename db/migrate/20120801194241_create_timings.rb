class CreateTimings < ActiveRecord::Migration
  def change
    create_table :timings do |t|
      t.string :engine
      t.integer :miliseconds

      t.timestamps
    end
  end
end
