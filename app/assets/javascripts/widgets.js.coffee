widgetModule = angular.module 'fusionpanel', []

widgetController = ($scope) ->
  $scope.selectedItem = 0
  $scope.deleteButton = true
  $scope.categoryValue = "No Category"
  $scope.statusValue = "Active"
  
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
    
  # Change slug field when content title has changed
  $scope.populateAlias = () ->
   $scope.widgetAlias = $scope.widgetName.replace(/[^a-zA-Z0-9-\s]/gi, '').replace(/[_\s]/g, '-').toLowerCase();
   return
   
  # Trigger action menu category filter
  $scope.selectCategory = (category) ->
    $scope.categoryValue = category
  
  # Trigger action menu status filter
  $scope.selectStatus = (status) ->
    $scope.statusValue = status
  return

widgetModule.controller appController, widgetController

widgetModule.directive 'ngBlur', () ->
  (scope, elem, attrs ) ->
    elem.bind 'blur', () ->
      scope.$apply attrs.ngBlur
      return
    return
