webtrafficModule = angular.module 'fusionpanel', []

webtrafficController = ($scope, $http) ->
  delete $http.defaults.headers.common['X-Requested-With'];
  $('.country').each () ->
    elem_id = $(this).attr('id');
    elem_ip = $(this).attr('data-ipaddress');
    $http.get('http://ip-api.com/json/' + elem_ip).success (data) ->
      if data.status == 'success'
        country_code =  data.countryCode.toLowerCase()
        if country_code == 'rd'
          ip_flag = ''
        else
          ip_flag = '<img src="http://www.geoips.com/assets/img/flag/16/' + country_code + '.png" />'
        if data.country == ''
          data_country = '(not available)'
          ip_flag = ''
        else
          data_country = data.country
      else
        ip_flag = ''
        data_country = '(not available)'
        
      document.getElementById(elem_id).innerHTML= ip_flag + ' ' + data_country
      return
    return

  $('.data_details').each () ->
    elem_id = $(this).attr('id');
    elem_ip = $(this).attr('data-ipaddress');
    $http.get('http://ip-api.com/json/' + elem_ip).success (data) ->
      if data.status == 'success'
        country_code =  data.countryCode.toLowerCase()
        if elem_id == 'country'
          data_var = '<img src="http://www.geoips.com/assets/img/flag/16/' + country_code + '.png" />' + ' ' + data.country
        else if elem_id == 'region'
          data_var = data.regionName
          #data_var = '<img src="http://www.geoips.com/assets/img/flag/16/' + country_code + '.png" />'
        else if elem_id == 'city'
          data_var = data.city
        else if elem_id == 'isp'
          data_var = data.isp
        else if elem_id == 'map'
          data_var = '<img class="pull-right" src="http://maps.googleapis.com/maps/api/staticmap?center=' + data.lat + ',' + data.lon + '&zoom=10&size=400x200&sensor=false" />'
        else
          data_var = ''
      document.getElementById(elem_id).innerHTML= data_var #ip_flag + ' ' + data.country_name
      return
    return
  return
  
webtrafficModule.controller appController, webtrafficController

