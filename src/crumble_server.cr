require "./environment"

# Empty service worker for now
register_service_worker

web_manifest do
  name "Hitrace"
  short_name "Hitrace"
  description "Hit the glowing tiles faster than your opponent!"
  display :standalone
  background_color "rgba(2,7,13,1)"
  theme_color "white"

  icon PNGFile.register("logo_192.png", "assets/logo_192.png"), sizes: "192x192"

  # Mobile
  screenshot JPGFile.register("screenshot_game_mobile.jpg", "assets/screenshot_game_mobile.jpg"), label: "Game Grid", sizes: "1080x1946"
  screenshot JPGFile.register("screenshot_game_summary_mobile.jpg", "assets/screenshot_game_summary_mobile.jpg"), label: "Game Summary", sizes: "1080x1946"

  # Desktop
  screenshot PNGFile.register("screenshot_game_desktop.png", "assets/screenshot_game_desktop.png"), label: "Game Grid", sizes: "1919x1016", form_factor: :wide
  screenshot PNGFile.register("screenshot_game_summary_desktop.png", "assets/screenshot_game_summary_desktop.png"), label: "Game Summary", sizes: "1919x1016", form_factor: :wide
end

worker = Crumble::Jobs::Worker.new

spawn do
  worker.start
end

Crumble::Server.start
