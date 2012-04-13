module GitHub::HTML
  # This filter rewrites image tags with a max-width inline style and also wraps
  # the image in an <a> tag that causes the full size image to be opened in a
  # new tab.
  #
  # The max-width inline styles are especially useful in HTML email which
  # don't use a global stylesheets.
  class ImageMaxWidthFilter < Filter
    def call
      doc.search('img').each do |element|
        # Skip if theres already a style attribute. Not sure how this
        # would happen but we can reconsider it in the future.
        next if element['style']

        # Bail out if src doesn't look like a valid http url. tryna avoid weird
        # js injection via javascript: urls.
        next if element['src'].to_s.strip =~ /\Ajavascript/i

        element['style'] = "max-width:100%;"

        if !has_ancestor?(element, %w(a))
          link_image element
        end
      end

      doc
    end

    def link_image(element)
      parent = element.parent
      link = doc.document.create_element('a', :href => element['src'], :target => '_blank')
      link.add_child element.remove
      parent.add_child link
    end
  end
end
