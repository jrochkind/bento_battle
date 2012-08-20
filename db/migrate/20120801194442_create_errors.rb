class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.string :engine
      t.text :backtrace
      t.text :error_info

      t.timestamps
    end
  end
end
