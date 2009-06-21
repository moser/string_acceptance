class ChildThing < ActiveRecord::Base
  belongs_to :thing
  accepts_string_for :thing
end
