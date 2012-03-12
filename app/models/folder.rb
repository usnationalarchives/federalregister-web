class Folder < ApplicationModel
  stampable

  has_many :clippings
  belongs_to :user, :foreign_key => :creator_id 

  validates_presence_of :name, :message => "Folder name must not be blank"
  validates_uniqueness_of :name, :scope => :creator_id
  validate :slug_is_not_reserved

  before_validation :generate_slug

  def self.for_current_user
    scoped(:conditions => {:creator_id => User.stamper}).all
  end

  def to_param
    slug
  end

  def self.find_by_user_and_slug(user, slug)
    scoped(:conditions => {:creator_id => user.id, :slug => slug}).first
  end

  def document_numbers
    clippings.map{|c| c.document_number}
  end
  private

  def generate_slug
    clean_name = name.downcase.gsub(/[^a-z0-9& -]+/,'').gsub(/&/, 'and')
    slug = view_helper.truncate_words(clean_name, :length => 100, :omission => '')
    self.slug = slug.gsub(/ /,'-')
  end

  def slug_is_not_reserved
    if self.slug == "my-clippings"
      errors.add(:base, "Sorry, a folder can not be named 'My Clippings'")
      return false
    else
      return true
    end
  end
end
