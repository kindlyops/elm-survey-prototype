module StyleSheet exposing (..)

import Color
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Transition as Transition


type Styles
    = None
    | Main
    | NavBarStyle
    | Page
    | Logo
    | NavOption
    | Box
    | Container
    | Label
    | ProgressBarContainer
    | ProgressBarBackground
    | ProgressBar
    | SaveButton
    | NavigationButton
    | NextButton
    | SubQuestionButton
    | SurveyFooterStyle
    | SubQuestionStyle
    | SurveyQuestionStyle
    | NumberField


sansSerif : List Font
sansSerif =
    [ Font.font "helvetica"
    , Font.font "arial"
    , Font.font "sans-serif"
    ]


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Main
            [ Color.text Color.darkCharcoal

            --, Color.background Color.white
            , Font.typeface sansSerif
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style NavBarStyle
            [ Color.background Color.gray
            ]
        , style Page
            [ Border.all 5
            , Border.solid
            , Color.text Color.darkCharcoal
            , Color.background Color.white
            , Color.border Color.lightGrey
            ]
        , style Label
            [ Font.size 25
            , Font.center
            ]
        , style Logo
            [ Font.size 25
            , Font.typeface sansSerif
            ]
        , style NavOption
            [ Font.size 16
            , Font.typeface sansSerif
            ]
        , style Box
            [ Transition.all
            , Color.text Color.white
            , Color.background Color.blue
            , Color.border Color.blue
            , Border.rounded 3
            , hover
                [ Color.text Color.white
                , Color.background Color.red
                , Color.border Color.red
                , cursor "pointer"
                ]
            ]
        , style Container
            [ Color.text Color.black
            , Color.background Color.lightGrey
            , Color.border Color.lightGrey
            ]
        , style ProgressBarContainer
            [ Color.background Color.red
            ]
        , style ProgressBarBackground
            [ Color.background Color.lightGrey
            ]
        , style ProgressBar
            [ Color.background Color.blue
            ]
        , style SaveButton
            [ Color.background Color.yellow
            ]
        , style NavigationButton
            [ Color.background Color.lightBlue
            ]
        , style NextButton
            [ Color.background Color.green
            , Color.text Color.white
            ]
        , style SubQuestionButton
            [ Color.background Color.lightBlue
            ]
        , style SurveyFooterStyle
            []
        , style SubQuestionStyle
            [ Color.border Color.black
            , Border.solid
            , Font.lineHeight 2
            , Border.all 2
            ]
        , style SurveyQuestionStyle
            [ Font.size 20
            , Font.bold
            ]
        , style NumberField
            [ Border.rounded 5
            , Border.all 1
            , Border.solid
            , Color.border Color.lightGrey
            ]
        ]
