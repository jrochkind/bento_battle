class AddQueryToSelections < ActiveRecord::Migration
  def change
    add_column :selections, :query, :string
  end
end
