class ReaderAidsPresenter::Base
  SECTIONS = {
    'office-of-the-federal-register-blog'=> {
      title: 'Office of the Federal Register Blog',
      icon_class: 'quote',
      type: 'posts',
      show_authorship: true,
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'using-federalregister-gov' => {
      title: 'Using FederalRegister.Gov',
      icon_class: 'help',
      type: 'pages',
      index_settings: {
        display_count: 6,
        columns: 2
      }
    },
    'understanding-the-federal-register' => {
      title: 'Understanding the Federal Register',
      icon_class: 'lightbulb-active',
      type: 'pages',
      index_settings: {
        display_count: 6,
        columns: 2
      }
    },
    'recent-updates' => {
      title: 'Recent Site Updates',
      icon_class: 'pc',
      type: 'posts',
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'videos-tutorials' => {
      title: 'Videos & Tutorials',
      icon_class: 'movie',
      type: 'pages',
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'developer-tools' => {
      title: 'Developer Tools',
      icon_class: 'tools',
      type: 'pages',
      index_settings: {
        display_count: 3,
        columns: 1
      }
    },
    'policy' => {
      title: 'Policy',
      icon_class: 'legal',
      type: 'pages',
      index_settings: {
        display_count: 6,
        columns: 2
      }
    },
  }

  def sections
    SECTIONS
  end
end
