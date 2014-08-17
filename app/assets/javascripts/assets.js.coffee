assets = angular.module 'fusionpanel', []

routeProv = ($routeProvider) ->
  $routeProvider.when '/', {templateUrl: window.baseURL + window.adminSlug + '/template_loader', controller: 'assets'}
  $routeProvider.when '/file_id/:item', {templateUrl: window.baseURL + window.adminSlug + '/template_loader', controller: 'assets'}
  $routeProvider.otherwise "undefined"
  return

assets.config ['$routeProvider', routeProv]

assets.directive 'fileDirectory', () ->
  solid_opacity = 1
  flimsy_opacity = 0.85
  return {restrict: 'A', scope: {fileId: '@'}, link: (scope, elem, attrs)->
    elem.attr 'style', 'opacity:' + flimsy_opacity
    elem.bind 'dblclick', (e) ->
      window.location = '#/file_id/' + scope.fileId
      return
    elem.bind 'mouseover', (e) ->
      elem.attr 'style', 'opacity:' + solid_opacity
    elem.bind 'mouseout', (e) ->
      elem.attr 'style', 'opacity:' + flimsy_opacity
    return}

assets.controller 'assets', ($scope, $routeParams, $location) ->
  
  $scope.filefolders = [];
  
  $scope.setFileID = (fileID) ->
    $scope.fileID = fileID
    
  $scope.addremove = (check_state, file_ids) ->
    if check_state
      $scope.filefolders.push file_ids
    else
      index = $scope.filefolders.indexOf file_ids
      $scope.filefolders.splice index,1
  
  $scope.submitform = () ->
    
    askdelete=confirm "WARNING: This will delete all file and folder you selected and all of its contents. Do you want to continue?"
    
    if askdelete
      $("#deletefilefolder").submit()
    else
    
  if($routeParams.item > 0)
    $scope.templateUrl = window.baseURL + window.adminSlug + '/file_writer/' + $routeParams.item
  else
    $scope.templateUrl = window.baseURL + window.adminSlug + '/file_writer/' + 0
  
  return
