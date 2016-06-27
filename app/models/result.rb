class Result < ActiveRecord::Base
    
    validates :text, uniqueness: true
end
