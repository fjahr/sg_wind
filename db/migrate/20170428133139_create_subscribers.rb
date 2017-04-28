class CreateSubscribers < ActiveRecord::Migration[5.0]
  def change
    create_table :subscribers do |t|
      t.string :facebook_id

      t.timestamps
    end
  end
end
