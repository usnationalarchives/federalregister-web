class Folder < ApplicationModel
  has_many :clippings
  belongs_to :user, :foreign_key => :creator_id 

  validates_presence_of :name

  before_save :generate_slug

  def to_param
    slug
  end

  def self.find_by_user_and_slug(user, slug)
    scoped(:conditions => {:creator_id => user.id, :slug => slug}).first
  end


  private

  def generate_slug
    clean_name = name.downcase.gsub(/[^a-z0-9& -]+/,'').gsub(/&/, 'and')
    slug = view_helper.truncate_words(clean_name, :length => 100, :omission => '')
    self.slug = slug.gsub(/ /,'-')
  end
end
