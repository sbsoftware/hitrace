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
end
