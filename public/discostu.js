function list_albums(search) {
	if (typeof(search) != 'undefined' && search != null && search != '')
		params = 'name=' + search ;
	else
		params = null ;
	
	new Ajax.Request('/albums', { method: 'get', parameters: params,
	 	onSuccess: function(response) {
			$('albums').update(response.responseText.evalJSON().map(function(a) {
				var albumdiv = '<div class="album"><div class="coverart"></div>#{name}' ;
				albumdiv += '<br /><a href="javascript:void" onclick="add_album(#{id})">Add All</a></div>' ;
				return albumdiv.interpolate(a) ;
			}).join('\n')) ;
		}
	}) ;
}

function add_album(album_id) {
	new Ajax.Request('/playlist_items', { method: 'post', parameters: 'album_id=' + album_id }) ;
}

function nexttrack() {
	new Ajax.Request('/player/next', {
		method: 'post',
		onSuccess: function(response) {
			next_update(1) ;
		},
		onFailure: function(response) {
			alert(response.responseText) ;
		}
	}) ;
}

function prevtrack() {
	new Ajax.Request('/player/prev', {
		method: 'post',
		onSuccess: function(response) {
			next_update(1) ;
		},
		onFailure: function(response) {
			alert(response.responseText) ;
		}
	}) ;
}

function playpause() {
	new Ajax.Request('/player/play', {
		method: 'post',
		onSuccess: function(response) {
			next_update(1) ;
		},
		onFailure: function(response) {
			alert(response.responseText) ;
		}
	}) ;
}

function stopplaying() {
	new Ajax.Request('/player/stop', {
		method: 'post',
		onSuccess: function() {
			window.clearTimeout(schedule_update) ;
		},
		onFailure: function() {
			alert(reponse.responseText)
		}
	}) ;
}

function update_albumartist() {
	new Ajax.Updater('metadata', '/meta', { method:'get' }) ;
	schedule_update = update_albumartist.delay(10) ;
}

function next_update(time) {
	if (schedule_update != null)
		window.clearTimeout(schedule_update) ;
	schedule_update = update_albumartist.delay(time) ;
}