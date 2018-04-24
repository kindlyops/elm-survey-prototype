module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Zipper as Zipper exposing (..)
import Ports
import Survey as Survey exposing (..)
import RadarChart exposing (RadarChartConfig, generateIpsativeChart)
import DemoData as DemoData exposing (scdsSurveyData, scdsMetaData, scdsQuestions, forceSurveyData)
import Icons as Icons exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Page
    = Home
    | SurveyInstructions
    | Survey
    | IncompleteSurvey
    | Finished


type alias Model =
    { currentSurvey : Survey.Survey
    , availableSurveys : List Survey.Survey
    , currentPage : Page
    , numberOfGroups : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { currentSurvey = DemoData.forceSurveyData
      , availableSurveys = [ DemoData.scdsSurveyData, DemoData.forceSurveyData ]
      , currentPage = Home
      , numberOfGroups = 2
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | StartLikertSurvey
    | StartIpsativeSurvey
    | BeginLikertSurvey
    | BeginIpsativeSurvey
    | IncrementAnswer IpsativeAnswer Int
    | DecrementAnswer IpsativeAnswer Int
    | NextQuestion
    | PreviousQuestion
    | GoToHome
    | ChangeNumberOfGroups String
    | FinishSurvey
    | GenerateChart
    | SelectLikertAnswer Int String
    | GotoQuestion Survey Int


limitNumberOfGroups : Int -> Int
limitNumberOfGroups input =
    if input < 0 then
        1
    else if input > 3 then
        3
    else
        input


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        SelectLikertAnswer answerNumber choice ->
            let
                newSurvey =
                    case model.currentSurvey of
                        Likert survey ->
                            Likert (selectLikertAnswer survey answerNumber choice)

                        _ ->
                            model.currentSurvey
            in
                { model | currentSurvey = newSurvey } ! []

        GenerateChart ->
            case model.currentSurvey of
                Ipsative survey ->
                    ( model, Ports.radarChart (RadarChart.generateIpsativeChart survey) )

                _ ->
                    model ! []

        ChangeNumberOfGroups number ->
            let
                newNumber =
                    String.toInt number |> Result.toMaybe |> Maybe.withDefault model.numberOfGroups |> limitNumberOfGroups
            in
                { model | numberOfGroups = newNumber } ! []

        GoToHome ->
            { model | currentPage = Home } ! []

        FinishSurvey ->
            if validateSurvey model.currentSurvey then
                { model | currentPage = Finished } ! []
            else
                { model | currentPage = IncompleteSurvey } ! []

        StartLikertSurvey ->
            { model | currentPage = Survey } ! []

        StartIpsativeSurvey ->
            { model | currentPage = Survey } ! []

        BeginLikertSurvey ->
            let
                newModel =
                    { model | currentSurvey = DemoData.forceSurveyData }
            in
                { newModel | currentPage = SurveyInstructions } ! []

        BeginIpsativeSurvey ->
            let
                newSurvey =
                    Survey.createIpsativeSurvey 10 model.numberOfGroups DemoData.scdsMetaData DemoData.scdsQuestions

                newModel =
                    { model | currentSurvey = newSurvey }
            in
                { newModel | currentPage = SurveyInstructions } ! []

        NextQuestion ->
            case model.currentSurvey of
                Ipsative survey ->
                    case Zipper.next survey.questions of
                        Just x ->
                            { model | currentSurvey = Ipsative { survey | questions = x } } ! []

                        _ ->
                            { model | currentSurvey = Ipsative survey } ! []

                Likert survey ->
                    case Zipper.next survey.questions of
                        Just x ->
                            { model | currentSurvey = Likert { survey | questions = x } } ! []

                        _ ->
                            { model | currentSurvey = Likert survey } ! []

        PreviousQuestion ->
            case model.currentSurvey of
                Ipsative survey ->
                    case Zipper.previous survey.questions of
                        Just x ->
                            { model | currentSurvey = Ipsative { survey | questions = x } } ! []

                        _ ->
                            { model | currentSurvey = Ipsative survey } ! []

                Likert survey ->
                    case Zipper.previous survey.questions of
                        Just x ->
                            { model | currentSurvey = Likert { survey | questions = x } } ! []

                        _ ->
                            { model | currentSurvey = Likert survey } ! []

        DecrementAnswer answer groupNumber ->
            --if points for this answer is > 0,
            --then decrement the point in this answer and
            --increment the points left for the group
            let
                newSurvey =
                    case model.currentSurvey of
                        Ipsative survey ->
                            Ipsative (decrementAnswer survey answer groupNumber)

                        _ ->
                            model.currentSurvey
            in
                { model | currentSurvey = newSurvey } ! []

        IncrementAnswer answer groupNumber ->
            --    --if points left in group > 0,
            --then increment the point in the group for
            --this answer and decrement the points assigned for the group
            let
                newSurvey =
                    case model.currentSurvey of
                        Ipsative survey ->
                            Ipsative (incrementAnswer survey answer groupNumber)

                        _ ->
                            model.currentSurvey
            in
                { model | currentSurvey = newSurvey } ! []

        GotoQuestion survey questionNumber ->
            case model.currentSurvey of
                Ipsative survey ->
                    case Zipper.find (\x -> x.id == questionNumber) (Zipper.first survey.questions) of
                        Just x ->
                            { model | currentSurvey = Ipsative { survey | questions = x }, currentPage = Survey } ! []

                        _ ->
                            { model | currentSurvey = Ipsative survey } ! []

                Likert survey ->
                    case Zipper.find (\x -> x.id == questionNumber) (Zipper.first survey.questions) of
                        Just x ->
                            { model | currentSurvey = Likert { survey | questions = x }, currentPage = Survey } ! []

                        _ ->
                            { model | currentSurvey = Likert survey } ! []


validateSurvey : Survey -> Bool
validateSurvey survey =
    if List.length (getIncompleteQuestions survey) == 0 then
        True
    else
        False


getIncompleteQuestions : Survey -> List Int
getIncompleteQuestions survey =
    case survey of
        Ipsative survey ->
            --Survey question is good if all the points for all the groups for all the answers is zero
            List.foldr
                (\question incompleteQuestions ->
                    if validateIpsativeQuestion question then
                        incompleteQuestions
                    else
                        question.id :: incompleteQuestions
                )
                []
                (Zipper.toList survey.questions)

        Likert survey ->
            --Survey question is good if all the answers have a selectedChoice
            List.foldr
                (\question incompleteQuestions ->
                    if validateLikertQuestion question then
                        incompleteQuestions
                    else
                        question.id :: incompleteQuestions
                )
                []
                (Zipper.toList survey.questions)


validateLikertQuestion : LikertQuestion -> Bool
validateLikertQuestion question =
    let
        checkedQuestions =
            List.filterMap
                (\answer ->
                    answer.selectedChoice
                )
                question.answers
    in
        if List.length checkedQuestions == List.length question.answers then
            True
        else
            False


validateIpsativeQuestion : IpsativeQuestion -> Bool
validateIpsativeQuestion question =
    let
        checkedQuestions =
            List.filterMap
                (\pointsLeft ->
                    validatePointsLeft pointsLeft
                )
                question.pointsLeft
    in
        if List.length checkedQuestions == 0 then
            True
        else
            False


validatePointsLeft : PointsLeft -> Maybe Bool
validatePointsLeft pointsLeft =
    if pointsLeft.pointsLeft == 0 then
        Nothing
    else
        Just False


selectLikertAnswer : LikertSurvey -> Int -> String -> LikertSurvey
selectLikertAnswer survey answerNumber choice =
    let
        newQuestions =
            Zipper.mapCurrent
                (\question ->
                    { id = question.id
                    , title = question.title
                    , choices = question.choices
                    , answers =
                        List.map
                            (\answer ->
                                if answer.id == answerNumber then
                                    { answer
                                        | selectedChoice = Just choice
                                    }
                                else
                                    answer
                            )
                            question.answers
                    }
                )
                survey.questions
    in
        { survey | questions = newQuestions }


incrementAnswer : IpsativeSurvey -> IpsativeAnswer -> Int -> IpsativeSurvey
incrementAnswer survey answer groupNumber =
    let
        newQuestions =
            Zipper.mapCurrent
                (\question ->
                    { id = question.id
                    , title = question.title
                    , pointsLeft =
                        List.map
                            (\pointsLeftInGroup ->
                                if pointsLeftInGroup.group == groupNumber then
                                    if pointsLeftInGroup.pointsLeft > 0 then
                                        { group = groupNumber, pointsLeft = pointsLeftInGroup.pointsLeft - 1 }
                                    else
                                        pointsLeftInGroup
                                else
                                    pointsLeftInGroup
                            )
                            question.pointsLeft
                    , answers =
                        List.map
                            (\x ->
                                if x.id == answer.id then
                                    { x
                                        | pointsAssigned =
                                            List.map
                                                (\y ->
                                                    if y.group == groupNumber then
                                                        if isPointsInGroup question.pointsLeft groupNumber then
                                                            { y | points = y.points + 1 }
                                                        else
                                                            y
                                                    else
                                                        y
                                                )
                                                x.pointsAssigned
                                    }
                                else
                                    x
                            )
                            question.answers
                    }
                )
                survey.questions
    in
        { survey | questions = newQuestions }


decrementAnswer : IpsativeSurvey -> IpsativeAnswer -> Int -> IpsativeSurvey
decrementAnswer survey answer groupNumber =
    let
        newQuestions =
            Zipper.mapCurrent
                (\question ->
                    { id = question.id
                    , title = question.title
                    , pointsLeft =
                        List.map
                            (\pointsLeftInGroup ->
                                if pointsLeftInGroup.group == groupNumber then
                                    if isAnswerGreaterThanZero answer groupNumber then
                                        { pointsLeftInGroup | pointsLeft = pointsLeftInGroup.pointsLeft + 1 }
                                    else
                                        pointsLeftInGroup
                                else
                                    pointsLeftInGroup
                            )
                            question.pointsLeft
                    , answers =
                        List.map
                            (\x ->
                                if x.id == answer.id then
                                    { x
                                        | pointsAssigned =
                                            List.map
                                                (\y ->
                                                    if y.group == groupNumber then
                                                        if y.points > 0 then
                                                            { y | points = y.points - 1 }
                                                        else
                                                            y
                                                    else
                                                        y
                                                )
                                                x.pointsAssigned
                                    }
                                else
                                    x
                            )
                            question.answers
                    }
                )
                survey.questions
    in
        { survey | questions = newQuestions }


isAnswerGreaterThanZero answer group =
    let
        filtered =
            List.filter (\x -> x.group == group) answer.pointsAssigned

        first =
            List.head filtered
    in
        case first of
            Just x ->
                if x.points > 0 then
                    True
                else
                    False

            _ ->
                False


isPointsInGroup pointsLeft group =
    let
        filtered =
            List.filter (\x -> x.group == group) pointsLeft

        first =
            List.head filtered
    in
        case first of
            Just x ->
                if x.pointsLeft > 0 then
                    True
                else
                    False

            _ ->
                False


view : Model -> Html.Html Msg
view model =
    div [] [ viewNavbar, viewApp model ]


viewApp : Model -> Html Msg
viewApp model =
    case model.currentPage of
        Home ->
            viewHero model

        SurveyInstructions ->
            viewSurveyInstructions model.currentSurvey

        Survey ->
            viewSurvey model.currentSurvey

        IncompleteSurvey ->
            viewIncomplete model.currentSurvey

        Finished ->
            viewFinished model


viewIncomplete : Survey -> Html Msg
viewIncomplete survey =
    div [ class "container mt-3" ]
        [ div [ class "row" ]
            [ div [ class "jumbotron" ]
                ([ h1 [ class "display-4" ] [ text "Incomplete Survey" ]
                 , p [ class "lead" ] [ text "You haven't answered all of the survey questions fully." ]
                 ]
                    ++ viewIncompleteButtons survey (getIncompleteQuestions survey)
                )
            ]
        ]


viewIncompleteButtons : Survey -> List Int -> List (Html Msg)
viewIncompleteButtons survey questionNumbers =
    List.map
        (\questionNumber ->
            div [ class "my-2" ] [ button [ class "btn btn-primary", onClick (GotoQuestion survey questionNumber) ] [ text ("Click to go back to question " ++ (toString questionNumber)) ] ]
        )
        questionNumbers


viewSurveyInstructions : Survey -> Html Msg
viewSurveyInstructions survey =
    case survey of
        Ipsative survey ->
            viewIpsativeSurveyInstructions survey

        Likert survey ->
            viewLikertSurveyInstructions survey


viewIpsativeSurveyInstructions : IpsativeSurvey -> Html Msg
viewIpsativeSurveyInstructions survey =
    div [ class "container mt-3" ]
        [ div [ class "row" ]
            [ div
                [ class "jumbotron" ]
                [ h1 [ class "display-4" ] [ text survey.metaData.name ]
                , p [ class "lead" ] [ text survey.metaData.instructions ]
                , hr [ class "my-4" ] []
                , button [ class "btn btn-primary", onClick StartIpsativeSurvey ] [ text "Begin" ]
                ]
            ]
        ]


viewLikertSurveyInstructions : LikertSurvey -> Html Msg
viewLikertSurveyInstructions survey =
    div [ class "container mt-3" ]
        [ div [ class "row" ]
            [ div
                [ class "jumbotron" ]
                [ h1 [ class "display-4" ] [ text survey.metaData.name ]
                , p [ class "lead" ] [ text survey.metaData.instructions ]
                , hr [ class "my-4" ] []
                , button [ class "btn btn-primary", onClick StartLikertSurvey ] [ text "Begin" ]
                ]
            ]
        ]


viewHero : Model -> Html Msg
viewHero model =
    div [ class "jumbotron" ]
        [ h1 [ class "display-4" ] [ text "KindlyOps Haven Survey Prototype" ]
        , p [ class "lead" ] [ text "Welcome to the Elm Haven Survey Prototype. " ]
        , hr [ class "my-4" ] []
        , p [ class "" ] [ text ("There are currently " ++ (toString (List.length model.availableSurveys)) ++ " surveys to choose from.") ]
        , div [ class "row" ]
            (List.map
                (\survey ->
                    case survey of
                        Ipsative survey ->
                            div [ class "col-sm" ]
                                [ viewScdsCard survey model.numberOfGroups
                                ]

                        Likert survey ->
                            div [ class "col-sm" ]
                                [ viewForceCard survey
                                ]
                )
                model.availableSurveys
            )
        ]


viewForceCard : LikertSurvey -> Html Msg
viewForceCard survey =
    div [ class "card" ]
        [ div [ class "card-header" ] [ text "Likert" ]
        , div [ class "card-body" ]
            [ h5 [ class "card-title" ]
                [ text survey.metaData.name
                ]
            , p [ class "card-text" ] [ text survey.metaData.description ]
            ]
        , ul [ class "list-group list-group-flush" ]
            [ li [ class "list-group-item" ] [ text ("Last Updated: " ++ survey.metaData.lastUpdated) ]
            , li [ class "list-group-item" ] [ text ("Created By: " ++ survey.metaData.createdBy) ]
            , li [ class "list-group-item" ] [ button [ class "btn btn-primary", onClick BeginLikertSurvey ] [ text "Click to start survey" ] ]
            ]
        ]


viewScdsCard : IpsativeSurvey -> Int -> Html Msg
viewScdsCard survey numberOfGroups =
    div [ class "card" ]
        [ div [ class "card-header" ] [ text "Ipsative" ]
        , div [ class "card-body" ]
            [ h5 [ class "card-title" ]
                [ text survey.metaData.name
                ]
            , p [ class "card-text" ] [ text survey.metaData.description ]
            ]
        , ul [ class "list-group list-group-flush" ]
            [ li [ class "list-group-item" ] [ text ("Last Updated: " ++ survey.metaData.lastUpdated) ]
            , li [ class "list-group-item" ] [ text ("Created By: " ++ survey.metaData.createdBy) ]
            , li [ class "list-group-item" ]
                [ label [] [ text "Number of Groups" ]
                , input
                    [ type_ "number"
                    , class "form-control form-control-sm"
                    , onInput ChangeNumberOfGroups
                    , Html.Attributes.value (toString numberOfGroups)
                    ]
                    []
                ]
            , li [ class "list-group-item" ] [ button [ class "btn btn-primary", onClick BeginIpsativeSurvey ] [ text ("Click to Start Survey with " ++ (toString numberOfGroups) ++ " Groups") ] ]
            ]
        ]


viewFinished : Model -> Html Msg
viewFinished model =
    case model.currentSurvey of
        Ipsative survey ->
            div [ class "container mt-3" ]
                [ div [ class "row" ]
                    [ div [ class "jumbotron" ]
                        [ h1 [ class "display-4" ] [ text "You finished the survey!" ]
                        , button [ class "btn btn-primary", onClick GenerateChart ] [ text "Click to generate radar chart of results." ]
                        , canvas [ id "chart" ] []
                        ]
                    ]
                ]

        Likert survey ->
            div [] [ text "You finished the survey!" ]


viewSurvey : Survey -> Html Msg
viewSurvey survey =
    case survey of
        Ipsative survey ->
            viewIpsativeSurvey survey

        Likert survey ->
            viewLikertSurvey survey


viewLikertSurvey : LikertSurvey -> Html Msg
viewLikertSurvey survey =
    div [ class "container-fluid" ]
        [ viewLikertSurveyTitle survey
        , br [] []
        , viewLikertSurveyTable (Zipper.current survey.questions)
        , br [] []
        , viewSurveyFooter
        ]


viewLikertSurveyTable : LikertQuestion -> Html Msg
viewLikertSurveyTable surveyQuestion =
    div [ class "row" ]
        [ div [ class "col-md" ]
            [ table [ class "table table-bordered table-hover table-sm" ]
                [ viewLikertSurveyTableHeader surveyQuestion
                , viewLikertSurveyTableRows surveyQuestion
                ]
            ]
        ]


viewLikertSurveyTableRows question =
    tbody []
        (List.map
            (\answer ->
                tr [ class "" ]
                    (td [] [ text answer.answer ]
                        :: (List.map
                                (\choice ->
                                    if isLikertSelected answer choice then
                                        td [ class "bg-success text-white text-center", onClick (SelectLikertAnswer answer.id choice) ]
                                            [ Icons.check ]
                                    else
                                        td [ class "", onClick (SelectLikertAnswer answer.id choice) ]
                                            [ div [ class "" ] []
                                            ]
                                )
                                question.choices
                           )
                    )
            )
            question.answers
        )


isLikertSelected : LikertAnswer -> String -> Bool
isLikertSelected answer choice =
    case answer.selectedChoice of
        Just x ->
            if x == choice then
                True
            else
                False

        Nothing ->
            False


viewLikertSurveyTableHeader : LikertQuestion -> Html Msg
viewLikertSurveyTableHeader surveyQuestion =
    thead [ class "thead-light" ]
        [ tr [ class "" ]
            (th [ class " " ] [ text "Statement" ]
                :: (List.map
                        (\choice ->
                            th [ class " " ] [ text choice ]
                        )
                        surveyQuestion.choices
                   )
            )
        ]


viewIpsativeSurvey survey =
    div [ class "container-fluid" ]
        [ viewIpsativeSurveyTitle survey
        , br [] []
        , viewIpsativeSurveyBoxes (Zipper.current survey.questions)
        , br [] []
        , viewSurveyFooter
        ]


viewNavbar : Html Msg
viewNavbar =
    nav [ class "navbar navbar-expand-lg navbar-light bg-light" ]
        [ a [ class "navbar-brand", style [ ( "cursor", "pointer" ) ], onClick GoToHome ]
            [ text "Haven Survey Prototype" ]
        , button [ attribute "aria-controls" "navbarSupportedContent", attribute "aria-expanded" "false", attribute "aria-label" "Toggle navigation", class "navbar-toggler", attribute "data-target" "#navbarSupportedContent", attribute "data-toggle" "collapse", type_ "button" ]
            [ span [ class "navbar-toggler-icon" ]
                []
            ]
        , div [ class "collapse navbar-collapse", id "navbarSupportedContent" ]
            [ ul [ class "navbar-nav mr-auto" ]
                [ li [ class "nav-item active" ]
                    [ a [ class "nav-link", style [ ( "cursor", "pointer" ) ], onClick GoToHome ]
                        [ text "Home "
                        , span [ class "sr-only" ]
                            [ text "(current)" ]
                        ]
                    ]
                , li [ class "nav-item" ]
                    [ a [ class "nav-link", href "https://github.com/kindlyops/elm-survey-prototype" ]
                        [ text "Github" ]
                    ]
                ]
            ]
        ]


viewLikertSurveyTitle : LikertSurvey -> Html Msg
viewLikertSurveyTitle survey =
    let
        currentQuestion =
            Zipper.current survey.questions

        questionNumber =
            currentQuestion.id

        totalQuestions =
            List.length (Zipper.toList survey.questions)

        questionTitle =
            currentQuestion.title
    in
        div [ class "row" ]
            [ div [ class "col-lg ", style [ ( "text-align", "center" ) ] ]
                [ h3 [ class "" ] [ text ("Question " ++ (toString questionNumber) ++ " of " ++ (toString totalQuestions)) ]
                , h4 [] [ text questionTitle ]
                ]
            ]


viewIpsativeSurveyTitle : IpsativeSurvey -> Html Msg
viewIpsativeSurveyTitle survey =
    let
        currentQuestion =
            Zipper.current survey.questions

        questionNumber =
            currentQuestion.id

        totalQuestions =
            List.length (Zipper.toList survey.questions)

        questionTitle =
            currentQuestion.title
    in
        div [ class "row" ]
            [ div [ class "col-lg ", style [ ( "text-align", "center" ) ] ]
                [ h3 [ class "" ] [ text ("Question " ++ (toString questionNumber) ++ " of " ++ (toString totalQuestions)) ]
                , h4 [] [ text questionTitle ]
                , div [ class "row" ] (viewPointsLeft currentQuestion.pointsLeft survey.pointsPerQuestion)
                ]
            ]


viewPointsLeft : List Survey.PointsLeft -> Int -> List (Html Msg)
viewPointsLeft pointsLeft pointsPerQuestion =
    List.map
        (\x ->
            div [ class "col-md" ]
                [ p [] [ text ("Group " ++ (toString x.group) ++ ": " ++ (toString x.pointsLeft) ++ "/" ++ (toString pointsPerQuestion)) ]
                , div [ class "progress" ]
                    [ div [ class "progress-bar bg-primary", style [ (calculateProgressBarPercent x.pointsLeft pointsPerQuestion) ] ] []
                    ]
                ]
        )
        pointsLeft


calculateProgressBarPercent : Int -> Int -> ( String, String )
calculateProgressBarPercent current max =
    let
        percent =
            100 * ((toFloat current) / (toFloat max))

        percentString =
            toString percent ++ "%"
    in
        ( "width", percentString )


viewIpsativeSurveyBoxes : IpsativeQuestion -> Html Msg
viewIpsativeSurveyBoxes surveyQuestion =
    div [ class "row" ]
        (List.map
            (\answer ->
                viewSurveyBox answer
            )
            surveyQuestion.answers
        )


viewSurveyBox : IpsativeAnswer -> Html Msg
viewSurveyBox answer =
    div [ class "col-md-6" ]
        [ div [ class "card mb-4 box-shadow" ]
            [ div [ class "card-body" ]
                [ p [ class "card-text h5 mb-4" ] [ text answer.answer ]
                , ul [ class "list-group list-group-flush" ]
                    (List.map
                        (\group -> viewSurveyPointsGroup answer group)
                        answer.pointsAssigned
                    )
                ]
            ]
        ]


viewSurveyPointsGroup answer group =
    li [ class "list-group-item" ]
        [ div [ class "row" ]
            [ div [ class "col-6" ]
                [ p [ class "card-text" ] [ text ("Group " ++ toString group.group ++ ":") ]
                ]
            , div [ class "col-6 " ]
                [ button [ type_ "button", class "btn btn-outline-primary", onClick (DecrementAnswer answer group.group) ] [ Icons.minus ]
                , span [ class " px-4 align-middle h5 " ] [ text (toString group.points) ]
                , button [ type_ "button", class "btn btn-outline-primary", onClick (IncrementAnswer answer group.group) ] [ Icons.plus ]
                ]
            ]
        ]


viewSurveyFooter : Html Msg
viewSurveyFooter =
    div [ class "row mb-4 pb-4" ]
        [ div [ class "col-md-8" ] []
        , div [ class "col-md-4 " ]
            [ button [ class "btn btn-primary btn-lg mx-1", onClick GoToHome ] [ text "Back" ]
            , button [ class "btn btn-default btn-lg mx-1", onClick PreviousQuestion ] [ text "<" ]
            , button [ class "btn btn-default btn-lg mx-1", onClick NextQuestion ] [ text ">" ]
            , button [ class "btn btn-primary btn-lg mx-1", onClick FinishSurvey ] [ text "Finish" ]
            ]
        ]
