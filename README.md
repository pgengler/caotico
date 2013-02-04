# caotico
`caotico` is the (very simple) engine being written to replace an atrociously-written Perl backend for [pgengler.net](http://pgengler.net). It's not really intended for general use but if you want to use this for yourself, go ahead.

For now, the only model/controller are for Posts. These are Markdown-formatted blocks of text that are parsed to HTML for display. One "enhancement" is that text wrapped in a <p> block with a `data-pullquote` attribute will show the value of that attribute as a pullquote next to that paragraph.
