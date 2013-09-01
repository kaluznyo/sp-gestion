# -*- encoding : utf-8 -*-
class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string(:title)
      t.text(:description)
      t.integer(:quantity)
      t.date(:expiry)
      t.text(:rem)
      t.references(:check_list)
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
