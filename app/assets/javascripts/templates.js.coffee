templateModule = angular.module 'fusionpanel', []

templateController = ($scope) ->
  $scope.selectedItem = 0
  $scope.deleteButton = true
  
  activateDeleteBtn = () ->
    if ( $scope.selectedItem > 0 )
     $scope.deleteButton = false
    else
     $scope.deleteButton = true
    return
    
  $scope.selectItem = (check) ->
    if(check)
     $scope.selectedItem++
    else
     $scope.selectedItem = $scope.selectedItem - 1
    $scope.masterSelect = false
    activateDeleteBtn()
    return
  
  $scope.selectAll = (parentElement, recordCount) ->
    if (parentElement)
      $scope.masterSelect = "true"
      $scope.masters = "true"
      $scope.selectedItem = recordCount
    else
      $scope.masterSelect = false
      $scope.masters = false
      $scope.selectedItem = 0
    activateDeleteBtn()
    return
  
  # Delete item of all item mark checked  
  $scope.deleteSelected = (formID) ->
    if ( $scope.selectedItem > 0 )
      $(formID).submit()

templateModule.controller appController, templateController

templateModule.directive 'ngBlur', () ->
  (scope, elem, attrs ) ->
    elem.bind 'blur', () ->
      scope.$apply attrs.ngBlur
      return
    return
