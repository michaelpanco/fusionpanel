# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
mainModule = angular.module 'fusionpanel', []

mainController = ($scope, $http) ->
  
  $scope.selectMonth = (month) ->
    $scope.selectedMonth = month
    return

  $scope.selectYear = (year) ->
    $scope.selectedYear = year
    return

  # Enable cancel and invite button
  enableButtonControl = ->
    $( "#forgot-password-cancel" ).attr('data-dismiss', 'modal')
    $( "#x-close-modal" ).attr('data-dismiss', 'modal')
    $scope.buttonControl = false
    
  # Disable cancel and invite button
  disableButtonControl = ->
    $( "#forgot-password-cancel" ).removeAttr('data-dismiss')
    $( "#x-close-modal" ).removeAttr('data-dismiss')
    $scope.buttonControl = true
    
  enableButtonControl()

  # Trigger forgot password

  $scope.forgotPassword = (action) ->
    
    # Template for preloader
    showPreload = ->
      '<div class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div>'
        
    # Template for success message
    showSuccess = (msg) ->
      '<div class="alert alert-success">' + msg + '</div>'
        
    # Template for resonse error
    showError = (msg) ->
      '<div class="alert alert-error">' + msg + '</div>'
        
    # Show preloader when action start
    $scope.messageForgotStatus = showPreload
    disableButtonControl()
    
    if !angular.isUndefined($scope.forgotAccountEmail) 
      
      $http({
        method: "POST",
        url: baseURL + adminSlug + action,
        data: {'emailaddress': $scope.forgotAccountEmail, authenticity_token: authenticityToken},
        headers: {'Content-type': 'application/json'}
      }).success((data, status, headers, config) ->
        response = data.code
        if response == 100
          $scope.messageForgotStatus = showSuccess data.message
        else
          $scope.messageForgotStatus = showError data.message
        enableButtonControl()
      ).error((data, status, headers, config) ->
        $scope.messageForgotStatus = 'Oops! something went wrong to our system, please try again.'
        enableButtonControl()
      )

    else
    
     $scope.messageForgotStatus = showError "Please enter your email address"
     enableButtonControl()


mainModule.controller appController, mainController