$(document).ready ()->
    new FR2.TopicListFilter(
      '#topic_list',
      {"filterCountTarget": '#topic-count'}
    )

    new FR2.TopicListSorter(
      '#topic_list'
    )
