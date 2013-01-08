class AddTwitterUidToPeople < ActiveRecord::Migration
  def change
    add_column :people, :twitter_uid, :string
  end
end
