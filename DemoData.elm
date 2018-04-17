module DemoData
    exposing
        ( scdsSurveyData
        , scdsMetaData
        , scdsQuestions
        , forceSurveyData
        )

import Survey
    exposing
        ( IpsativeSurvey
        , LikertSurvey
        , Survey
        , LikertMetaData
        , LikertServerQuestion
        , IpsativeMetaData
        , IpsativeServerQuestion
        , createIpsativeSurvey
        , createLikertSurvey
        )


scdsSurveyData : Survey
scdsSurveyData =
    createIpsativeSurvey 10 2 scdsMetaData scdsQuestions


forceSurveyData : Survey
forceSurveyData =
    createLikertSurvey forceMetaData forceServerQuestions


forceMetaData : LikertMetaData
forceMetaData =
    { name = "Security FORCE Survey"
    , createdBy = "Lance Hayden"
    , lastUpdated = "09/15/2015"
    , description = "Survey to identify existing security culture in an organization."
    , choices =
        [ "Strongly Disagree"
        , "Disagree"
        , "Neutral"
        , "Agree"
        , "Strongly Agree"
        ]
    , instructions = "To complete this Security FORCE Survey, please indicate your level of agreement with each of the following statements regarding information security values and practices within your organization. Choose one response per statement. Please respond to all statements."
    }


scdsMetaData : IpsativeMetaData
scdsMetaData =
    { name = "SCDS"
    , description = "Survey to identify existing security culture in an organization."
    , lastUpdated = "09/15/2015"
    , instructions = "For each question, assign a total of 10 points, divided among the four statements based on how accurately you think each describes your organization."
    , createdBy = "Lance Hayden"
    }


forceServerQuestions : List LikertServerQuestion
forceServerQuestions =
    [ { title = "Security Value of Failure"
      , id = 1
      , answers =
            [ { id = 1
              , answer = "I feel confident I could predict where the organization’s next security incident will happen."
              }
            , { id = 2
              , answer = "I regularly identify security problems while doing my job."
              }
            , { id = 3
              , answer = "I feel very comfortable reporting security problems up the management chain."
              }
            , { id = 4
              , answer = "I know that security problems I report will be taken seriously."
              }
            , { id = 5
              , answer = "When a security problem is found, it gets fixed."
              }
            ]
      }
    , { title = "Security Value of Operations"
      , id = 2
      , answers =
            [ { id = 1
              , answer = "I know that someone is constantly keeping watch over how secure the organization is."
              }
            , { id = 2
              , answer = "I am confident that information security in the organization actually works the way that people and policies say it does."
              }
            , { id = 3
              , answer = "I feel like there are many experts around the organization willing and able to help me understand how things work."
              }
            , { id = 4
              , answer = "Management and the security team regularly share information about security assessments."
              }
            , { id = 5
              , answer = "Management stays actively involved in security and makes sure appropriate resources are available."
              }
            ]
      }
    , { title = "Security Value of Resilience"
      , id = 3
      , answers =
            [ { id = 1
              , answer = "I feel like people are trained to know more about security than just the minimum level necessary."
              }
            , { id = 2
              , answer = "The organization has reserves of skill and expertise to call on in the event of a security incident or crisis."
              }
            , { id = 3
              , answer = "I feel like everyone in the organization is encouraged to “get out of their comfort zone” and be part of security challenges. "
              }
            , { id = 4
              , answer = "I feel like people are interested in what I know about security, and willing to share their own skills to help me as well."
              }
            , { id = 5
              , answer = "The organization often conducts drills and scenarios to test how well we respond to security incidents and failures."
              }
            ]
      }
    , { title = "Security Value of Complexity"
      , id = 4
      , answers =
            [ { id = 1
              , answer = "I feel like people in the organization prefer complex explanations over simple ones."
              }
            , { id = 2
              , answer = "I feel like people are open to being challenged or questioned about how they arrived at an answer."
              }
            , { id = 3
              , answer = "The organization always has plenty of data to explain and justify its decisions."
              }
            , { id = 4
              , answer = "People from outside the security team are encouraged to participate and question security plans and decisions."
              }
            , { id = 5
              , answer = "The organization formally reviews strategies and predictions to make sure they were accurate, and adjusts accordingly."
              }
            ]
      }
    , { title = "Security Value of Expertise"
      , id = 5
      , answers =
            [ { id = 1
              , answer = "I know exactly where to go in the organization when I need an expert."
              }
            , { id = 2
              , answer = "I think everyone in the organization feels that monitoring security is part of their job."
              }
            , { id = 3
              , answer = "In the event of a security incident, people can legitimately bypass the bureaucracy to get things done."
              }
            , { id = 4
              , answer = "People in the organization are encouraged to help other groups if they have the right skills to help them."
              }
            , { id = 5
              , answer = "I feel empowered to take action myself, if something is about to cause a security failure."
              }
            ]
      }
    ]


scdsQuestions : List IpsativeServerQuestion
scdsQuestions =
    [ { id = 1
      , title = "What's valued most?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Stability and reliability are valued most by the organization. It is critical that everyone knows the rules and follows them. The organization cannot succeed if people are all doing things different ways without centralized visibility."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Successfully meeting external requirements is valued most by the organization. The organization is under a lot of scrutiny. It cannot succeed if people fail audits or do not live up to the expectations of those watching."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Adapting quickly and competing aggressively are valued most by the organization. Results are what matters. The organization cannot succeed if bureaucracy and red tape impair people's ability to be agile."
              }
            , { id = 4
              , category = "Trust"
              , answer = "People and a sense of community are valued most by the organization. Everyone is in it together. The organization cannot succeed unless people are given the opportunities and skills to succeed on their own."
              }
            ]
      }
    , { id = 2
      , title = "How does the organization work?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "The organization works on authority, policy, and standard ways of doing things. Organizational charts are formal and important. The organization is designed to ensure control and efficiency."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "The organization works on outside requirements and regular reviews. Audits are a central feature of life. The organization is designed to ensure everyone meets their obligations."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "The organization works on independent action and giving people decision authority. There's no one right way to do things. The organization is designed to ensure that the right things get done in the right situations."
              }
            , { id = 4
              , category = "Trust"
              , answer = "The organization works on teamwork and cooperation. It is a community. The organization is designed to ensure everyone is constantly learning, growing, and supporting one another."
              }
            ]
      }
    , { id = 3
      , title = "What does security mean?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Security means policies, procedures, and standards, automated wherever possible using technology. When people talk about security they are talking about the infrastructures in place to protect the organization's information assets."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Security means showing evidence of visibility and control, particularly to external parties. When people talk about security they are talking about passing an audit or meeting a regulatory requirement."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Security means enabling the organization to adapt and compete, not hindering it or saying “no” to everything. When people talk about security they are talking about balancing risks and rewards."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Security means awareness and shared responsibility. When people talk about security they are talking about the need for everyone to be an active participant in protecting the organization."
              }
            ]
      }
    , { id = 4
      , title = "How is information managed and controlled?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Information is seen as a direct source of business value, accounted for, managed, and controlled like any other business asset. Formal rules and policies govern information use and control."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Information is seen as a sensitive and protected resource, entrusted to the organization by others and subject to review and audit. Information use and control must always be documented and verified."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Information is seen as a flexible tool that is the key to agility and adaptability in the organization's environment. Information must be available where and when it is needed by the business, with a minimum of restrictive control."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Information is seen as key to people's productivity, collaboration, and success. Information must be a shared resource, minimally restricted, and available throughout the community to empower people and make them more successful."
              }
            ]
      }
    , { id = 5
      , title = "How are operations managed?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Operations are controlled and predictable, managed according to the same standards throughout the organization."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Operations are visible and verifiable, managed and documented in order to support audits and outside reviews."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Operations are agile and adaptable, managed with minimal bureaucracy and capable of fast adaptation and flexible execution to respond to changes in the environment."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Operations are inclusive and supportive, allowing people to master new skills and responsibilities and to grow within the organization."
              }
            ]
      }
    , { id = 6
      , title = "How is technology managed?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Technology is centrally managed. Standards and formal policies exist to ensure uniform performance internally."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Technology is regularly reviewed. Audits and evaluations exist to ensure the organization meets its obligations to others."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Technology is locally managed. Freedom exists to ensure innovation, adaptation, and results."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Technology is accessible to everyone. Training and support exists to empower users and maximize productivity."
              }
            ]
      }
    , { id = 7
      , title = "How are people managed?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "People must conform to the needs of the organization. They must adhere to policies and standards of behavior. The success of the organization is built on everyone following the rules."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "People must demonstrate that they are doing things correctly. They must ensure the organization meets its obligations. The success of the organization is built on everyone regularly proving that they are doing things properly."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "People must take risks and make quick decisions. They must not wait for someone else to tell them what's best. The success of the organization is built on everyone experimenting and innovating in the face of change."
              }
            , { id = 4
              , category = "Trust"
              , answer = "People must work as a team and support one other. They must know that everyone is doing their part. The success of the organization is built on everyone learning and growing together."
              }
            ]
      }
    , { id = 8
      , title = "How is risk managed?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Risk is best managed by getting rid of deviations in the way things are done. Increased visibility and control reduce uncertainty and negative outcomes. The point is to create a reliable standard."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Risk is best managed by documentation and regular review. Frameworks and evaluations reduce uncertainty and negative outcomes. The point is to keep everyone on their toes."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Risk is best managed by decentralizing authority. Negative outcomes are always balanced by potential opportunities. The point is to let those closest to the decision make the call."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Risk is best managed by sharing information and knowledge. Education and support reduce uncertainty and negative outcomes. The point is to foster a sense of shared responsibility."
              }
            ]
      }
    , { id = 9
      , title = "How is accountability achieved?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Accountability is stable and formalized. People know what to expect and what is expected of them. The same rewards and consequences are found throughout the organization."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Accountability is enabled through review and audit. People know that they will be asked to justify their actions. Rewards and consequences are contingent upon external expectations and judgments."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Accountability is results-driven. People know there are no excuses for failing. Rewards and consequences are a product of successful execution on the organization's business."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Accountability is shared among the group. People know there are no rock stars or scapegoats. Rewards and consequences apply to everyone because everyone is a stakeholder in the organization."
              }
            ]
      }
    , { id = 10
      , title = "How is performance evaluated?"
      , answers =
            [ { id = 1
              , category = "Process"
              , answer = "Performance is evaluated against formal strategies and goals. Success criteria are unambiguous."
              }
            , { id = 2
              , category = "Compliance"
              , answer = "Performance is evaluated against the organization's ability to meet external requirements. Audits define success."
              }
            , { id = 3
              , category = "Autonomy"
              , answer = "Performance is evaluated on the basis of specific decisions and outcomes. Business success is the primary criteria."
              }
            , { id = 4
              , category = "Trust"
              , answer = "Performance is evaluated by the organizational community. Success is defined through shared values, commitment, and mutual respect."
              }
            ]
      }
    ]
