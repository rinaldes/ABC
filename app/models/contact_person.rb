class ContactPerson < ActiveRecord::Base
  belongs_to :supplier

  after_create :generate_user
  validates_format_of :email, :with => /^[a-zA-Z\d\s@._]*$/i,:multiline => true, :message => "nama email tidak boleh special character"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :multiline => true, :message => "format email harus benar"
  validates :name, :presence => {:message => 'harus diisi'} 
  validates :phone, :presence => {:message => 'harus diisi'}
  validates :pinbb, :presence => {:message => 'harus diisi'}
  validates :email, :presence => {:message => 'harus diisi'}
  validates_format_of :name, :with => /^[a-zA-Z\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :pinbb, :with => /^[a-zA-Z\d\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet dan angka"
 

  def generate_user
    user = User.new first_name: name, last_name: name, gender: "male", birth_place: "hometown", birth_date: Time.now, email: email, status: "active", confirmed_at: Time.now, username: email, password: email, role_id: Role::SUPPLIER
    user.save
    self.update_attributes user_id: user.id
  end
end
