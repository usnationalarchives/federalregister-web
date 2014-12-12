class Navigation::AgenciesPresenter
  HIGHLIGHTED_AGENCIES = [
    "Agriculture Deparment",
    "Commerce Department",
    "Defense Department",
    "Education Department",
    "Energy Department",
    "Environmental Protection Agency",
    "Health and Human Services Department",
    "Homeland Security Department",
    "Housing and Urban Development Department",
    "Interior Department",
    "Justice Department",
    "Labor Department",
    "State Department",
    "Transportation Department",
    "Treasury Department",
    "Veterans Affairs Department"
  ]

  def agencies
    @agencies ||= FederalRegister::Agency.
      all.
      select{|a| HIGHLIGHTED_AGENCIES.include?(a.name)}.
      map{|a| AgencyDecorator::Nav.decorate(a)}
  end
end
