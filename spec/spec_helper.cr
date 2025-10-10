require "spec"
File.delete("./test.db")
require "../src/environment"
require "crumble/spec/test_handler_context"

{% for orm_class in Orma::Record.all_subclasses %}
  {% if !orm_class.abstract? %}
    {{orm_class.id}}.continuous_migration!
  {% end %}
{% end %}

class String
  def squish
    gsub(/\n\s*/, "")
  end
end

class ApplicationRecord
  def self.db_connection_string
    "sqlite3://./test.db"
  end
end
