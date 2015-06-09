module Refinery
  module WordPress
    class Page
      include ::ActionView::Helpers::TagHelper
      include ::ActionView::Helpers::TextHelper

      attr_reader :dump
      attr_reader :node
      attr_reader :body_part

      def initialize(node, dump = nil)
        @node = node
        @dump = dump
      end

      def inspect
        "WordPress::Page(#{post_id}): #{title}"
      end

      def link
        node.xpath("link").text
      end

      def title
        node.xpath("title").text
      end

      def excerpt
        node.xpath("excerpt:encoded").text
      end

      def excerpt_formatted
        formatted = format_syntax_highlighter(format_paragraphs(excerpt))

        # remove all tags inside <pre> that simple_format created
        # TODO: replace format_paragraphs with a method, that ignores pre-tags
        formatted.gsub!(/(<pre.*?>)(.+?)(<\/pre>)/m) do |match|
          "#{$1}#{strip_tags($2)}#{$3}"
        end

        formatted
      end

      def content
        node.xpath("content:encoded").text
      end

      def content_formatted
        formatted = format_syntax_highlighter(format_captions(format_paragraphs(content)))

        # remove all tags inside <pre> that simple_format created
        # TODO: replace format_paragraphs with a method, that ignores pre-tags
        formatted.gsub!(/(<pre.*?>)(.+?)(<\/pre>)/m) do |match|
          "#{$1}#{strip_tags($2)}#{$3}"
        end

        formatted
      end

      def creator
        node.xpath("dc:creator").text
      end

      def post_date
        DateTime.parse node.xpath("wp:post_date").text
      end

      def post_id
        node.xpath("wp:post_id").text.to_i
      end

      def parent_id
        dump_id = node.xpath("wp:post_parent").text.to_i
        dump_id == 0 ? nil : dump_id
      end

      def status
        node.xpath("wp:status").text
      end

      def draft?
        status != 'publish'
      end

      def published?
        ! draft?
      end

      def ==(other)
        post_id == other.post_id
      end

      def to_refinery
        page = Refinery::Page.create!(:id => post_id, :title => title,
          :created_at => post_date, :draft => draft?)

        @body_part = page.parts.create(:title => 'Body', :body => content_formatted)
        page
      end

      def remap_urls
        # Remap internal blog post urls from old wordpress links to new refinery post links

        text = body_part.body.clone
        links = text.scan( /href="(.+?)"/ )
        updated = false

        links.each { |l|
          if l[0].start_with?( dump.base_blog_url )
            p = Refinery::Blog::Post.find_by_source_url l[0]
            if p.present?
              lup = Refinery::Core::Engine.routes.url_helpers.blog_post_path p
              text[ l[0] ] = lup
              updated = true
            end
          end
        }

        if updated
          body_part.body = text
          body_part.save
        end
      end

      private

      def format_paragraphs(text, html_options={})
        # WordPress doesn't export <p>-Tags, so let's run a simple_format over
        # the content. As we trust ourselves, no sanatize. This code is heavily
        # inspired by the simple_format rails helper
        text = ''.html_safe if text.nil?
        start_tag = tag('p', html_options, true)

        text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
        text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
        text.insert 0, start_tag

        text.html_safe.safe_concat("</p>")
      end

      def format_syntax_highlighter(text)
        # Support for SyntaxHighlighter (http://alexgorbatchev.com/SyntaxHighlighter/):
        # In WordPress you can (via a plugin) enclose code in [lang][/lang]
        # blocks, which are converted to a <pre>-tag with a class corresponding
        # to the language.
        #
        # Example:
        # [ruby]p "Hello World"[/ruby]
        # -> <pre class="brush: ruby">p "Hello world"</pre>
        text.gsub(/\[(\w+)\](.+?)\[\/\1\]/m, '<pre class="brush: \1">\2</pre>')
      end

      def format_captions(text)
        # Examples:
        # [caption id="attachment_99" align="aligncenter" width="400"]<img src="" /> Hello World[/caption]
        # -> <div class="caption"><img src="" /> <span class="caption-text">Hello world</span></div>
        #
        # [caption id="attachment_99" align="aligncenter" width="400"]<a href=""><img src="" /></a> Hello World[/caption]
        # -> <div class="caption"><a href=""><img src="" /></a> <span class="caption-text">Hello world</span></div>

        caption = text.scan( /\[caption .+?\].+?\[\/caption\]/m )

        caption.each { |c|
          cup = c.dup
          cup.gsub!( /\[caption (.+?)\]/, '<div class="caption" \1>' )
          cup.gsub!( /align="(.+?)"/, 'data-align="\1"' )
          cup.gsub!( /width="(.+?)"/, 'style="width: \1px"' )
          cup.gsub!( / \/> /, ' /> <span class="caption-text">' )
          cup.gsub!( /\[\/caption\]/, '</span></div>' )

          text[ c ] = cup
        }

        text
      end
    end
  end
end
