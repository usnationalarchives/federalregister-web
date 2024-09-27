module SuggestionService::CustomPatterns
  CUSTOM_PATTERNS = [
    {
      highlight: "Hazardous Materials Table",
      pattern: /(?:haz).*(?:mat)?.*(?:table)?/i,
      type: "custom",
      hierarchy: {
        title: "49",
        subtitle: "B",
        chapter: "I",
        subchapter: "C",
        part: "172",
        subpart: "B",
        section: "172.101"
      }
    },
    {
      highlight: "General Operating and Flight Rules",
      pattern: /\A\s*FAR\s*\z/i,
      type: "custom",
      hierarchy: {
        title: "14"
      }
    },
    {
      highlight: "Security and Privacy",
      pattern: /(?:HIPAA|HIPPA)/i,
      type: "custom",
      hierarchy: {
        title: "45",
        subtitle: "A",
        subchapter: "C",
        part: "164"
      }
    },
    {
      highlight: "General Administrative Requirements",
      pattern: /(?:HIPAA|HIPPA)/i,
      type: "custom",
      hierarchy: {
        title: "45",
        subtitle: "A",
        subchapter: "C",
        part: "160"
      }
    }
  ]
end
