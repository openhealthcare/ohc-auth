class CreateEmailVerifications < ActiveRecord::Migration
  def self.up
    create_table :email_verifications do |t|
      t.integer :user_id
      t.datetime :created
      t.datetime :sent
      t.string :key
      t.timestamps
    end
  end

  def self.down
    drop_table :email_verifications
  end
end
