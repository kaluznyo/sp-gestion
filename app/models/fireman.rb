class Fireman < ActiveRecord::Base

  belongs_to :station
  has_many :grades, -> { order 'kind DESC' }, :dependent => :delete_all
  has_many :convocation_firemen
  has_many :convocations, -> { order 'date DESC' }, :through => :convocation_firemen
  has_many :fireman_interventions
  has_many :interventions, :through => :fireman_interventions
  has_many :fireman_trainings
  has_many :trainings, :through => :fireman_trainings
  has_many :fireman_availabilities, :dependent => :delete_all

  accepts_nested_attributes_for :grades

  mount_uploader :passeport_photo, PasseportPhotoUploader

  validates_presence_of :firstname, :message => "Le prénom est obligatoire."
  validates_presence_of :lastname, :message => "Le nom est obligatoire."
  validates_presence_of :status
  validates_date :birthday, :allow_blank => true, :on_or_before => :today
  validates_date :incorporation_date, :allow_blank => true, :on_or_before => :today
  validates_date :resignation_date, :allow_blank => true, :after => :incorporation_date
  validates_date :checkup, :allow_blank => true
  validates_date :checkup_truck, :allow_blank => true
  validates_format_of :email, :with => Authlogic::Regex.email, :message => "L'adresse email est mal formée.", :allow_blank => true
  validates_length_of :email, :within => 6..100, :message => "L'adresse email doit avoir au minimum 6 caractères.", :allow_blank => true
  validates_with FiremanValidator

  attr_accessor :validate_grade_update
  attr_reader :warnings

  before_save :denormalize_grade
  before_save :warn_if_resignation_date_changed
  before_destroy :check_associations

  acts_as_taggable_on :tags

  STATUS = {
    'JSP' => 1,
    'Vétéran' => 2,
    'Actif' => 3
  }.freeze

  STATUS_PLURAL = {
    'JSP' => 1,
    'Vétérans' => 2,
    'Actifs' => 3
  }

  scope :order_by_grade_and_lastname, -> { order('firemen.grade DESC, firemen.lastname ASC') }
  scope :not_resigned, -> { where("COALESCE(firemen.resignation_date, '') = ''") }
  scope :resigned, -> { where("COALESCE(firemen.resignation_date, '') <> ''") }
  scope :active, -> { where(:status => Fireman::STATUS['Actif']) }
  scope :by_grade, -> (grade) { where(:grade_category => grade) }
  scope :by_training, -> (training) {
    joins(:fireman_trainings)
    .where('training_id = ?', training)
  }

  def initialize(params = nil, *args)
    super
    self.status ||= 3
    self.grades = Grade.new_defaults() if self.grades.length != Grade::GRADE.length
    @warnings = ""
  end

  def years_stats
    result = ActiveRecord::Base.connection.select_all(<<-eos % [self.id, self.id])
      SELECT DISTINCT(year) AS year
      FROM
      (
        SELECT DISTINCT(YEAR(interventions.start_date)) AS year
        FROM firemen
        INNER JOIN fireman_interventions ON fireman_interventions.fireman_id = firemen.id
        INNER JOIN interventions ON interventions.id = fireman_interventions.intervention_id
        WHERE firemen.id = %s

        UNION ALL

        SELECT DISTINCT(YEAR(convocations.date)) AS year
        FROM firemen
        INNER JOIN convocation_firemen ON (convocation_firemen.fireman_id = firemen.id)
        INNER JOIN convocations ON (convocations.id = convocation_firemen.convocation_id)
        WHERE firemen.id = %s
      ) VIEW
      ORDER BY year DESC
    eos
    result.each { |line| line.symbolize_keys! }
    result.map { |line| line[:year] }
  end

  def current_grade
    self.grades.each do |grade|
      return grade if (!grade.date.blank?) and (grade.date <= Date.today)
    end
    return nil
  end

  def max_grade_date
    result = self.grades.collect { |grade| grade.date }.compact.max
    result.to_date unless result == nil
  end

  def stats_interventions(year)
    data = FiremanIntervention.joins(:intervention) \
                              .where('YEAR(interventions.start_date) = ?', year) \
                              .where(:fireman_id => self.id) \
                              .pluck('COALESCE(SUM(TIMESTAMPDIFF(MINUTE, start_date, end_date)), 0) AS duration, COUNT(*) AS total')

    result = {:duration => data[0][0],
              :sum    => data[0][1]}
  end

  def stats_interventions_by_role(year)
    data = FiremanIntervention.joins(:intervention) \
                              .joins(:intervention_role) \
                              .where("YEAR(interventions.start_date) = ?", year) \
                              .where(:fireman_id => self.id) \
                              .group('intervention_roles.name') \
                              .count

    sum = data.inject(0) { |sum, stat| sum ? sum+stat[1] : stat[1] }
    result = {:data => data,
              :sum  => sum}
  end

  def stats_interventions_by_hour(year)
    data = FiremanIntervention.joins(:intervention) \
                                .select("HOUR(CONVERT_TZ(start_date, '+00:00', '#{Time.zone.formatted_offset}')) AS hour, COUNT(interventions.id) AS count") \
                                .where("YEAR(interventions.start_date) = ?", year) \
                                .where(:fireman_id => self.id) \
                                .group('hour') \
                                .collect { |i| [i[:hour], i[:count].to_i] }
    data = Hash[*(0..23).to_a.zip(Array.new(24, 0)).flatten].merge(Hash[data])
    data.sort { |result_a, result_b| result_a[0].to_i <=> result_b[0].to_i }.map{ |hour, number| number }
    sum = data.inject(0) { |sum, stat| sum ? sum+stat[1] : stat[1] }
    result = {:data => data,
              :sum  => sum}
  end

  def stats_convocations(year)
    result = ConvocationFireman.select("COUNT(*) AS total,
                                        COALESCE(SUM(IF(presence = 0,1,0)),0) AS missings,
                                        COALESCE(SUM(IF(presence = 1,1,0)),0) as presents") \
                               .joins(:convocation) \
                               .where("YEAR(convocations.date) = ?", year) \
                               .where(:fireman_id => self.id) \
                               .first

    if result[:total].to_i > 0
      ratio = (result[:presents].to_i*100)/result[:total].to_i
    else
      ratio = 0
    end
    result = {:total => result[:total].to_i,
              :presents => result[:presents].to_i,
              :missings => result[:missings].to_i,
              :ratio => ratio.to_i}
  end

  def self.distinct_tags(station)
    result = Fireman.not_resigned
                    .select("DISTINCT(tags.name) AS name") \
                    .joins("INNER JOIN taggings ON firemen.id = taggings.taggable_id AND taggings.taggable_type = 'Fireman'") \
                    .joins("INNER JOIN tags ON taggings.tag_id = tags.id") \
                    .where(:station_id => station.id) \
                    .order('tags.name')
    result.to_a.map! { |tag| tag.name }
  end

  private

  def check_associations
    unless self.convocations.empty?
      self.errors[:base] << "Impossible de supprimer cette personne car elle possède des convocations." and return false
    end
    unless self.interventions.empty?
      self.errors[:base] << "Impossible de supprimer cette personne car elle a effectué des interventions." and return false
    end
    unless self.trainings.empty?
      self.errors[:base] << "Impossible de supprimer cette personne car elle a effectué des formations." and return false
    end
  end

  def denormalize_grade
    self.grade = current_grade.nil? ? nil : current_grade.kind
    self.grade_category = Grade::GRADE_CATEGORY_MATCH[self.grade]
  end

  def warn_if_resignation_date_changed
    if self.resignation_date_changed?
      @warnings = "Attention, cette personne est désormais dans la liste des hommes"
      @warnings += self.resignation_date.blank? ? "." : " radiés."
    end
  end

end
