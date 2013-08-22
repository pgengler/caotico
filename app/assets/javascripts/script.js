// Search popup
$('.search > .icon-search').click(function() {
	$('.search_popup').slideDown('', function() { });
	$('.search > .icon-search').toggleClass('active');
	$('.search > .icon-remove').toggleClass('active');
});

$('.search > .icon-remove').click(function() {
	$('.search_popup').slideUp('', function() { });
	$('.search > .icon-search').toggleClass('active');
	$('.search > .icon-remove').toggleClass('active');
});

// Mobile menu
$('.menubutton').click(function() {
	$('header nav').slideToggle('', function() { });
});

// Responsive videos
$(".post_video").fitVids();

// Contact form validation
$("#contact_form").validate();

setTimeout(function() {
	$("#contact_form").submit(function(e) {
		e.preventDefault();
		if (!$('input, textarea').hasClass('error')) {
			$('#contact #contact_form').slideUp(250);
			$('#contact .message').slideDown(250);
			$.post('js/send.php', $('#contact_form').serialize());
		} else {
			return false;
		}
	});
}, 500);
