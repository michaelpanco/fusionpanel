userModule = angular.module 'fusionpanel', []

userController = ($scope, $http) ->
  $scope.selectedItem = 0
  $scope.deleteButton = true
  $scope.roleValue = "Select User Role"

  # Trigger action menu status filter
  $scope.selectStatus = (status) ->
    $scope.statusValue = status
    
  # Enable cancel and invite button
  enableButtonControl = ->
    $( "#invite-user-cancel" ).attr('data-dismiss', 'modal')
    $( "#x-close-modal" ).attr('data-dismiss', 'modal')
    $scope.buttonControl = false
    
  # Disable cancel and invite button
  disableButtonControl = ->
    $( "#invite-user-cancel" ).removeAttr('data-dismiss')
    $( "#x-close-modal" ).removeAttr('data-dismiss')
    $scope.buttonControl = true
    
  enableButtonControl()
  
  # Create category function
  $scope.inviteUser = (action) ->
    
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
    $scope.messageStatus = showPreload
    disableButtonControl()
    $http({
      method: "POST",
      url: baseURL + adminSlug + action,
      data: {'email': $scope.roleEmailValue, 'role': $scope.roleIDValue, authenticity_token: authenticityToken},
      headers: {'Content-type': 'application/json'}
    }).success((data, status, headers, config) ->
      response = data.code
      if response == 100
        $scope.clearInviteUserForm()
        $scope.messageStatus = showSuccess data.message
      else
        $scope.messageStatus = showError data.message
      enableButtonControl()
    ).error((data, status, headers, config) ->
      $scope.messageStatus = showError 'Oops! something went wrong with our system, please try again.'
      enableButtonControl()
    )
 
  # Change account  password
  $scope.changePassword = (action) ->
    
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
    $scope.messagePasswordStatus = showPreload
    disableButtonControl()
    
    if !angular.isUndefined($scope.oldPassword) && !angular.isUndefined($scope.newPassword) && !angular.isUndefined($scope.renewPassword) 
      
      if $scope.newPassword == $scope.renewPassword
      
        $http({
          method: "POST",
          url: baseURL + adminSlug + action,
          data: {'oldpassword': $scope.oldPassword, 'newpassword': $scope.newPassword, authenticity_token: authenticityToken},
          headers: {'Content-type': 'application/json'}
        }).success((data, status, headers, config) ->
          response = data.code
          if response == 100
            $scope.messagePasswordStatus = showSuccess data.message
          else
            $scope.messagePasswordStatus = showError data.message
          enableButtonControl()
        ).error((data, status, headers, config) ->
          $scope.messagePasswordStatus = 'Oops! something went wrong to our system, please try again.'
          enableButtonControl()
        )
      else
        $scope.messagePasswordStatus = showError "New password doesn't match"
        enableButtonControl()
      
    else
     $scope.messagePasswordStatus = showError "Please enter all the fields"
     enableButtonControl()

  
  # Update User Role
  $scope.changeRole = (action) ->
    
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
    $scope.messageStatus = showPreload
    disableButtonControl()
    $http({
      method: "POST",
      url: baseURL + adminSlug + action,
      data: {'userid': $scope.userID, 'role': $scope.roleIDValue, authenticity_token: authenticityToken},
      headers: {'Content-type': 'application/json'}
    }).success((data, status, headers, config) ->
      response = data.code
      if response == 100
        $scope.messageStatus = showSuccess data.message
        $scope.usersRole = $scope.roleValue
      else
        $scope.messageStatus = showError data.message
      enableButtonControl()
    ).error((data, status, headers, config) ->
      $scope.messageStatus = 'Oops! something went wrong to our system, please try again.'
      enableButtonControl()
    )
    
  # Quick status update when user click status
  $scope.updateStatus = (id, status) ->
    $http({
      method: "POST",
      url: baseURL + adminSlug + "/updatestatus",
      data: {'email': $scope.roleEmailValue, 'role': $scope.roleIDValue, authenticity_token: authenticityToken},
      headers: {'Content-type': 'application/json'}
    }).success((data, status, headers, config) ->
      response = data.code
      if response == 100
        $scope.messageStatus = showSuccess data.message
      else
        $scope.messageStatus = showError data.message
    ).error((data, status, headers, config) ->
      $scope.messageStatus = 'Oops! something went wrong to our system, please try again.'
    )
    
  # Clear Add category form when modal open
  $scope.clearInviteUserForm = ->
    $scope.messageStatus = ""
    $scope.roleEmailValue = ""
    $scope.roleIDValue = ""
    $scope.roleValue = "Select User Role"
    
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
        
  # Delete item of all item mark checked  
  $scope.deleteSingleUser = (formID) ->
    $(formID).submit()
      
   
  # Trigger action menu category filter
  $scope.selectRole = (userRoleID, userRole) ->
    $scope.roleIDValue = userRoleID
    $scope.roleValue = userRole

  return

userModule.controller appController, userController

###

$(document).ready ->

	# Trigger action menu category filter
	$(".dropdown-menu.role-menu li a").click (e)->
		e.preventDefault()
		$(".btn.btn-role").text($(this).text())
		$("#user_request_role").val($(this).attr("data-role-id"))

	noEffect = (e) ->
		$("#user_request_email").val("")
		$(".btn.btn-role").text("Select User Role")
		$("#user_request_role").val("")
		$("#add-user-modal .message-status").html("")

	$('#add-user-modal').on 'hide', noEffect

	showPreload = ->
		'<div class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div>';

	showError = (msg) ->
		'<div class="alert alert-error">' + msg + '</div>'

	showSuccess = (msg) ->
		'<div class="alert alert-success">' + msg + '</div>'

	$("#add-new-user").submit (e)->

		$("#add-user-modal .message-status").html(showPreload())


		$.ajax '/administrator/users/add',
			type: 'POST'
			dataType: 'json'
			data: $("#add-new-user").serialize()

			error: (data) ->
				$("#add-user-modal .message-status").html(showError("<%= Fusionpanel::Application.config.error_process_message %>"))

			success: (data) ->
				response = data.code
				if response == 100
					$("#add-user-modal .message-status").html(showSuccess(data.message))
					$("#user_request_email").val("")
					$(".btn.btn-role").text("Select User Role")
					$("#user_request_role").val("")
					setTimeout (-> $('#add-user-modal').modal('hide')), 2000
				else
					$("#add-user-modal .message-status").html(showError(data.message))

		return false;  
  
###