class SettingPointMember < ActiveRecord::Base
  validates :point, presence: {:message => 'harus diisi'}
  validates :price, presence: {:message => 'harus diisi'}
  has_many :members, :through => :point_members #join table
  has_many :point_members
end
