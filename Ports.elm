port module Ports exposing (..)

import RadarChart exposing (RadarChartConfig)


port radarChart : RadarChartConfig -> Cmd msg
