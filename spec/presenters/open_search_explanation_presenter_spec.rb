require "spec_helper"

describe OpenSearchExplanationPresenter, es: true do

  it "provides a high level summary of the scoring" do
    example_open_search_explanation_json = {
      "value": 23.570526,
      "description": "function score, product of:",
      "details": [
        {
          "value": 23.942554,
          "description": "sum of:",
          "details": [
            {
              "value": 1,
              "description": "ConstantScore(*:*)",
              "details": []
            },
            {
              "value": 22.926174,
              "description": "script score function, computed with script:\"Script{type=inline, lang='painless', idOrCode='_score * 1.7', options={}, params={}}\"",
              "details": [
                {
                  "value": 13.485985,
                  "description": "_score: ",
                  "details": [
                    {
                      "value": 13.485985,
                      "description": "sum of:",
                      "details": [
                        {
                          "value": 5.9250984,
                          "description": "weight(full_text:test in 71) [PerFieldSimilarity], result of:",
                          "details": [
                            {
                              "value": 5.9250984,
                              "description": "score(freq=11.0), computed as boost * idf * tf from:",
                              "details": [
                                {
                                  "value": 2.75,
                                  "description": "boost",
                                  "details": []
                                },
                                {
                                  "value": 2.3025851,
                                  "description": "idf, computed as log(1 + (N - n + 0.5) / (n + 0.5)) from:",
                                  "details": [
                                    {
                                      "value": 11,
                                      "description": "n, number of documents containing term",
                                      "details": []
                                    },
                                    {
                                      "value": 114,
                                      "description": "N, total number of documents with field",
                                      "details": []
                                    }
                                  ]
                                },
                                {
                                  "value": 0.9357227,
                                  "description": "tf, computed as freq / (freq + k1 * (1 - b + b * dl / avgdl)) from:",
                                  "details": [
                                    {
                                      "value": 11,
                                      "description": "freq, occurrences of term within document",
                                      "details": []
                                    },
                                    {
                                      "value": 1.2,
                                      "description": "k1, term saturation parameter",
                                      "details": []
                                    },
                                    {
                                      "value": 0.75,
                                      "description": "b, length normalization parameter",
                                      "details": []
                                    },
                                    {
                                      "value": 856,
                                      "description": "dl, length of field (approximate)",
                                      "details": []
                                    },
                                    {
                                      "value": 1690.886,
                                      "description": "avgdl, average length of field",
                                      "details": []
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        },
                        {
                          "value": 7.5608864,
                          "description": "weight(abstract:test in 71) [PerFieldSimilarity], result of:",
                          "details": [
                            {
                              "value": 7.5608864,
                              "description": "score(freq=1.0), computed as boost * idf * tf from:",
                              "details": [
                                {
                                  "value": 4.4,
                                  "description": "boost",
                                  "details": []
                                },
                                {
                                  "value": 4.060443,
                                  "description": "idf, computed as log(1 + (N - n + 0.5) / (n + 0.5)) from:",
                                  "details": [
                                    {
                                      "value": 1,
                                      "description": "n, number of documents containing term",
                                      "details": []
                                    },
                                    {
                                      "value": 86,
                                      "description": "N, total number of documents with field",
                                      "details": []
                                    }
                                  ]
                                },
                                {
                                  "value": 0.4232009,
                                  "description": "tf, computed as freq / (freq + k1 * (1 - b + b * dl / avgdl)) from:",
                                  "details": [
                                    {
                                      "value": 1,
                                      "description": "freq, occurrences of term within document",
                                      "details": []
                                    },
                                    {
                                      "value": 1.2,
                                      "description": "k1, term saturation parameter",
                                      "details": []
                                    },
                                    {
                                      "value": 0.75,
                                      "description": "b, length normalization parameter",
                                      "details": []
                                    },
                                    {
                                      "value": 60,
                                      "description": "dl, length of field (approximate)",
                                      "details": []
                                    },
                                    {
                                      "value": 50.802326,
                                      "description": "avgdl, average length of field",
                                      "details": []
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "value": 0.016379423,
              "description": "script score function, computed with script:\"Script{type=inline, lang='painless', idOrCode='_score * 1.5', options={}, params={}}\"",
              "details": [
                {
                  "value": 0.010919616,
                  "description": "_score: ",
                  "details": [
                    {
                      "value": 0.010919616,
                      "description": "within top 20",
                      "details": []
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "value": 0.9844616,
          "description": "min of:",
          "details": [
            {
              "value": 0.9844616,
              "description": "Function for field publication_date:",
              "details": [
                {
                  "value": 0.9844616,
                  "description": "exp(-0.5*pow(MIN[Math.max(Math.abs(1.7064864E12(=doc value) - 1.713818582102E12(=origin))) - 2.592E9(=offset), 0)],2.0)/7.173940282037916E20)",
                  "details": []
                }
              ]
            },
            {
              "value": 3.4028235e+38,
              "description": "maxBoost",
              "details": []
            }
          ]
        }
      ]
    }

    result = OpenSearchExplanationPresenter.new(example_open_search_explanation_json).summary
    expect(result).to eq("(1 + 22.926174 + 0.016379423 ) * 0.9844616")
  end

end
