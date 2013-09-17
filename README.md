# caotico
`caotico` is the (very simple) engine being written to replace an atrociously-written Perl backend for [pgengler.net](http://pgengler.net). It's not really intended for general use but if you want to use this for yourself, go ahead. (You'll have to change the theme, however; this uses the [Basic Ultra-Clean Responsive Blog Theme](http://themeforest.net/item/basic-ultraclean-responsive-blog-theme/3726332) from Themeforest.)

This is a fairly simple post-centric design, where posts can have zero or more tags. There is no built-in authentication/authorization for the admin features, but they all live under an /admin URL so they can be protected by .htaccess.

Post content is Markdown-formatted blocks of text that are parsed to HTML for display. One "enhancement" is that text wrapped in a `<p>` block with a `data-pullquote` attribute will show the value of that attribute as a pullquote next to that paragraph.
