// Search popup
$('.search > .icon-search').click(function() {
	$('.search_popup').slideDown('', function() { });
	$('.search_popup').find('input[type=text]').focus();
	$('.search > .icon-search').toggleClass('active');
	$('.search > .icon-remove').toggleClass('active');
});

$('.search > .icon-remove').click(function() {
	$('.search_popup').slideUp('', function() { });
	$('.search_popup').find('input[type=text]').blur();
	$('.search > .icon-search').toggleClass('active');
	$('.search > .icon-remove').toggleClass('active');
});

// Mobile menu
$('.menubutton').click(function() {
	$('header nav').slideToggle('', function() { });
});
