require "sqlite3"
require "orma"
require "crumble-turbo"
require "./ext/**"
require "./models/*"
require "./views/*"
require "./resources/*"
require "./styles/*"

if ENV.fetch("ORMA_CONTINUOUS_MIGRATION", "").in?(["1", "true"])
  {% for orm_class in Orma::Record.all_subclasses %}
    {% if !orm_class.abstract? %}
      {{orm_class.id}}.continuous_migration!
    {% end %}
  {% end %}
end

spawn do
  loop do
    Game.all.find_each do |game|
      next if game.hit_targets.count >= 2

      if game_id = game.id
        new_target = HitTarget.new(game_id: game_id, pos_x: rand(1..game.size_x.value), pos_y: rand(1..game.size_y.value))
        new_target.save
      end

      Crumble::Turbo::ModelTemplateRefreshService.notify(game.grid)
    end

    sleep 1.second
  end
end

Crumble::Server.start
