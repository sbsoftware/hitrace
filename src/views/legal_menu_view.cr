class LegalMenuView
  css_class LegalMenu

  style do
    rule LegalMenu do
      position :absolute
      bottom 0
      right 0
      padding 10.px
      display :flex
    end
  end

  ToHtml.class_template do
    div LegalMenu do
      a PrivacyNoticeResource do
        "Datenschutz"
      end
      "&nbsp;|&nbsp;"
      a LegalNoticeResource do
        "Impressum"
      end
    end
  end
end
