class LegalNoticeView
  include Crumble::ContextView

  css_class LegalNotice

  style do
    rule LegalNotice do
      width 750.px
      maxWidth 100.vw
      backgroundColor "#DDD"
      color Black
      padding 15.px
    end

    rule LegalNotice >> a do
      color Black
    end
  end

  template do
    div LegalNotice do
      h1 { "Impressum" }

      p do
        ENV.fetch("LEGAL_NOTICE_NAME")
        br
        ENV.fetch("LEGAL_NOTICE_STREET")
        br
        ENV.fetch("LEGAL_NOTICE_CITY")
      end

      h2 { "Kontakt" }

      p do
        span { "Telefon: " }
        span { ENV.fetch("LEGAL_NOTICE_PHONE") }
        br
        span { "E-Mail: " }
        span { ENV.fetch("LEGAL_NOTICE_EMAIL") }
      end

      h2 { "Verbraucherstreitbeilegung/Universalschlichtungsstelle" }

      p do
        "Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen."
      end

      h2 { "Zentrale Kontaktstelle nach dem Digital Services Act - DSA (Verordnung (EU) 2022/265)" }

      p do
        "Unsere zentrale Kontaktstelle für Nutzer und Behörden nach Art. 11, 12 DSA erreichen Sie wie folgt:"
      end
      p do
        span { "E-Mail: " }
        span { ENV.fetch("LEGAL_NOTICE_EMAIL") }
      end
      p do
        "Die für den Kontakt zur Verfügung stehenden Sprachen sind: Deutsch, Englisch."
      end

      p do
        span { "Quelle: " }
        a href: "https://www.e-recht24.de" do
          "eRecht24"
        end
      end
    end
  end
end
