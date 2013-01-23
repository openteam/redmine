class AddSendedToIssue < ActiveRecord::Migration
  def change
    add_column :issues, :sended, :boolean, :default => false
  end
end
