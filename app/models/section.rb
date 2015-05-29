class Section < ActiveHash::Base
   self.data = [
    {id: 1, title: 'Money', slug: 'money', icon: 'Coins-dollaralt'},
    {id: 2, title: 'Environment', slug: 'environment', icon: 'Eco'},
    {id: 3, title: 'World', slug: 'world', icon: 'globe'},
    {id: 4, title: 'Science and Technology', slug: 'science-and-technology', icon: 'Lab'},
    {id: 5, title: 'Business and Industry', slug: 'business-and-industry', icon: 'Factory'},
    {id: 6, title: 'Health and Public Welfare', slug: 'health-and-public-welfare', icon: 'Medicine'},
   ]

  def self.slugs
    all.map{|s| s.slug}
  end

  def to_param
    slug
  end
end
