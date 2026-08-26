require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"
require "html_pipeline/node_filter/syntax_highlight_filter"
require "html_pipeline/sanitization_filter"

# Renders Markdown text to sanitized HTML with syntax highlighting.
# Used by both ApplicationHelper (for view rendering) and the Post model
# (for pre-rendering content on save).
module MarkdownRenderer
  # Deep-copy the default sanitization config (which is frozen) and add the
  # data-pullquote attribute on <p> elements for the blog's pullquote
  # enhancement.
  SANITIZATION_CONFIG = begin
    config = HTMLPipeline::SanitizationFilter::DEFAULT_CONFIG.dup
    config[:attributes] = config[:attributes].dup
    config[:attributes]["p"] = ["data-pullquote"]
    config
  end.freeze

  PIPELINE = HTMLPipeline.new(
    convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
    node_filters: [HTMLPipeline::NodeFilter::SyntaxHighlightFilter.new],
    sanitization_config: SANITIZATION_CONFIG,
    default_context: {
      # Allow raw HTML (e.g. <p data-pullquote="...">) through Commonmarker so
      # the sanitization filter can decide what to keep.
      markdown: { render: { unsafe: true } },
    },
  )

  def self.render(text)
    output = PIPELINE.call(text)[:output].to_s
    output.respond_to?(:html_safe) ? output.html_safe : output
  end
end
