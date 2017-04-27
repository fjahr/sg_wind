class CreateObservations < ActiveRecord::Migration[5.0]
  def change
    create_table :observations do |t|
      t.string :time
      t.json :data

      t.timestamps
    end
  end
end
