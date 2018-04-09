module Data exposing (..)

import List.Zipper as Zipper exposing (..)


type alias Survey =
    { metaData : SurveyMetaData
    , pointsPerQuestion : Int
    , numGroups : Int
    , questions : Zipper Question
    }


type alias SurveyMetaData =
    { name : String
    , description : String
    , lastUpdated : String
    , createdBy : String
    }


type alias Question =
    { id : Int
    , title : String
    , pointsLeft : List PointsLeft
    , answers : List Answer
    }


type alias PointsLeft =
    { group : Int
    , pointsLeft : Int
    }


type alias Answer =
    { id : Int
    , answer : String
    , pointsAssigned : List PointsAssigned
    }


type alias PointsAssigned =
    { group : Int
    , points : Int
    }


surveyMetaData =
    { name = "SCDS_1"
    , description = "Survey to identify existing security culture in an organization."
    , lastUpdated = "09/15/2015"
    , createdBy = "Lance Hayden"
    }


emptyQuestion : Question
emptyQuestion =
    { id = 0
    , title = "UNKNOWN"
    , pointsLeft = [ emptyPointsLeft ]
    , answers =
        [ emptyAnswer
        ]
    }


emptyAnswer : Answer
emptyAnswer =
    { id = 0
    , answer = "EMPTY QUESTION"
    , pointsAssigned = [ emptyPointsAssigned ]
    }


emptyPointsLeft : PointsLeft
emptyPointsLeft =
    { group = 1
    , pointsLeft = 10
    }


emptyPointsAssigned : PointsAssigned
emptyPointsAssigned =
    { group = 1
    , points = 1
    }


surveyData : Survey
surveyData =
    createSurvey 10 2 surveyMetaData surveyDataQuestions


createSurvey : Int -> Int -> SurveyMetaData -> List ServerQuestion -> Survey
createSurvey pointsPerQuestion numGroups metaData questions =
    { metaData = metaData
    , pointsPerQuestion = pointsPerQuestion
    , numGroups = numGroups
    , questions =
        Zipper.fromList (surveyDataQuestionsMapped questions numGroups pointsPerQuestion)
            |> Zipper.withDefault emptyQuestion
    }


surveyDataQuestionsMapped : List ServerQuestion -> Int -> Int -> List Question
surveyDataQuestionsMapped surveyDataQuestions numGroups numPointsPerQuestion =
    List.map
        (\x ->
            { id = x.id
            , title = x.title
            , pointsLeft = createPointsLeft numGroups numPointsPerQuestion
            , answers = createAnswers x.answers numGroups
            }
        )
        surveyDataQuestions


createPointsLeft : Int -> Int -> List PointsLeft
createPointsLeft numGroups numPointsPerQuestion =
    List.map
        (\x ->
            { group = x
            , pointsLeft = numPointsPerQuestion
            }
        )
        (List.range 1 numGroups)


createAnswers : List ServerAnswer -> Int -> List Answer
createAnswers serverAnswers numGroups =
    List.map
        (\x ->
            { id = x.id
            , answer = x.answer
            , pointsAssigned = createPointsAssigned numGroups
            }
        )
        serverAnswers


createPointsAssigned : Int -> List PointsAssigned
createPointsAssigned numGroups =
    --[ { group = 1, points = 1 } ]
    List.map
        (\x ->
            { group = x
            , points = 0
            }
        )
        (List.range 1 numGroups)


type alias ServerQuestion =
    { id : Int
    , title : String
    , answers : List ServerAnswer
    }


type alias ServerAnswer =
    { id : Int
    , answer : String
    }


surveyDataQuestions : List ServerQuestion
surveyDataQuestions =
    [ { id = 1
      , title = "What's valued most?"
      , answers =
            [ { id = 1, answer = "Stability and reliability are valued most by the organization. It is critical that everyone knows the rules and follows them. The organization cannot succeed if people are all doing things different ways without centralized visibility." }
            , { id = 2, answer = "Successfully meeting external requirements is valued most by the organization. The organization is under a lot of scrutiny. It cannot succeed if people fail audits or do not live up to the expectations of those watching." }
            , { id = 3, answer = "Adapting quickly and competing aggressively are valued most by the organization. Results are what matters. The organization cannot succeed if bureaucracy and red tape impair people's ability to be agile." }
            , { id = 4, answer = "People and a sense of community are valued most by the organization. Everyone is in it together. The organization cannot succeed unless people are given the opportunities and skills to succeed on their own." }
            ]
      }
    , { id = 2
      , title = "How does the organization work?"
      , answers =
            [ { id = 1, answer = "The organization works on authority, policy, and standard ways of doing things. Organizational charts are formal and important. The organization is designed to ensure control and efficiency." }
            , { id = 2, answer = "The organization works on outside requirements and regular reviews. Audits are a central feature of life. The organization is designed to ensure everyone meets their obligations." }
            , { id = 3, answer = "The organization works on independent action and giving people decision authority. There's no one right way to do things. The organization is designed to ensure that the right things get done in the right situations." }
            , { id = 4, answer = "The organization works on teamwork and cooperation. It is a community. The organization is designed to ensure everyone is constantly learning, growing, and supporting one another." }
            ]
      }
    , { id = 3
      , title = "What does security mean?"
      , answers =
            [ { id = 1, answer = "Security means policies, procedures, and standards, automated wherever possible using technology. When people talk about security they are talking about the infrastructures in place to protect the organization's information assets." }
            , { id = 2, answer = "Security means showing evidence of visibility and control, particularly to external parties. When people talk about security they are talking about passing an audit or meeting a regulatory requirement." }
            , { id = 3, answer = "Security means enabling the organization to adapt and compete, not hindering it or saying “no” to everything. When people talk about security they are talking about balancing risks and rewards." }
            , { id = 4, answer = "Security means awareness and shared responsibility. When people talk about security they are talking about the need for everyone to be an active participant in protecting the organization." }
            ]
      }
    , { id = 4
      , title = "How is information managed and controlled?"
      , answers =
            [ { id = 1, answer = "Information is seen as a direct source of business value, accounted for, managed, and controlled like any other business asset. Formal rules and policies govern information use and control." }
            , { id = 2, answer = "Information is seen as a sensitive and protected resource, entrusted to the organization by others and subject to review and audit. Information use and control must always be documented and verified." }
            , { id = 3, answer = "Information is seen as a flexible tool that is the key to agility and adaptability in the organization's environment. Information must be available where and when it is needed by the business, with a minimum of restrictive control." }
            , { id = 4, answer = "Information is seen as key to people's productivity, collaboration, and success. Information must be a shared resource, minimally restricted, and available throughout the community to empower people and make them more successful." }
            ]
      }
    , { id = 5
      , title = "How are operations managed?"
      , answers =
            [ { id = 1, answer = "Operations are controlled and predictable, managed according to the same standards throughout the organization." }
            , { id = 2, answer = "Operations are visible and verifiable, managed and documented in order to support audits and outside reviews." }
            , { id = 3, answer = "Operations are agile and adaptable, managed with minimal bureaucracy and capable of fast adaptation and flexible execution to respond to changes in the environment." }
            , { id = 4, answer = "Operations are inclusive and supportive, allowing people to master new skills and responsibilities and to grow within the organization." }
            ]
      }
    , { id = 6
      , title = "How is technology managed?"
      , answers =
            [ { id = 1, answer = "Technology is centrally managed. Standards and formal policies exist to ensure uniform performance internally." }
            , { id = 2, answer = "Technology is regularly reviewed. Audits and evaluations exist to ensure the organization meets its obligations to others." }
            , { id = 3, answer = "Technology is locally managed. Freedom exists to ensure innovation, adaptation, and results." }
            , { id = 4, answer = "Technology is accessible to everyone. Training and support exists to empower users and maximize productivity." }
            ]
      }
    , { id = 7
      , title = "How are people managed?"
      , answers =
            [ { id = 1, answer = "People must conform to the needs of the organization. They must adhere to policies and standards of behavior. The success of the organization is built on everyone following the rules." }
            , { id = 2, answer = "People must demonstrate that they are doing things correctly. They must ensure the organization meets its obligations. The success of the organization is built on everyone regularly proving that they are doing things properly." }
            , { id = 3, answer = "People must take risks and make quick decisions. They must not wait for someone else to tell them what's best. The success of the organization is built on everyone experimenting and innovating in the face of change." }
            , { id = 4, answer = "People must work as a team and support one other. They must know that everyone is doing their part. The success of the organization is built on everyone learning and growing together." }
            ]
      }
    , { id = 8
      , title = "How is risk managed?"
      , answers =
            [ { id = 1, answer = "Risk is best managed by getting rid of deviations in the way things are done. Increased visibility and control reduce uncertainty and negative outcomes. The point is to create a reliable standard." }
            , { id = 2, answer = "Risk is best managed by documentation and regular review. Frameworks and evaluations reduce uncertainty and negative outcomes. The point is to keep everyone on their toes." }
            , { id = 3, answer = "Risk is best managed by decentralizing authority. Negative outcomes are always balanced by potential opportunities. The point is to let those closest to the decision make the call." }
            , { id = 4, answer = "Risk is best managed by sharing information and knowledge. Education and support reduce uncertainty and negative outcomes. The point is to foster a sense of shared responsibility." }
            ]
      }
    , { id = 9
      , title = "How is accountability achieved?"
      , answers =
            [ { id = 1, answer = "Accountability is stable and formalized. People know what to expect and what is expected of them. The same rewards and consequences are found throughout the organization." }
            , { id = 2, answer = "Accountability is enabled through review and audit. People know that they will be asked to justify their actions. Rewards and consequences are contingent upon external expectations and judgments." }
            , { id = 3, answer = "Accountability is results-driven. People know there are no excuses for failing. Rewards and consequences are a product of successful execution on the organization's business." }
            , { id = 4, answer = "Accountability is shared among the group. People know there are no rock stars or scapegoats. Rewards and consequences apply to everyone because everyone is a stakeholder in the organization." }
            ]
      }
    , { id = 10
      , title = "How is performance evaluated?"
      , answers =
            [ { id = 1, answer = "Performance is evaluated against formal strategies and goals. Success criteria are unambiguous." }
            , { id = 2, answer = "Performance is evaluated against the organization's ability to meet external requirements. Audits define success." }
            , { id = 3, answer = "Performance is evaluated on the basis of specific decisions and outcomes. Business success is the primary criteria." }
            , { id = 4, answer = "Performance is evaluated by the organizational community. Success is defined through shared values, commitment, and mutual respect." }
            ]
      }
    ]
