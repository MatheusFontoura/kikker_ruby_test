class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :ratings, %i[post_id user_id], unique: true
    add_check_constraint :ratings, 'value BETWEEN 1 AND 5', name: 'rating_value_range'
  end
end
