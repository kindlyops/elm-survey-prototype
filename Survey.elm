module Survey
    exposing
        ( IpsativeServerQuestion
        , Survey(Ipsative, Likert)
        , IpsativeSurvey
        , LikertSurvey
        , IpsativeMetaData
        , IpsativeQuestion
        , LikertQuestion
        , PointsLeft
        , IpsativeAnswer
        , IpsativeServerAnswer
        , PointsAssigned
        , emptyIpsativeQuestion
        , emptyAnswer
        , emptyPointsLeft
        , emptyPointsAssigned
        , createIpsativeSurvey
        , createLikertSurvey
        , surveyDataQuestionsMapped
        , createPointsLeft
        , createAnswers
        , createPointsAssigned
        , LikertServerQuestion
        , LikertMetaData
        )

import List.Zipper as Zipper exposing (..)


type Survey
    = Ipsative IpsativeSurvey
    | Likert LikertSurvey


type alias IpsativeSurvey =
    { metaData : IpsativeMetaData
    , pointsPerQuestion : Int
    , numGroups : Int
    , questions : Zipper IpsativeQuestion
    }


type alias IpsativeMetaData =
    { name : String
    , description : String
    , instructions : String
    , lastUpdated : String
    , createdBy : String
    }


type alias IpsativeQuestion =
    { id : Int
    , title : String
    , pointsLeft : List PointsLeft
    , answers : List IpsativeAnswer
    }


type alias IpsativeAnswer =
    { id : Int
    , answer : String
    , category : String
    , pointsAssigned : List PointsAssigned
    }


type alias IpsativeServerQuestion =
    { id : Int
    , title : String
    , answers : List IpsativeServerAnswer
    }


type alias IpsativeServerAnswer =
    { id : Int
    , category : String
    , answer : String
    }


type alias PointsLeft =
    { group : Int
    , pointsLeft : Int
    }


type alias PointsAssigned =
    { group : Int
    , points : Int
    }


type alias LikertSurvey =
    { metaData : LikertMetaData
    , questions : Zipper LikertQuestion
    }


type alias LikertMetaData =
    { name : String
    , choices : List String
    , instructions : String
    , createdBy : String
    , description : String
    , lastUpdated : String
    }


type alias LikertQuestion =
    { id : Int
    , title : String
    , answers : List LikertAnswer
    }


type alias LikertServerQuestion =
    { title : String
    , id : Int
    , answers : List LikertAnswer
    }


type alias LikertAnswer =
    { id : Int
    , answer : String
    }


emptyLikertQuestion : LikertQuestion
emptyLikertQuestion =
    { id = 0
    , title = "UNKNOWN"
    , answers = [ emptyLikertAnswer ]
    }


emptyLikertAnswer : LikertAnswer
emptyLikertAnswer =
    { id = 0
    , answer = ""
    }


emptyIpsativeQuestion : IpsativeQuestion
emptyIpsativeQuestion =
    { id = 0
    , title = "UNKNOWN"
    , pointsLeft = [ emptyPointsLeft ]
    , answers =
        [ emptyAnswer
        ]
    }


emptyAnswer : IpsativeAnswer
emptyAnswer =
    { id = 0
    , answer = "EMPTY QUESTION"
    , category = "EMPTY CATEGORY"
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


createIpsativeSurvey : Int -> Int -> IpsativeMetaData -> List IpsativeServerQuestion -> Survey
createIpsativeSurvey pointsPerQuestion numGroups metaData questions =
    Ipsative
        { metaData = metaData
        , pointsPerQuestion = pointsPerQuestion
        , numGroups = numGroups
        , questions =
            Zipper.fromList (surveyDataQuestionsMapped questions numGroups pointsPerQuestion)
                |> Zipper.withDefault emptyIpsativeQuestion
        }


createLikertSurvey : LikertMetaData -> List LikertServerQuestion -> Survey
createLikertSurvey metaData questions =
    Likert
        { metaData = metaData
        , questions = Zipper.fromList questions |> Zipper.withDefault emptyLikertQuestion
        }


surveyDataQuestionsMapped : List IpsativeServerQuestion -> Int -> Int -> List IpsativeQuestion
surveyDataQuestionsMapped scdsQuestions numGroups numPointsPerQuestion =
    List.map
        (\x ->
            { id = x.id
            , title = x.title
            , pointsLeft = createPointsLeft numGroups numPointsPerQuestion
            , answers = createAnswers x.answers numGroups
            }
        )
        scdsQuestions


createPointsLeft : Int -> Int -> List PointsLeft
createPointsLeft numGroups numPointsPerQuestion =
    List.map
        (\x ->
            { group = x
            , pointsLeft = numPointsPerQuestion
            }
        )
        (List.range 1 numGroups)


createAnswers : List IpsativeServerAnswer -> Int -> List IpsativeAnswer
createAnswers serverAnswers numGroups =
    List.map
        (\x ->
            { id = x.id
            , answer = x.answer
            , category = x.category
            , pointsAssigned = createPointsAssigned numGroups
            }
        )
        serverAnswers


createPointsAssigned : Int -> List PointsAssigned
createPointsAssigned numGroups =
    List.map
        (\x ->
            { group = x
            , points = 0
            }
        )
        (List.range 1 numGroups)
