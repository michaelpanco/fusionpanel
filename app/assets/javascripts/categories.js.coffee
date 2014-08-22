categoryModule = angular.module 'fusionpanel', []

categoryController = ($scope, $http) ->
  $scope.selectedItem = 0
  $scope.parentCategoryID = 1
  $scope.deleteButton = true
  $scope.categoryValue = "No Category"
  $scope.statusValue = "Active"
  $scope.parentCategory = "none"
  
  # Enable cancel and invite button
  enableButtonControl = ->
    $( "#create-category-cancel" ).attr('data-dismiss', 'modal')
    $( "#x-close-modal" ).attr('data-dismiss', 'modal')
    $scope.buttonControl = false
    
  # Disable cancel and invite button
  disableButtonControl = ->
    $( "#create-category-cancel" ).removeAttr('data-dismiss')
    $( "#x-close-modal" ).removeAttr('data-dismiss')
    $scope.buttonControl = true
    
  enableButtonControl()
  
  # Create category function
  $scope.createCategory = (action) ->
    
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
      data: {'category_name': $scope.categoryName, 'category_slug': $scope.categorySlug, 'parent_category': $scope.parentCategoryID, authenticity_token: authenticityToken},
      headers: {'Content-type': 'application/json'}
    }).success((data, status, headers, config) ->
      response = data.code
      if response == 100
        window.location.href = baseURL + adminSlug + "/categories"
      else
        $scope.messageStatus = showError data.message
      enableButtonControl()
    ).error((data, status, headers, config) ->
      $scope.messageStatus = 'Oops! something went wrong to our system, please try again.'
      enableButtonControl()
    )
  
  # Clear Add category form when modal open
  $scope.clearAddCategoryForm = ->
    $scope.messageStatus = ""
    $scope.categoryName = ""
    $scope.categorySlug = ""
  
  #  Activate delete button when item is selected
  activateDeleteBtn = () ->
    if ( $scope.selectedItem > 0 )
      $scope.deleteButton = false
    else
      $scope.deleteButton = true
    return
  
  # Select item and increment the selectedItem variable
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
    
  $scope.selectParentCategory = (parentCategory, catID) ->
    $scope.parentCategory = parentCategory
    $scope.parentCategoryID = catID
  # Delete item of all item mark checked  
  $scope.deleteSelected = (formID) ->
    if ( $scope.selectedItem > 0 )
      $(formID).submit()
      
  # Change slug field when content title has changed
  $scope.populateSlug = () ->
    $scope.categorySlug = $scope.categoryName.replace(/[^a-zA-Z0-9-\s]/gi, '').replace(/[_\s]/g, '-').toLowerCase();
    return
   
  # Trigger action menu category filter
  $scope.selectCategory = (category) ->
    $scope.categoryValue = category
  
  # Trigger action menu status filter
  $scope.selectStatus = (status) ->
    $scope.statusValue = status
  return

categoryModule.controller appController, categoryController

categoryModule.directive 'ngBlur', () ->
  (scope, elem, attrs ) ->
    elem.bind 'blur', () ->
      scope.$apply attrs.ngBlur
      return
    return
  
###

$(document).ready ->

	# Change slug field when content title changed
	$("#category_name").change (e)->
		convert_slug = $(this).val().replace(/[^a-z0-9\s]/gi, '').replace(/[_\s]/g, '-').toLowerCase();
		$("#category_slug").val(convert_slug);

	showPreload = ->
		'<div class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div>';

	showError = (msg) ->
		'<div class="alert alert-error">' + msg + '</div>'

	$("#create-new-category").submit (e)->

		$("#create-category-modal .message-status").html(showPreload())

		$.ajax '/administrator/categories/add',
			type: 'POST'
			dataType: 'json'
			data: $("#create-new-category").serialize()

			error: (data) ->
				$("#create-category-modal .message-status").html(showError("Oops! something went wrong to our system, please try again."))

			success: (data) ->
				response = data.code
				if response == 100
					window.location.href = "http://localhost:3001/administrator/categories"
				else
					$("#create-category-modal .message-status").html(showError(data.message))

		return false;  

###