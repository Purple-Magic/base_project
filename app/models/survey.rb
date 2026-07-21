class Survey < ApplicationRecord
  has_many :questions, class_name: 'Surveys::Question'
end
