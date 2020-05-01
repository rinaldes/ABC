class BankAccount < ActiveRecord::Base
  validates :name, :presence => {:message => 'harus diisi'}
  validates :account_number, :presence => {:message => 'harus diisi'}
  validates :bank_name, :presence => {:message => 'harus diisi'}
  validates :branch, :presence => {:message => 'harus diisi'}
  validates :city, :presence => {:message => 'harus diisi'}
  validates_format_of :name, :with => /^[a-zA-Z\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :account_number, :with => /^[a-zA-Z\d\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :bank_name, :with => /^[a-zA-Z\d\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :branch, :with => /^[a-zA-Z\d\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :city, :with => /^[a-zA-Z\s]*$/i,:multiline => true, :message => "hanya mengijinkan input alphabet"

end