# ▼▲▼ XRXS 9. メッセ表示フルグレ「追加制御文字」 ▼▲▼ built 192000
# by 桜雅 在土    (\pass)
#    和希, RaTTiE (\V, \e, \R)

#==============================================================================
# □ カスタマイズポイント
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # 外字
  #--------------------------------------------------------------------------
  GAIJI_FILE          = "gaiji.png" # ピクチャファイル名
  GAIJI_SIZE          =  24         # 外字一文字のサイズ
end
#==============================================================================
# ■ Interpreter
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # ○ 停止中を装う
  #--------------------------------------------------------------------------
  def pretend_stopping=(b)
    @pretend_stopping = b
  end
  #--------------------------------------------------------------------------
  # ● 実行中判定
  #--------------------------------------------------------------------------
  alias xrxs9_running? running?
  def running?
    return (not @pretend_stopping and xrxs9_running?)
  end
end
#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias xrxs9_update update
  def update
    # メッセージ中移動で無い場合
    return xrxs9_update unless @messaging_moving
    # 変更
    last_showing = $game_temp.message_window_showing
    $game_system.map_interpreter.pretend_stopping = true
    $game_temp.message_window_showing = false
    # 呼び戻す
    xrxs9_update
    # 復旧
    $game_temp.message_window_showing = last_showing
    $game_system.map_interpreter.pretend_stopping = nil
  end
end
#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● イベント起動
  #--------------------------------------------------------------------------
  alias xrxs9_start start
  def start
    # 呼び戻す
    xrxs9_start
    # 実行された場合 かつ プレイヤーがメッセージ移動中の場合
    if @starting and $game_player.messaging_moving
      $game_player.messaging_moving = false
    end
  end
end
#------------------------------------------------------------------------------
#
#
# ▽ 追加制御文字の描画機能 [独立]
#     (by 和希, RaTTiE)
#
#
#==============================================================================
# ■ Window_Message
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ 外字描画
  #--------------------------------------------------------------------------
  # x　　 ：ｘ座標
  # y　　 ：ｙ座標
  # num　 ：外字番号
  # 返り値：外字幅(@x増加値)
  #--------------------------------------------------------------------------
  def draw_gaiji(x, y, num)
    # 外字キャッシュが存在しない場合
    if @gaiji_cache == nil
      # 外字データ読み込み
      if RPG_FileTest.picture_exist?(GAIJI_FILE)
        @gaiji_cache = RPG::Cache.picture(GAIJI_FILE)
      else
        return 0
      end
    end
    # 指定した外字がキャッシュ範囲を超えている場合は何もしない
    if @gaiji_cache.width < num * GAIJI_SIZE
      return 0
    end
    # 文字サイズを取得
    size = GAIJI_SIZE
    # 外字データをstretch_bltで転送
    self.contents.stretch_blt(Rect.new(x, y, size, size), @gaiji_cache, Rect.new(num * GAIJI_SIZE, 0, GAIJI_SIZE, GAIJI_SIZE))
    # 文字描写のSEを演奏
    if SOUNDNAME_ON_SPEAK != "" then
      Audio.se_play(SOUNDNAME_ON_SPEAK)
    end
    # 文字サイズを返す
    return size
  end
  #--------------------------------------------------------------------------
  # ○ \V変換
  #--------------------------------------------------------------------------
  # option ：オプション。無指定又は規定外の場合はindexのユーザ変数値を返す。
  # index  ：インデックス
  # 返り値 ：変換結果(アイコン表示用シーケンス込み)
  #--------------------------------------------------------------------------
  def convart_value(option, index)
    # optionがnilの場合は""に直す(誤動作防止)
    option == nil ? option = "" : nil

    # optionはdowncaseしておく。
    option.downcase!

    # \030はアイコン表示用のシーケンス。\030[アイコンファイル名]で定義。
    case option
    when "i"
      unless $data_items[index].name == nil
        r = sprintf("\030[%s]%s", $data_items[index].icon_name, $data_items[index].name)
      end
    when "w"
      unless $data_weapons[index].name == nil
        r = sprintf("\030[%s]%s", $data_weapons[index].icon_name, $data_weapons[index].name)
      end
    when "a"
      unless $data_armors[index].name == nil
        r = sprintf("\030[%s]%s", $data_armors[index].icon_name, $data_armors[index].name)
      end
    when "s"
      unless $data_skills[index].name == nil
        r = sprintf("\030[%s]%s", $data_skills[index].icon_name, $data_skills[index].name)
      end
    else
      r = $game_variables[index]
    end

    r == nil ? r = "" : nil
    return r
  end
end
#==============================================================================
# --- ルビ ---
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ ルビ文字 の処理
  #--------------------------------------------------------------------------
  def process_ruby
    @now_text.sub!(/\[(.*?)\]/, "")
    # 文字とルビを描画
    x = @x
    y = @y * line_height
    w = 40
    h = line_height
    @x += self.contents.draw_ruby_text(x, y, w, h, $1)
  end
end
class Bitmap
  #--------------------------------------------------------------------------
  # ○ ルビ文字描画
  #--------------------------------------------------------------------------
  # x      ：x座標
  # y      ：y座標
  # str　  ：描画文字列。本文,ルビの形式で入力。
  # 　　　　 ,区切りが2つ以上あった場合は自動的に無視される。
  # 返り値 ：文字幅(@x増加値)。
  #--------------------------------------------------------------------------
  def draw_ruby_text(x, y, w, h, str)
    # フォントサイズをバックアップしておく
    sizeback = self.font.size
    # ルビサイズの計算
    self.font.size * 3 / 2 > 32 ? rubysize = 32 - self.font.size : rubysize = self.font.size / 2
    rubysize = [rubysize, 6].max
    
    # strをsplitで分割し、split_sに格納
    split_s = str.split(/,/)
    # split_sがnilの場合は""にしておく(誤動作防止)
    split_s[0] = "" if split_s[0] == nil
    split_s[1] = "" if split_s[1] == nil
    
    # heightとwidthを計算
    height = sizeback + rubysize
    width  = self.text_size(split_s[0]).width

    # バッファ用の幅計算(ルビの幅が本文の幅を越える可能性がある為)
    self.font.size = rubysize
    ruby_width = self.text_size(split_s[1]).width
    self.font.size = sizeback

    buf_width = [self.text_size(split_s[0]).width, ruby_width].max

    # 本文の描画幅とルビの描画幅の差を1/2にして変数に格納(後で使用)
    width - ruby_width != 0 ? sub_x = (width - ruby_width) / 2 : sub_x = 0

    # ルビの描画
    self.font.size = rubysize
    self.draw_text(x + sub_x, 4 + y - self.font.size, self.text_size(split_s[1]).width, self.font.size, split_s[1])
    self.font.size = sizeback
    # 本文の描画
    self.draw_text(x, y, width, h, split_s[0])
    return width
  end
end

