module Main exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input exposing (..)
import Html
import Ports
import RadarChart exposing (RadarChartConfig, generateChartConfig)
import Html.Attributes
import Html.Events
import List.Zipper as Zipper exposing (..)
import Data as Data exposing (..)
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
    { survey : Data.Survey
    , currentPage : Page
    , numberOfGroups : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { survey = Data.surveyData
      , currentPage = Instructions
      , numberOfGroups = 3
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | StartSurvey
    | StartSurveyWithGroups Int
    | IncrementAnswer Answer Int
    | DecrementAnswer Answer Int
    | NextQuestion
    | PreviousQuestion
    | GoToInstructions
    | ChangeNumberOfGroups String
    | FinishSurvey
    | GenerateChart


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        GenerateChart ->
            ( model, Ports.radarChart (RadarChart.generateChartConfig model.survey) )

        ChangeNumberOfGroups number ->
            let
                newNumber =
                    String.toInt number |> Result.toMaybe |> Maybe.withDefault model.numberOfGroups
            in
                { model | numberOfGroups = newNumber } ! []

        GoToInstructions ->
            { model | currentPage = Instructions } ! []

        FinishSurvey ->
            { model | currentPage = Finished } ! []

        StartSurvey ->
            let
                newModel =
                    { model | survey = Data.surveyData }
            in
                { newModel | currentPage = Survey } ! []

        StartSurveyWithGroups numGroups ->
            let
                newSurvey =
                    Data.createSurvey 10 numGroups Data.surveyMetaData Data.surveyDataQuestions

                newModel =
                    { model | survey = newSurvey }
            in
                { newModel | currentPage = Survey } ! []

        NextQuestion ->
            let
                newQuestions =
                    case Zipper.next model.survey.questions of
                        Just x ->
                            x

                        _ ->
                            model.survey.questions

                currentSurvey =
                    model.survey

                newSurvey =
                    { currentSurvey | questions = newQuestions }
            in
                { model | survey = newSurvey } ! []

        PreviousQuestion ->
            let
                newQuestions =
                    case Zipper.previous model.survey.questions of
                        Just x ->
                            x

                        _ ->
                            model.survey.questions

                currentSurvey =
                    model.survey

                newSurvey =
                    { currentSurvey | questions = newQuestions }
            in
                { model | survey = newSurvey } ! []

        DecrementAnswer answer groupNumber ->
            --if points for this answer is > 0,
            --then decrement the point in this answer and
            --increment the points left for the group
            let
                newModel =
                    decrementAnswer model answer groupNumber
            in
                newModel ! []

        IncrementAnswer answer groupNumber ->
            --    --if points left in group > 0,
            --then increment the point in the group for
            --this answer and decrement the points assigned for the group
            let
                newModel =
                    incrementAnswer model answer groupNumber
            in
                newModel ! []


incrementAnswer model answer group =
    let
        newQuestions =
            Zipper.mapCurrent
                (\question ->
                    { id = question.id
                    , title = question.title
                    , pointsLeft =
                        List.map
                            (\pointsLeftInGroup ->
                                if pointsLeftInGroup.group == group then
                                    if pointsLeftInGroup.pointsLeft > 0 then
                                        { group = group, pointsLeft = pointsLeftInGroup.pointsLeft - 1 }
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
                                                    if y.group == group then
                                                        if isPointsInGroup question.pointsLeft group then
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
                model.survey.questions

        currentSurvey =
            model.survey

        newSurvey =
            { currentSurvey | questions = newQuestions }

        newModel =
            { model | survey = newSurvey }
    in
        newModel


decrementAnswer model answer group =
    let
        newQuestions =
            Zipper.mapCurrent
                (\question ->
                    { id = question.id
                    , title = question.title
                    , pointsLeft =
                        List.map
                            (\pointsLeftInGroup ->
                                if pointsLeftInGroup.group == group then
                                    if isAnswerGreaterThanZero answer group then
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
                                                    if y.group == group then
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
                model.survey.questions

        currentSurvey =
            model.survey

        newSurvey =
            { currentSurvey | questions = newQuestions }

        newModel =
            { model | survey = newSurvey }
    in
        newModel


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

            --, viewTest model
            , case model.currentPage of
                Instructions ->
                    viewInstructions model

                Survey ->
                    viewSurvey model

                Finished ->
                    viewFinished model
            ]



--viewTest : Model -> Element Styles variation Msg
--viewTest model =
--    Element.html
--        (Html.div [ Html.Attributes.style [ ( "width", "40%" ) ] ] [ Html.canvas [ Html.Attributes.id "chart" ] [] ])


viewInstructions : Model -> Element Styles variation Msg
viewInstructions model =
    column None
        [ center, spacing 20, paddingTop 20 ]
        [ h1 None [] (Element.text "Welcome to the Elm Ipsative Survey Prototype. There are currently 2 surveys to choose from.")
        , h2 None [] (Element.text model.survey.metaData.name)
        , h2 None [] (Element.text ("Last Updated: " ++ model.survey.metaData.lastUpdated))
        , h2 None [] (Element.text ("Created By: " ++ model.survey.metaData.createdBy))
        , button NextButton [ paddingXY 20 10, onClick StartSurvey ] (Element.text "Click to Start Survey")
        , row None
            [ spacing 20 ]
            [ Input.text NumberField
                []
                { onChange = ChangeNumberOfGroups
                , value = (toString model.numberOfGroups)
                , label =
                    Input.placeholder
                        { label = Input.labelAbove (el None [] (Element.text "Number of Groups"))
                        , text = ""
                        }
                , options =
                    []
                }
            , button NextButton [ paddingXY 20 10, onClick (StartSurveyWithGroups model.numberOfGroups) ] (Element.text ("Click to Start Survey with " ++ (toString model.numberOfGroups) ++ " Groups"))
            ]
        ]


viewFinished : Model -> Element Styles variation Msg
viewFinished model =
    Element.html
        (Html.div []
            [ viewChart model
            , Html.table []
                (viewFinishedTableHeader :: viewFinishedTableRows model.survey.questions)
            ]
        )


viewChart : Model -> Html.Html Msg
viewChart model =
    Html.div []
        [ Html.button [ Html.Events.onClick GenerateChart ] [ Html.text "Click to generate radar chart" ]
        , Html.div [ Html.Attributes.style [ ( "width", "40%" ) ] ] [ Html.canvas [ Html.Attributes.id "chart" ] [] ]
        ]


viewFinishedTableHeader =
    Html.tr []
        [ Html.td [] [ Html.text "Question" ]
        , Html.td [] [ Html.text "Answer" ]
        , Html.td [] [ Html.text "Group" ]
        , Html.td [] [ Html.text "Points" ]
        ]


viewFinishedTableRows : Zipper Question -> List (Html.Html Msg)
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


generateOutputRows : List Question -> List OutputRow
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


viewSurvey : Model -> Element Styles variation Msg
viewSurvey model =
    column None
        [ spacing 20 ]
        [ viewSurveyTitle model.survey
        , viewSurveyBoxes (Zipper.current model.survey.questions)
        , viewSurveyFooter
        ]


viewHeader : Element Styles variation Msg
viewHeader =
    row NavBarStyle
        [ spread, paddingXY 80 20 ]
        [ el Logo [] (Element.text "Elm Ipsative Survey Prototype")
        , row None
            [ spacing 20, verticalCenter ]
            [ el NavOption [] (Element.text "Instructions")
            , el NavOption [] (Element.text "Github")
            ]
        ]


viewSurveyTitle : Survey -> Element Styles variation Msg
viewSurveyTitle survey =
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


viewPointsLeft : List Data.PointsLeft -> Int -> List (Element Styles variation Msg)
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


viewSurveyBoxes : Question -> Element Styles variation Msg
viewSurveyBoxes surveyQuestion =
    wrappedRow None
        [ spacing 10, center ]
        (List.map (\x -> viewSurveyBox x) surveyQuestion.answers)


viewSurveyBox : Answer -> Element Styles variation Msg
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
