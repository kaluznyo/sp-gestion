# -*- encoding : utf-8 -*-
class Message < ActiveRecord::Base

  attr_accessible :title, :body

  belongs_to :user

  scope :unread, where(:read_at => nil)

  def read?
    !self.read_at.blank?
  end

  def read!
    update_attribute(:read_at, Time.now) unless self.read?
  end
end
