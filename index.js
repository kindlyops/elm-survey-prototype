const Chart = window.Chart

let elmApp = Elm.Main.embed(document.getElementById('elm'))

elmApp.ports.radarChart.subscribe(chartConfig => {
  chartConfig.type = 'radar'
  window.myRadar = new Chart(document.getElementById('chart'), chartConfig)
})
