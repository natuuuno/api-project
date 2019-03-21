class CreateTodo < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.integer :user_id
    end
  end
end
