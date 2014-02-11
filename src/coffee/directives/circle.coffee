###
!
The MIT License

Copyright (c) 2010-2013 Google, Inc. http://angularjs.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

angular-google-maps
https://github.com/nlaplante/angular-google-maps

@authors
Nicolas Laplante - https://plus.google.com/108189012221374960701
Nicholas McCready - https://twitter.com/nmccready
Chentsu Lin - https://github.com/ChenTsuLin
###
angular.module("google-maps").directive "circle", ["$log", "$timeout", ($log, $timeout) ->
  validateCenterPoints = (center) ->
    return false  if angular.isUndefined(center.latitude) or angular.isUndefined(center.longitude)

    true
  convertCenterPoints = (center) ->
    result = new google.maps.LatLng(center.latitude, center.longitude)

    result
  fitMapBounds = (map, bounds) ->
    map.fitBounds bounds

  #
  #         * Utility functions
  #

  ###
  Check if a value is true
  ###
  isTrue = (val) ->
    angular.isDefined(val) and val isnt null and val is true or val is "1" or val is "y" or val is "true"
  "use strict"
  DEFAULTS = {}
  restrict: "ECA"
  require: "^googleMap"
  replace: true
  scope:
    center: "=center"
    radius: "=radius"
    stroke: "=stroke"
    clickable: "="
    draggable: "="
    editable: "="
    fill: "="
    visible: "="

  link: (scope, element, attrs, mapCtrl) ->

    # Validate required properties
    if angular.isUndefined(scope.center) or scope.center is null or angular.isUndefined(scope.center) or scope.center is null or not validateCenterPoints(scope.center)
      $log.error "circle: no valid bound attribute found"
      return

    # Wrap circle initialization inside a $timeout() call to make sure the map is created already
    $timeout ->
      buildOpts = (center,radius) ->
        opts = angular.extend({}, DEFAULTS,
          map: map
          center: center
          radius: radius
          strokeColor: scope.stroke and scope.stroke.color
          strokeOpacity: scope.stroke and scope.stroke.opacity
          strokeWeight: scope.stroke and scope.stroke.weight
          fillColor: scope.fill and scope.fill.color
          fillOpacity: scope.fill and scope.fill.opacity
        )
        angular.forEach
          clickable: true
          draggable: false
          editable: false
          visible: true
        , (defaultValue, key) ->
          if angular.isUndefined(scope[key]) or scope[key] is null
            opts[key] = defaultValue
          else
            opts[key] = scope[key]

        opts
      map = mapCtrl.getMap()
      circle = new google.maps.Circle(buildOpts(convertCenterPoints(scope.center),scope.radius))
      fitMapBounds map, bounds  if isTrue(attrs.fit)
      if angular.isDefined(scope.editable)
        scope.$watch "editable", (newValue, oldValue) ->
          circle.setEditable newValue

      if angular.isDefined(scope.draggable)
        scope.$watch "draggable", (newValue, oldValue) ->
          circle.setDraggable newValue

      if angular.isDefined(scope.visible)
        scope.$watch "visible", (newValue, oldValue) ->
          circle.setVisible newValue

      if angular.isDefined(scope.stroke) and angular.isDefined(scope.stroke.color)
        scope.$watch "stroke.color", (newValue, oldValue) ->
          circle.setOptions buildOpts(circle.getCenter(),circle.getRadius())

      if angular.isDefined(scope.stroke) and angular.isDefined(scope.stroke.weight)
        scope.$watch "stroke.weight", (newValue, oldValue) ->
          circle.setOptions buildOpts(circle.getCenter(),circle.getRadius())

      if angular.isDefined(scope.stroke) and angular.isDefined(scope.stroke.opacity)
        scope.$watch "stroke.opacity", (newValue, oldValue) ->
          circle.setOptions buildOpts(circle.getCenter(),circle.getRadius())

      if angular.isDefined(scope.fill) and angular.isDefined(scope.fill.color)
        scope.$watch "fill.color", (newValue, oldValue) ->
          circle.setOptions buildOpts(circle.getCenter(),circle.getRadius())

      if angular.isDefined(scope.fill) and angular.isDefined(scope.fill.opacity)
        scope.$watch "fill.opacity", (newValue, oldValue) ->
          circle.setOptions buildOpts(circle.getCenter(),circle.getRadius())

      google.maps.event.addListener circle, "center_changed", ->
        c = circle.center
        _.defer ->
          scope.$apply (s) ->
            s.center.latitude = c.lat()  if s.center.latitude isnt c.lat()
            s.center.longitude = c.lng()  if s.center.longitude isnt c.lng()

      google.maps.event.addListener circle, "radius_changed", ->
        r = circle.radius
        _.defer ->
          scope.$apply (s) ->
            s.radius= r  if s.radius isnt r

      # Remove circle on scope $destroy
      scope.$on "$destroy", ->
        circle.setMap null


]
