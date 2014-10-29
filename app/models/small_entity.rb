class SmallEntity < ActiveHash::Base
  self.data = [
    {
      id: 1,
      name: "Businesses",
    },
    {
      id: 2,
      name: "Governmental Jurisdictions"
    },
    {
      id: 3,
      name: "Organizations"
    }
  ]
end
