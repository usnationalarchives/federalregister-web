class SectionSlug < ActiveHash::Base
  self.data = [
      {
        slug: "money",
        title: "Money",
        icon: "Coins-dollaralt"
      },
      {
        slug: "environment",
        title: "Environment",
        icon: "Eco"
      },
      {
        slug: "world",
        title: "World",
        icon: "Globe"
      },
      {
        slug: "science-and-technology",
        title: "Science and Technology",
        icon: "Lab"
      },
      {
        slug: "business-and-industry",
        title: "Business and Industry",
        icon: "Factory"
      },
      {
        slug: "health-and-public-welfare",
        title: "Health and Public Welfare",
        icon: "Medicine"
      }
  ]
end
