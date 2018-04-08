class HTML::Pipeline
  class SyntaxHighlightFilter < Filter
    def lexer_for(lang)
      Pygments::Lexer[lang]
    end
  end
end
