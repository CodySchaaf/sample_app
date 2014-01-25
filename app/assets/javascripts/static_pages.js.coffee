# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
	word_count_and_display = (object) ->
		chars = object.value.replace(/\s/g,'').length
		$("#word_count").html "Characters Left: " + (140 - (chars))
	$("#micropost_content").keyup ->
	  word_count_and_display this