class PrivacyNoticeResource < Crumble::Resource
  layout ApplicationLayout

  def index
    render PrivacyNoticeView
  end
end
