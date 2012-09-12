class AddQueryToErrors < ActiveRecord::Migration
  def change
    add_column :errors, :query, :string
  end
end
