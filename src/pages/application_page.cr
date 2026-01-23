require "../views/application_layout"

abstract class ApplicationPage < Crumble::Page
  layout ApplicationLayout

  def redirect(new_path)
    ctx.response.status_code = 303
    ctx.response.headers["Location"] = new_path
  end
end
