class SurveyDecorator < Tramway::BaseDecorator
  delegate_attributes :title

  association :questions
  
  class << self
    def index_attributes
      [:title]
    end
  end

  def show_associations
    [:questions]
  end
end
