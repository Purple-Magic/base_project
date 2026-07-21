class CreateSurveysQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :surveys_questions do |t|
      t.bigint :survey_id
      t.string :question_type
      t.string :text

      t.timestamps
    end
  end
end
