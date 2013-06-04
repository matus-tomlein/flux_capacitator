class ChangedBlock < ActiveRecord::Base
  belongs_to :update

  CHANGE_TYPES = { no_change: 0, added: 1, removed: 2, moved: 3 }

  def change_type
    CHANGE_TYPES.key(read_attribute(:change_type))
  end

  def change_type=(t)
    write_attribute(:change_type, CHANGE_TYPES[t])
  end
end
