class AddDemographicsToSelection < ActiveRecord::Migration
  def change
    add_column :selections, :demographic_school, :string
    add_column :selections, :demographic_status, :string
  end
end
