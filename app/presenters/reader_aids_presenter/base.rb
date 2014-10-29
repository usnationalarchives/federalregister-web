class ReaderAidsPresenter::Base
  SECTIONS = {
    'office-of-the-federal-register-blog'=> {
      title: 'Office of the Federal Register Blog',
      icon_class: 'icon-fr2-quote',
      type: 'posts',
      show_authorship: true,
    },
    'using-federalregister-gov' => {
      title: 'Using FederalRegister.Gov',
      icon_class: 'icon-fr2-help',
      type: 'pages',
    },
    'understanding-the-federal-register' => {
      title: 'Understanding the Federal Register',
      icon_class: 'icon-fr2-lightbulb-active',
      type: 'pages',
    },
    'recent-updates' => {
      title: 'Recent Site Updates',
      icon_class: 'icon-fr2-pc',
      type: 'posts',
    },
    'videos-tutorials' => {
      title: 'Videos & Tutorials',
      icon_class: 'icon-fr2-movie',
      type: 'pages',
    },
    'developer-tools' => {
      title: 'Developer Tools',
      icon_class: 'icon-fr2-tools',
      type: 'pages',
    },
  }

  def sections
    SECTIONS
  end
end
