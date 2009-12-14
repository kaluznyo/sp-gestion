class Convocation < ActiveRecord::Base
  
  belongs_to :station
  belongs_to :uniform
  has_many :convocation_firemen, :dependent => :destroy, :order => 'convocation_firemen.grade DESC'
  has_many :firemen, :through => :convocation_firemen
  
  validates_presence_of :title, :message => "Le titre est obligatoire."
  validates_presence_of :date, :message => "La date est obligatoire."
  validates_presence_of :place, :message => "Le lieu est obligatoire."
  validates_presence_of :uniform, :message => "La tenue est obligatoire."
  validates_presence_of :firemen, :message => "Les personnes convoquées sont obligatoires."
  
  named_scope :lastfive,  lambda { |limit|
    {:order => "created_at DESC", :limit => limit}
  }
    
  def validate
    self.errors.add(:date, "Ne peut pas être dans le passé !") if !editable?
  end
  
  def editable?
    !(self.date.blank?) and (self.date > Time.now)
  end
    
end
