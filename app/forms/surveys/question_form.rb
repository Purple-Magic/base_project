class Surveys::QuestionForm < Tramway::BaseForm
  properties :text, :question_type

  fields text: :text,
    question_type: {
      type: :select,
      collection: Surveys::Question.question_type.values.map { [it, it] }
    }
end
