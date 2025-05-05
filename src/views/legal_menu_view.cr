class LegalMenuView
  css_class LegalMenu

  style do
    rule LegalMenu do
      position Absolute
      prop("bottom", 0)
      prop("right", 0)
      padding 10.px
      display Flex
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
