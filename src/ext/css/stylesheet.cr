require "crumble"

class CSS::Stylesheet
  def self.outline_shadow(color, depth)
    ([] of String).tap do |arr|
      (-depth..depth).each do |i|
        (-depth..depth).each do |j|
          arr << "#{i}px #{j}px 0px #{color}"
        end
      end
    end.join(", ")
  end

  # Emit a plain CSS comment at the current position in the stylesheet.
  macro comment(text)
    def self.to_s(io : IO)
      {% if @type.class.methods.map(&.name.stringify).includes?("to_s") %}
        previous_def
        io << "\n\n"
      {% end %}

      io << "/* "
      io << {{text}}
      io << " */"
    end
  end

  ToHtml.class_template do
    link self
  end
end
