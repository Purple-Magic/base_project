class Surveys::Question < ApplicationRecord
  enumerize :question_type, in: [:text, :choice]
end
