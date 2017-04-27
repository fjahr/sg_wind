class Observation < ApplicationRecord
  validates :time, uniqueness: true
end
