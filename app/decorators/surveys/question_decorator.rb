class Surveys::QuestionDecorator < Tramway::BaseDecorator
  delegate_attributes :text

  alias title text

  def show_attributes
    [:text]
  end
end
