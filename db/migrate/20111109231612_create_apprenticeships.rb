class CreateApprenticeships < ActiveRecord::Migration
  def change
    create_table :apprenticeships do |t|
      t.integer :student_id
      t.integer :mentor_id

      t.timestamps
    end
  end
end
