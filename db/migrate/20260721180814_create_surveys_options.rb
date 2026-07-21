class CreateSurveysOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :surveys_options do |t|
      t.bigint :question_id
      t.string :text

      t.timestamps
    end
  end
end
