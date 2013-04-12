class AddAccountsVerified < ActiveRecord::Migration
  def self.up
    change_table :accounts do | t |
      t.boolean :verified
    end
  end

  def self.down
    remove_column :accounts, :verified
  end
end
