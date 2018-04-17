module Main exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input exposing (..)
import Html
import Ports
import RadarChart exposing (RadarChartConfig, generateIpsativeChart)
import Html.Attributes
import Html.Events
import DemoData as DemoData exposing (scdsSurveyData, scdsMetaData, scdsQuestions, forceSurveyData)
import List.Zipper as Zipper exposing (..)
import Survey as Survey exposing (..)
import StyleSheet exposing (..)


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
    = Instructions
    | Survey
    | Finished


type alias Model =
    { currentSurvey : Survey.Survey
    , availableSurveys : List Survey.Survey
    , currentPage : Page
    , numberOfGroups : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { currentSurvey = DemoData.scdsSurveyData
      , availableSurveys = [ DemoData.scdsSurveyData, DemoData.forceSurveyData ]
      , currentPage = Instructions
      , numberOfGroups = 2
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | StartLikertSurvey
    | StartIpsativeSurvey Int
    | IncrementAnswer IpsativeAnswer Int
    | DecrementAnswer IpsativeAnswer Int
    | NextQuestion
    | PreviousQuestion
    | GoToInstructions
    | ChangeNumberOfGroups String
    | FinishSurvey
    | GenerateChart


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

        GoToInstructions ->
            { model | currentPage = Instructions } ! []

        FinishSurvey ->
            { model | currentPage = Finished } ! []

        StartLikertSurvey ->
            let
                newModel =
                    { model | currentSurvey = DemoData.forceSurveyData }
            in
                { newModel | currentPage = Survey } ! []

        StartIpsativeSurvey numGroups ->
            let
                newSurvey =
                    Survey.createIpsativeSurvey 10 numGroups DemoData.scdsMetaData DemoData.scdsQuestions

                newModel =
                    { model | currentSurvey = newSurvey }
            in
                { newModel | currentPage = Survey } ! []

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
    Element.layout stylesheet <|
        column Main
            []
            [ viewHeader
            , case model.currentPage of
                Instructions ->
                    viewInstructions model

                Survey ->
                    viewSurvey model.currentSurvey

                Finished ->
                    viewFinished model
            ]


viewInstructions : Model -> Element Styles variation Msg
viewInstructions model =
    column None
        [ center, spacing 20, paddingTop 20 ]
        [ h1 None
            []
            (Element.text "Welcome to the Elm Haven Survey Prototype. There are currently 2 surveys to choose from.")
        , wrappedRow None
            [ spacing 10, center ]
            (List.map
                (\survey ->
                    case survey of
                        Ipsative survey ->
                            viewScdsInstructions survey model.numberOfGroups

                        Likert survey ->
                            viewForceInstructions survey
                )
                model.availableSurveys
            )
        ]


viewForceInstructions : LikertSurvey -> Element Styles variation Msg
viewForceInstructions survey =
    column SubQuestionStyle
        [ center, spacing 10, padding 10 ]
        [ h2 None [] (Element.text survey.metaData.name)
        , h2 None [] (Element.text ("Last Updated: " ++ survey.metaData.lastUpdated))
        , h2 None [] (Element.text ("Created By: " ++ survey.metaData.createdBy))
        , button NextButton [ paddingXY 20 10, onClick StartLikertSurvey ] (Element.text "Click to Start Survey")
        ]


viewScdsInstructions : IpsativeSurvey -> Int -> Element Styles variation Msg
viewScdsInstructions survey numberOfGroups =
    column SubQuestionStyle
        [ center, spacing 10, padding 10 ]
        [ h2 None [] (Element.text survey.metaData.name)
        , h2 None [] (Element.text ("Last Updated: " ++ survey.metaData.lastUpdated))
        , h2 None [] (Element.text ("Created By: " ++ survey.metaData.createdBy))
        , row None
            [ spacing 10 ]
            [ Input.text NumberField
                []
                { onChange = ChangeNumberOfGroups
                , value = (toString numberOfGroups)
                , label =
                    Input.placeholder
                        { label = Input.labelAbove (el None [] (Element.text "Number of Groups"))
                        , text = ""
                        }
                , options =
                    []
                }
            , button NextButton [ paddingXY 20 10, onClick (StartIpsativeSurvey numberOfGroups) ] (Element.text ("Click to Start Survey with " ++ (toString numberOfGroups) ++ " Groups"))
            ]
        ]


viewFinished : Model -> Element Styles variation Msg
viewFinished model =
    column None
        [ paddingTop 100, spacing 10, center ]
        [ h1 None [] (Element.text "You finished the survey!")
        , button NextButton [ paddingXY 20 10, onClick GoToInstructions ] (Element.text "Click to Start Over")
        ]


viewFinishedTableHeader =
    Html.tr []
        [ Html.td [] [ Html.text "Question" ]
        , Html.td [] [ Html.text "Answer" ]
        , Html.td [] [ Html.text "Group" ]
        , Html.td [] [ Html.text "Points" ]
        ]


viewFinishedTableRows : Zipper IpsativeQuestion -> List (Html.Html Msg)
viewFinishedTableRows questions =
    let
        outputRows =
            generateOutputRows (Zipper.toList questions)
    in
        viewOutputRows outputRows


type alias OutputRow =
    { question : String
    , answer : String
    , group : String
    , pointsAssigned : String
    }


generateOutputRows : List IpsativeQuestion -> List OutputRow
generateOutputRows questions =
    let
        mapped =
            List.map
                (\question ->
                    List.map
                        (\answer ->
                            List.map
                                (\pointsAssigned ->
                                    { question = question.title
                                    , answer = (toString question.id) ++ "-" ++ (toString answer.id)
                                    , group = (toString pointsAssigned.group)
                                    , pointsAssigned = (toString pointsAssigned.points)
                                    }
                                )
                                answer.pointsAssigned
                        )
                        question.answers
                )
                questions
    in
        mapped |> List.concat |> List.concat


viewOutputRows : List OutputRow -> List (Html.Html Msg)
viewOutputRows outputRows =
    List.map
        (\row ->
            Html.tr []
                [ Html.td [] [ Html.text row.question ]
                , Html.td [] [ Html.text row.answer ]
                , Html.td [] [ Html.text row.group ]
                , Html.td [] [ Html.text row.pointsAssigned ]
                ]
        )
        outputRows


viewSurvey : Survey -> Element Styles variation Msg
viewSurvey survey =
    case survey of
        Ipsative survey ->
            viewIpsativeSurvey survey

        Likert survey ->
            viewLikertSurvey survey


viewLikertSurvey : LikertSurvey -> Element Styles variation Msg
viewLikertSurvey survey =
    column None
        [ spacing 20 ]
        [ viewLikertSurveyTitle survey
        , viewLikertSurveyTable (Zipper.current survey.questions)
        , viewSurveyFooter
        ]


viewLikertSurveyTable : LikertQuestion -> Element Styles variation Msg
viewLikertSurveyTable surveyQuestion =
    table None
        []
        [ [ el None [] (Element.text "Statement")
          , el None [] (Element.text "hey")
          , el None [] (Element.text "hey")
          ]
        , [ el None [] (Element.text "Agree")
          , el None [] (Element.text "hey")
          , el None [] (Element.text "hey")
          ]
        , [ el None [] (Element.text "Disagree")
          , el None [] (Element.text "hey")
          , el None [] (Element.text "hey")
          ]
        ]


viewIpsativeSurvey : IpsativeSurvey -> Element Styles variation Msg
viewIpsativeSurvey survey =
    column None
        [ spacing 20 ]
        [ viewIpsativeSurveyTitle survey
        , viewIpsativeSurveyBoxes (Zipper.current survey.questions)
        , viewSurveyFooter
        ]


viewHeader : Element Styles variation Msg
viewHeader =
    row NavBarStyle
        [ spread, paddingXY 80 20 ]
        [ el Logo [] (Element.text "Elm Haven Survey Prototype")
        , row None
            [ spacing 20, verticalCenter ]
            [ el NavOption [] (Element.text "Instructions")
            , el NavOption [] (Element.text "Github")
            ]
        ]


viewLikertSurveyTitle : LikertSurvey -> Element Styles variation Msg
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
        row None
            [ center, paddingTop 20 ]
            [ column None
                [ spacing 10 ]
                [ el None [] (Element.text ("Question " ++ (toString questionNumber) ++ " of " ++ (toString totalQuestions)))
                , el SurveyQuestionStyle [] (Element.text questionTitle)
                ]
            ]


viewIpsativeSurveyTitle : IpsativeSurvey -> Element Styles variation Msg
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
        row None
            [ center, paddingTop 20 ]
            [ column None
                [ spacing 10 ]
                [ el None [] (Element.text ("Question " ++ (toString questionNumber) ++ " of " ++ (toString totalQuestions)))
                , el SurveyQuestionStyle [] (Element.text questionTitle)
                , row None
                    [ spacing 20 ]
                    (viewPointsLeft currentQuestion.pointsLeft survey.pointsPerQuestion)
                ]
            ]


viewPointsLeft : List Survey.PointsLeft -> Int -> List (Element Styles variation Msg)
viewPointsLeft pointsLeft pointsPerQuestion =
    List.map
        (\x ->
            column None
                []
                [ Element.text ("Group " ++ (toString x.group) ++ ": " ++ (toString x.pointsLeft) ++ "/" ++ (toString pointsPerQuestion))
                , row ProgressBarBackground
                    []
                    [ el ProgressBar [ width (percent (calculateProgressBarPercent x.pointsLeft pointsPerQuestion)), paddingXY 0 10 ] empty ]
                ]
        )
        pointsLeft


calculateProgressBarPercent : Int -> Int -> Float
calculateProgressBarPercent current max =
    100 * ((toFloat current) / (toFloat max))


viewIpsativeSurveyBoxes : IpsativeQuestion -> Element Styles variation Msg
viewIpsativeSurveyBoxes surveyQuestion =
    wrappedRow None
        [ spacing 10, center ]
        (List.map (\x -> viewSurveyBox x) surveyQuestion.answers)


viewSurveyBox : IpsativeAnswer -> Element Styles variation Msg
viewSurveyBox answer =
    el None
        [ width (px 600) ]
        (column
            SubQuestionStyle
            [ paddingBottom 10 ]
            [ textLayout None [ paddingXY 10 10 ] [ paragraph None [] [ (Element.text answer.answer) ] ]
            , column None
                [ center, spacing 20 ]
                (viewAnswerButtons answer answer.pointsAssigned)
            ]
        )


viewAnswerButtons answer pointsAssigned =
    List.map
        (\x ->
            row None
                [ spacing 20 ]
                [ el None [ verticalCenter ] (Element.text ("Group " ++ toString x.group ++ ":"))
                , button SubQuestionButton [ paddingXY 20 10, (onClick (DecrementAnswer answer x.group)) ] (Element.text "-")
                , el None [ verticalCenter ] (Element.text (toString x.points))
                , button SubQuestionButton [ paddingXY 20 10, (onClick (IncrementAnswer answer x.group)) ] (Element.text "+")
                ]
        )
        pointsAssigned


viewSurveyFooter : Element Styles variation Msg
viewSurveyFooter =
    row SurveyFooterStyle
        [ alignRight, spacing 12, paddingRight 40 ]
        [ button SaveButton [ paddingXY 20 10, onClick GoToInstructions ] (Element.text "Back")
        , button NavigationButton [ paddingXY 20 10, onClick PreviousQuestion ] (Element.text "<")
        , button NavigationButton [ paddingXY 20 10, onClick NextQuestion ] (Element.text ">")
        , button NextButton [ paddingXY 20 10, onClick FinishSurvey ] (Element.text "Finish")
        ]
