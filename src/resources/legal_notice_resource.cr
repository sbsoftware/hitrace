class LegalNoticeResource < Crumble::Resource
  layout ApplicationLayout

  def index
    render LegalNoticeView
  end
end
