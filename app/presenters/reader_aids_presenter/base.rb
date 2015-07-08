class ReaderAidsPresenter::Base
  SECTIONS = {
    'office-of-the-federal-register-blog'=> {
      title: 'Office of the Federal Register Blog',
      icon_class: 'quote',
      type: 'posts',
      show_authorship: true,
    },
    'using-federalregister-gov' => {
      title: 'Using FederalRegister.Gov',
      icon_class: 'help',
      type: 'pages',
    },
    'understanding-the-federal-register' => {
      title: 'Understanding the Federal Register',
      icon_class: 'lightbulb-active',
      type: 'pages',
    },
    'recent-updates' => {
      title: 'Recent Site Updates',
      icon_class: 'pc',
      type: 'posts',
    },
    'videos-tutorials' => {
      title: 'Videos & Tutorials',
      icon_class: 'movie',
      type: 'pages',
    },
    'developer-tools' => {
      title: 'Developer Tools',
      icon_class: 'tools',
      type: 'pages',
    },
  }

  def sections
    SECTIONS
  end
end
