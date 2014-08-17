settingModule = angular.module 'fusionpanel', []

settingController = ($scope, $http) ->

 # Enable cancel and invite button
  enableButtonControl = ->
    $( "#update-smtp-cancel" ).attr('data-dismiss', 'modal')
    $( "#x-close-modal" ).attr('data-dismiss', 'modal')
    $scope.buttonControl = false
    
  # Disable cancel and invite button
  disableButtonControl = ->
    $( "#update-smtp-cancel" ).removeAttr('data-dismiss')
    $( "#x-close-modal" ).removeAttr('data-dismiss')
    $scope.buttonControl = true
    
  enableButtonControl()
  
  # Create category function
  $scope.updateSMTP = (action) ->
    
    # Template for preloader
    showPreload = ->
      '<div class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div>';
        
    # Template for resonse error
    showError = (msg) ->
      '<div class="alert alert-error">' + msg + '</div>'
        
    disableButtonControl()
    # Show preloader when action start
    $scope.messageStatus = showPreload
    $http({
      method: "POST",
      url: baseURL + adminSlug + action,
      data: {'smtp_address': $scope.smtpAddress, 'smtp_port': $scope.smtpPort, 'smtp_domain': $scope.smtpDomain, 'smtp_username':$scope.smtpUsername, 'smtp_password':$scope.smtpPassword,  'authenticity_token': authenticityToken},
      headers: {'Content-type': 'application/json'}
    }).success((data, status, headers, config) ->
      response = data.code
      if response == 100
        window.location.href = baseURL + adminSlug + "/settings"
      else
        $scope.messageStatus = showError data.message
      enableButtonControl()
    ).error((data, status, headers, config) ->
      $scope.messageStatus = 'Oops! something went wrong to our system, please try again.'
      enableButtonControl()
    )

  $scope.switchPresence = (status) ->
    if status == 'online'
      $scope.presenceLabel = 'label-success'
      $scope.presenceButton = 'btn-danger'
      $scope.toswitch = 'offline'
    else
      $scope.presenceLabel = 'label-important'
      $scope.presenceButton = 'btn-success'
      $scope.toswitch = 'online'
    $scope.presence = status
  $scope.updateSetting = () ->
    $("#updateSetting").submit()

  # Trigger action menu status filter
  $scope.selectHomepage = (value,id) ->
    if value.length >= 37
      $scope.HomepageValue = value.slice(0,25) + '...'
    else
      $scope.HomepageValue = value
    $scope.HomepageValueID = id
  return

settingModule.controller appController, settingController