# -*- coding: utf-8 -*-
miquire :mui, 'sub_parts_helper'

require 'gtk2'
require 'cairo'

Plugin.create :sub_parts_client do
  # ツイートが投稿されるのに使われたクライアントアプリケーションの名前をTL上に表示する
  class Gdk::SubPartsClient < Gdk::SubParts
    register

    def initialize(*args)
      super
      @margin = Gdk.scale(2)
      if message and not helper.visible?
        sid = helper.ssc(:expose_event, helper){
          helper.on_modify
          helper.signal_handler_disconnect(sid)
          false } end
    end

    def render(context)
      if helper.visible? and message
        context.save{
          layout = main_message(context)
          context.translate(width - (layout.size[0] / Pango::SCALE) - @margin*2, 0)
          context.set_source_rgb(*(UserConfig[:twitter_tweet_basic_color] || [0,0,0]).map{ |c| c.to_f / 65536 })
          context.show_pango_layout(layout) } end end

    def height
      @height ||= main_message.size[1] / Pango::SCALE end

    private

    def main_message(context = Cairo::Context.dummy)
      layout = context.create_pango_layout
      layout.font_description = helper.font_description(UserConfig[:twitter_tweet_basic_font])
      layout.alignment = Pango::Alignment::RIGHT
      if(message[:source])
        layout.text = (message[:system] ? "by" : "via") + ' ' + message[:source]
      else
        layout.text = '' end
      layout end

    def message
      helper.message end

  end
end
