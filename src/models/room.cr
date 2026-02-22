require "./application_record"
require "./room_player"

class Room < ApplicationRecord
  column name : String
  column game_id : Int64?
  column last_game_started_at : Time?

  has_many_of RoomPlayer
  InvitePreviewImage = JPGFile.register "assets/invite_preview.jpg", "#{__DIR__}/../../assets/screenshot_game_mobile.jpg"

  INVITE_DESCRIPTION  = "Race a friend to hit the glowing target tiles first in quick head-to-head rounds."
  INVITE_HOW_IT_WORKS = "Tap Join game to enter the room. When two players are ready, the game starts automatically."
  INVITE_PREVIEW_ALT  = "Gameplay preview showing the HITRACE target grid"

  def ready?
    game_id.nil? && room_players.size == 2 && room_players.all? do |room_player|
      room_player.ready.value && room_player.online?
    end
  end

  def reset!
    self.game_id = nil
    save

    room_players.each(&.reset!)
  end

  def invite_title : String
    "Join #{name} on HITRACE"
  end

  def invite_description : String
    INVITE_DESCRIPTION
  end

  def invite_how_it_works : String
    INVITE_HOW_IT_WORKS
  end

  def invite_preview_alt : String
    INVITE_PREVIEW_ALT
  end

  def invite_preview_image_uri : String
    "#{Crumble::Server.host}#{InvitePreviewImage.uri_path}"
  end

  model_template :player_list do
    ul do
      room_players.each do |room_player|
        li do
          room_player.player_name
          " "
          if room_player.online?
            "(online)"
          end
          if room_player.ready.value
            " (ready)"
          end
        end
      end
    end
  end

  model_action :set_ready, player_list do
    controller do
      return unless model

      if room_player = model.room_players.find { |rp| rp.user_id == ctx.session.user_id }
        room_player.ready = true
        room_player.save
        RoomMaintenanceJob.enqueue
      end
    end

    view do
      template do
        action_form.to_html do
          GameButton.to_html { "Ready!" }
        end
      end
    end
  end

  accessible RoomPlayer, RoomPage, player_list do
    access_view do
      css_class InviteLanding
      css_class InviteTitle
      css_class InviteDescription
      css_class InviteHowItWorks
      css_class JoinButton
      css_class InvitePreview
      css_class InvitePreviewImage

      style do
        rule InviteLanding do
          display :flex
          flex_direction :column
          align_items :center
          width 100.percent
          max_width 560.px
          gap 14.px
          padding 0, 16.px, 24.px, 16.px
          box_sizing :border_box
        end

        rule InviteTitle do
          margin 0
          text_align :center
          font_size 34.px
        end

        rule InviteDescription do
          margin 0
          display :flex
          justify_content :center
          font_size 18.px
          text_align :center
        end

        rule InviteHowItWorks do
          margin 0
          font_size 16.px
          text_align :center
          max_width 520.px
        end

        rule JoinButton do
          display :flex
          justify_content :center
          margin_top 2.px
        end

        rule JoinButton > form > GameButton::GameButton do
          min_width 180.px
        end

        rule InvitePreview do
          margin 4.px, 0
        end

        rule InvitePreviewImage do
          display :block
          width 100.percent
          max_width 420.px
          border_radius 12.px
          border 1.px, :solid, rgb(255, 255, 255, alpha: 25.percent)
          box_shadow 0.px, 20.px, 40.px, 0.px, rgb(0, 0, 0, alpha: 35.percent)
        end

        media(max_width 800.px) do
          rule InviteTitle do
            font_size 28.px
          end
        end
      end

      template do
        section InviteLanding do
          h1 InviteTitle do
            "Join #{model.name}"
          end

          p InviteDescription do
            model.invite_description
          end

          div JoinButton do
            model.accept_access_action_template(ctx)
          end

          p InviteHowItWorks do
            "How it works: #{model.invite_how_it_works}"
          end

          figure InvitePreview do
            img InvitePreviewImage, src: Room::InvitePreviewImage.uri_path, alt: model.invite_preview_alt, loading: "lazy"
          end
        end
      end
    end

    accept_access_view do
      template do
        GameButton.to_html { "Join game" }
      end
    end

    access_model_attributes user_id: ctx.session.ensure_user.id
  end

  class AccessPage
    class InviteSocialMetaTags
      include Crumble::ContextView

      private def room : Room
        ctx.handler.as(Room::AccessPage).model.not_nil!
      end

      # Open Graph core tags are now provided via Crumble's handler hooks (`og_*` methods below).
      # Keep platform-specific and optional tags here.
      template do
        invite_title = room.invite_title
        invite_description = room.invite_description
        invite_image_uri = room.invite_preview_image_uri
        invite_image_alt = room.invite_preview_alt

        meta name: "description", content: invite_description
        meta property: "og:image:alt", content: invite_image_alt
        meta name: "twitter:card", content: "summary_large_image"
        meta name: "twitter:title", content: invite_title
        meta name: "twitter:description", content: invite_description
        meta name: "twitter:image", content: invite_image_uri
        meta name: "twitter:image:alt", content: invite_image_alt
      end
    end

    layout ApplicationLayout do
      def head_children
        super + {InviteSocialMetaTags.new(ctx: ctx)}
      end
    end

    def window_title : String?
      model.try(&.invite_title)
    end

    def og_title : String?
      model.try(&.invite_title)
    end

    def og_description : String?
      model.try(&.invite_description)
    end

    def og_image : String?
      model.try(&.invite_preview_image_uri)
    end

    def og_url : String?
      model.try(&.share_uri)
    end

    def og_type : String?
      "website"
    end

    def og_site_name : String?
      "HITRACE"
    end
  end
end
