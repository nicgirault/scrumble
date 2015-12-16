angular.module 'NotSoShitty.bdc'
.controller 'BurnDownChartCtrl', (
  $scope
  $state
  BDCDataProvider
  TrelloClient
  trelloUtils
  svgToPng
  sprint
) ->
  $state.go 'tab.new-sprint' unless sprint?

  if sprint.bdcData?
    # the date is saved as a string so we've to convert it
    for day in sprint.bdcData
      day.date = moment(day.date).toDate()
  else
    sprint.bdcData = BDCDataProvider.initializeBDC sprint.dates.days, sprint.resources

  $scope.tableData = sprint.bdcData

  getCurrentDayIndex = (bdcData) ->
    for day, i in bdcData
      return i unless day.done?
  $scope.currentDayIndex = getCurrentDayIndex $scope.tableData

  $scope.save = ->
    svg = d3.select('#bdcgraph')[0][0].firstChild
    sprint.bdcBase64 = svgToPng.getPngBase64 svg
    sprint.save().then ->
      $scope.currentDayIndex = getCurrentDayIndex $scope.tableData

  $scope.fetchTrelloDonePoints = ->
    if sprint.doneColumn?
      trelloUtils.getColumnPoints sprint.doneColumn
      .then (points) ->
        $scope.tableData[$scope.currentDayIndex].done = points
