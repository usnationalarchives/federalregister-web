class Folder < ApplicationRecord
  has_many :clippings

  validates_presence_of :name,
    message: "Folder name must not be blank"

  validates_uniqueness_of :name,
    case_sensitive: true,
    scope: :creator_id,
    message: Proc.new{|e,f| "You have already created a folder named \"#{f[:value]}\"."}

  validate :slug_is_not_reserved

  before_validation :generate_slug

  # used to stub values for serialization when creating a
  # faux 'my-clipboard' folder
  attr_accessor :doc_count, :documents

  def self.my_clipboard
    new(:name => 'My Clipboard', :slug => "my-clippings")
  end

  def to_param
    slug
  end

  def self.find_by_user_and_slug(user, slug)
    where(creator_id: user.id, slug: slug).first
  end

  def document_numbers
    clippings.map{|c| c.document_number}
  end

  def deletable?
    document_numbers.empty?
  end

  def user
    User.find(creator_id)
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
