# ▼▲▼ XRXS 9. メッセージ表示フルグレードアップ ver.2 ▼▲▼
# by 桜雅 在土
#
# update 2007/ 1/16
#
#==============================================================================
# □ カスタマイズポイント
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # フォント設定
  #--------------------------------------------------------------------------
  DEFAULT_FONT_NAME      =  ["ＭＳ Ｐゴシック", "Tahoma"]       # 文章部分の文字フォント ( "" で無変更 )
  DEFAULT_FONT_SIZE      =  20      # 標準文字サイズ( 22が初期設定 )
  DEFAULT_LINE_SPACE     =  26      # 標準行間　　　( 32が初期設定 )
  #--------------------------------------------------------------------------
  # 基本メッセージウィンドウ
  #--------------------------------------------------------------------------
  DEFAULT_BG_PICTURE     = ""       # 背景ピクチャ ( "" で使用しない )
  DEFAULT_BG_X           =   0      # 背景ピクチャ X 位置
  DEFAULT_BG_Y           = 320      # 背景ピクチャ Y 位置
  DEFAULT_RECT           = Rect.new(80, 304, 496, 160)
  DEFAULT_BACK_OPACITY   = 255      # ウィンドウの不透明度
  DEFAULT_STRETCH_ENABLE = true     # 五行以上の場合自動的にサイズを変更する
  #--------------------------------------------------------------------------
  # インフォメーションウィンドウ
  #--------------------------------------------------------------------------
  INFO_RECT              = Rect.new(-16, 64, 672, DEFAULT_LINE_SPACE + 32)
  #--------------------------------------------------------------------------
  # 一文字ずつ描写 (falseにすると同時に全表示)
  #--------------------------------------------------------------------------
  DEFAULT_TYPING_ENABLE = true
  DEFAULT_TYPING_SPEED  = 0.2
  #--------------------------------------------------------------------------
  # 高速スキップ／タイピングスキップ
  #--------------------------------------------------------------------------
  KEY_SHOW_ALL          = Input::B # タイピングスキップ(残りを瞬間表示)
  KEY_MESSAGE_SKIP      = Input::L # 高速スキップ
  #
  # 高速スキップを有効にするスイッチのID.( 0 は常時可能)
  #
  HISKIP_ENABLE_SWITCH_ID = 0
  #
  # 高速スキップ・タイピングスキップを共に禁止するスイッチのID. ( 0 は常時可能)
  #
  SKIP_BAN_SWITCH_ID      = 0
  #--------------------------------------------------------------------------
  # 顔グラフィック
  #--------------------------------------------------------------------------
  FACE_STRETCH_ENABLE    = false     # 顔グラフィックを↓指定のサイズに拡大する。
  FACE_WIDTH             =  96      # 拡大後の「幅｣
  FACE_HEIGHT            =  96      # 拡大後の「高さ｣
  #--------------------------------------------------------------------------
  # キャラポップ
  #--------------------------------------------------------------------------
  CHARPOP_HEIGHT         =  56      # キャラポップの高さ
end
module XRXS9
  #--------------------------------------------------------------------------
  # ネームウィンドウ
  #--------------------------------------------------------------------------
  NAME_WINDOW_TEXT_COLOR  = Color.new(192,240,255,255) # \name ウィンドウ文字色
  NAME_WINDOW_TEXT_SIZE   =  20     # \name ウィンドウの文字サイズ
  NAME_WINDOW_SPACE       =  10     # \name ウィンドウの余白
  NAME_WINDOW_OFFSET_X    =   0     # \name ウィンドウのオフセット位置 X
  NAME_WINDOW_OFFSET_Y    = -26     # \name ウィンドウのオフセット位置 Y
  #--------------------------------------------------------------------------
  # 終了時フェードアウト (Fade Out Before Terminate)
  #--------------------------------------------------------------------------
  FOBT_DURATION           =  20     # \fade を指定した時のフェード持続時間 
end
#==============================================================================
# --- セリフ効果音 ---
#        $game_system.speak_se = RPG::AudioFile.new("")と設定し使用します。
#==============================================================================
class Game_System
  attr_accessor :speak_se
  def speak_se_play
    self.se_play(self.speak_se) if self.speak_se != nil
  end
end
class Window_Message < Window_Selectable
  # 文字描画SE除外文字
  NOT_SOUND_CHARACTERS = [" ", "　", "・", "、", "。", "─"]
end
#==============================================================================
# □ Sprite_Pause
#==============================================================================
class Sprite_Pause < Sprite
  def initialize
    super
    self.bitmap = RPG::Cache.windowskin($game_system.windowskin_name)
    self.x = 604
    self.y = 456
    self.z = 6001
    @count = 0
    @wait_count = 0
    update
  end
  def update
    super
    if @wait_count > 0
      @wait_count -= 1
    else
      @count = (@count + 1)%4
      x = 160 + @count % 2
      y =  64 + @count / 2
      self.src_rect.set(x, y, 16, 16)
      @wait_count = 4
    end
  end
end
#==============================================================================
# ■ Window_Message
#==============================================================================
class Window_Message < Window_Selectable
  # 定数
  AUTO   = 0
  LEFT   = 1
  CENTER = 2
  RIGHT  = 3
  #--------------------------------------------------------------------------
  # ○ line_height : 行の高さ(@y増加値)を返します。
  #--------------------------------------------------------------------------
  def line_height
    return DEFAULT_LINE_SPACE
  end
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias xrxs9_initialize initialize
  def initialize
    # 初期化
    @stand_pictuers = []
    @held_windows = []
    @extra_windows = []
    @extra_sprites = []
    # ポーズサインの作成
    @pause = Sprite_Pause.new
    # 呼び戻す
    xrxs9_initialize
    # ポーズサインの設定
    @pause.visible = false
    @pause.z = self.z + 1
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias xrxs9_dispose dispose
  def dispose
    # ホールドされたウィンドウを開放
    @held_windows.each {|window| window.dispose}
    @held_windows.clear
    # ポーズサイン
    @pause.dispose
    # 外字キャッシュ開放
    if @gaiji_cache != nil
      @gaiji_cache.dispose
      @gaiji_cache = nil
    end
    # 呼び戻す
    xrxs9_dispose
  end
  #--------------------------------------------------------------------------
  # ● メッセージ終了処理
  #--------------------------------------------------------------------------
  alias xrxs9_terminate_message terminate_message
  def terminate_message
    # 素通りフラグをクリア
    @passable = false
    $game_player.messaging_moving = false
    # 背景ピクチャを解放
    if @bgframe_sprite != nil
      @bgframe_sprite.dispose
    end
    # ウィンドウホールド
    if @window_hold
      # ウィンドウやスプライトの複製を作成
      @held_windows.push(Window_Copy.new(self))
      for window in @extra_windows
        next if window.disposed?
        @held_windows.push(Window_Copy.new(window))
      end
      for sprite in @extra_sprites
        next if sprite.disposed?
        @held_windows.push(Sprite_Copy.new(sprite))
      end
      # 設定をクリア
      self.opacity = 0
      self.contents_opacity = 0
      @extra_windows.clear
      @extra_sprites.clear
    else
      # ホールドされたウィンドウを開放
      @held_windows.each {|object| object.dispose}
      @held_windows.clear
    end
    # ネームウィンドウらを解放
    if @name_window_frame != nil
      @name_window_frame.dispose
      @name_window_frame = nil
    end
    if @name_window_text  != nil
      @name_window_text.dispose
      @name_window_text  = nil
    end
    # 呼び戻す
    xrxs9_terminate_message
  end
  #--------------------------------------------------------------------------
  # ○ ポップキャラクターの設定と取得
  #--------------------------------------------------------------------------
  def pop_character=(character_id)
    @pop_character = character_id
  end
  def pop_character
    return @pop_character
  end
  #--------------------------------------------------------------------------
  # ○ クリア
  #--------------------------------------------------------------------------
  def clear
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size  = DEFAULT_FONT_SIZE
    self.contents.font.name = DEFAULT_FONT_NAME if DEFAULT_FONT_NAME != ""
    self.opacity          = 255
    self.back_opacity     = DEFAULT_BACK_OPACITY
    self.contents_opacity = 255
    @mid_stop     = false       # \!    　　の中断中フラグ
    @face_file    = nil         # \f    　　の顔ファイル
    @current_name = nil         # \name 　　のネーム保持
    @window_hold  = false       # \hold 　　のウィンドウホールドのフラグ
    @stand_pictuer_hold = false # \picthold のスタンドピクチャの保持フラグ
    @passable     = false       # \pass 　　の素通り可能フラグ
    @inforesize   = false       # \info　　 のインフォリサイズ
    # 固定設定をロード
    @auto_align   = LEFT         # 基本位置揃え
    @default_rect = DEFAULT_RECT # 基本メッセージウィンドウ矩形
    @default_rect = DEFAULT_RECT # 基本メッセージウィンドウ矩形
    # あと残りのここらへんのものを全て 0 で初期化
    @x = @y = @indent = @line_index = 0
    @cursor_width = @write_wait = @lines_max = 0
    # タイピングスピードを取得
    @write_speed = DEFAULT_TYPING_SPEED
    # 各行の描画幅＆位置揃え設定初期化
    @line_widths = []
    @line_aligns = []
    # self.pop_character が nil の場合、標準位置。-1の場合、文字センター。
    # 0以上の場合　キャラポップ。0は主人公、1以降はイベント。
    self.pop_character = nil
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ [再定義]
  #--------------------------------------------------------------------------
  def refresh
    # ビットマップの取得と設定
    if DEFAULT_BG_PICTURE != ""
      bitmap = RPG::Cache.picture(DEFAULT_BG_PICTURE)
      @bgframe_sprite = Sprite.new
      @bgframe_sprite.x = DEFAULT_BG_X
      @bgframe_sprite.y = DEFAULT_BG_Y
      @bgframe_sprite.bitmap = bitmap
      @bgframe_sprite.z += 5
    end
    # 初期化
    self.clear
    # 表示待ちのメッセージがある場合
    if $game_temp.message_text != nil
      @now_text = $game_temp.message_text
      # 改行削除指定\_があるか？
      if (/\\_\n/.match(@now_text)) != nil
        $game_temp.choice_start -= 1
        @now_text.gsub!(/\\_\n/) { "" }
      end
      # 顔表示指定\Fがあるか？
      if (/\\[Ff]\[(.+?)(?:,(\d+))?\]/.match(@now_text)) != nil
        # ファイルチェック
        if RPG_FileTest.picture_exist?($1)
          # フェイスファイルを設定
          if $game_switches[47] == true
            @face_file = $1 + ".png"
          else
            if $game_switches[76] == true
              if RPG_FileTest.picture_exist?($1 + "s")
                @face_file = $1 + "s.png"
              else
                @face_file = $1 + ".png"
              end
            else
              if RPG_FileTest.picture_exist?($1 + "2")
                @face_file = $1 + "2.png"
              else
                @face_file = $1 + ".png"
              end
            end
          end
          @face_index = $2.to_i
          # 全行インデントを入れる。
          src = RPG::Cache.picture(@face_file)
          if FACE_STRETCH_ENABLE
            @indent += FACE_WIDTH
          elsif $2 == nil
            @indent += src.width
            @face_index = -1
          else
            @indent += src.width/4
          end
        end
        @now_text.gsub!(/\\[Ff]\[(.*?)\]/) { "" }
      end
      # インフォ判定
      @inforesize = (@now_text.gsub!(/\\info/) { "" } != nil)
      # ウィンドウ保持指定\holdがあるか？
      @window_hold = (@now_text.gsub!(/\\hold/) { "" } != nil)
      # \vの即時変換
      @now_text.gsub!(/\\[v]\[([0-9]+)\]/) { $game_variables[$1.to_i].to_s }
      # \Vを独自ルーチンに変更(追加部分)
      begin
        last_text = @now_text.clone
        @now_text.gsub!(/\\[V]\[([IiWwAaSs]?)([0-9]+)\]/) { convart_value($1, $2.to_i) }
      end until @now_text == last_text
      @now_text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # \name 判定
      if @now_text.sub!(/\\[Nn]ame\[(.*?)\]/) { "" }
        @current_name = $1
      end
      # ウィンドウポップ判定
      if @now_text.gsub!(/\\[Pp]\[([0-9]+)\]/) { "" }
        self.pop_character = $1.to_i
      end
      # 改行指定
      if (/\\n/.match(@now_text)) != nil
        $game_temp.choice_start += 1
        @now_text.gsub!(/\\n/) { "\n" }
      end
      # フェード判定
      if @now_text.gsub!(/\\fade/) { "" }
        @fade_count_before_terminate = XRXS9::FOBT_DURATION
      end
      # 素通り判定
      if @now_text.gsub!(/\\pass/) { "" }
        @passable = true
        $game_player.messaging_moving = true
      end
      # 末尾連続改行を削除
      nil while( @now_text.sub!(/\n\n\z/) { "\n" } )
      # 行数の取得
      @lines_max = @now_text.scan(/\n/).size
      # 現在搭載されている制御文字を配列化
      rxs = [/\\\w\[(\w+)\]/, /\\[.]/, /\\[|]/, /\\[>]/, /\\[<]/, /\\[!]/,
              /\\[~]/, /\\[i]/, /\\[Oo]\[([0-9]+)\]/, /\\[Hh]\[([0-9]+)\]/,
              /\\[b]\[([0-9]+)\]/, /\\[Rr]\[(.*?)\]/, /\\[B]/, /\\[I]/]
      @max_choice_x = 0
      # インフォウィンドウの強制センタリング
      @line_aligns[0] = CENTER if @inforesize
      #
      # [行ごとの設定]
      #
      lines = @now_text.split(/\n/)
      for i in 0..@lines_max
        # 行の取得 (インデックスは逆順)
        line = lines[@lines_max - i]
        # 空白行の場合は次へ
        next if line == nil
        # 制御文字を削る
        line.gsub!(/\\[Ee]\[([0-9]+)\]/) { "\022[#{$1}]" }
        for rx in rxs
          line.gsub!(rx) { "" }
        end
        # 位置揃えを取得
        @line_aligns[@lines_max - i] =
          line.sub!(/\\center/) {""} ? CENTER :
          line.sub!(/\\right/)  {""} ? RIGHT :
          line.sub!(/\\left/)   {""} ? LEFT :
                                       AUTO
        # 行の横幅の取得と設定
        cx = contents.text_size(line).width
        @line_widths[@lines_max - i] = cx
      end
      # 選択肢行以降の最大横幅を取得
      choices = @line_widths[$game_temp.choice_start, @line_widths.size]
      @max_choice_x = choices == nil ? 0 : choices.max + 8
      # 位置揃え制御文字の削除
      @now_text.gsub!(/\\center/) {""}
      @now_text.gsub!(/\\right/) {""}
      @now_text.gsub!(/\\left/) {""}
      # キャラポップ時のウィンドウリサイズ
      if self.pop_character != nil and self.pop_character >= 0
        max_x = @line_widths.max.to_i
        self.width = max_x + 32 + @indent + DEFAULT_FONT_SIZE/2
        self.height = [@lines_max * line_height, @indent].max  + 32
      end
      #
      # 「変換」
      #
      # 便宜上、"\\\\" を "\000" に変換
      @now_text.gsub!(/\\\\/) { "\000" }
      # "\\C" を "\001" に、"\\G" を "\002" に、
      # "\\S" を "\003" に、"\\A" を "\004" に変換
      @now_text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      @now_text.gsub!(/\\[Gg]/) { "\002" }
      @now_text.gsub!(/\\[Ss]\[([0-9]+)\]/) { "\003[#{$1}]" }
      @now_text.gsub!(/\\[Aa]\[(.*?)\]/) { "\004[#{$1}]" }
      @now_text.gsub!(/\\[.]/) { "\005" }
      @now_text.gsub!(/\\[|]/) { "\006" }
      # 競合すると何かと気まずいので、\016以降を使用する
      @now_text.gsub!(/\\[>]/) { "\016" }
      @now_text.gsub!(/\\[<]/) { "\017" }
      @now_text.gsub!(/\\[!]/) { "\020" }
      @now_text.gsub!(/\\[~]/) { "\021" }
      @now_text.gsub!(/\\[Ee]\[([0-9]+)\]/) { "\022[#{$1}]" }
      # インデント設定(追加部分)
      @now_text.gsub!(/\\[i]/) { "\023" }
      # テキスト透過率指定(追加部分)
      @now_text.gsub!(/\\[Oo]\[([0-9]+)\]/) { "\024[#{$1}]" }
      # テキストサイズ指定(追加部分)
      @now_text.gsub!(/\\[Hh]\[([0-9]+)\]/) { "\025[#{$1}]" }
      # 空白挿入(追加部分)
      @now_text.gsub!(/\\[b]\[([0-9]+)\]/) { "\026[#{$1}]" }
      # ルビ表示(追加部分)
      @now_text.gsub!(/\\[Rr]\[(.*?)\]/) { "\027[#{$1}]" }
      # Font.bold
      @now_text.gsub!(/\\[B]/) { "\031" }
      # Font.italic
      @now_text.gsub!(/\\[I]/) { "\032" }
      # ここで一旦ウィンドウ位置更新
      reset_window
      #
      # \nameがあるか？～「ネームウィンドウの作成」
      #
      if @current_name != nil
        # フォントを一時設定
        self.contents.font.size = XRXS9::NAME_WINDOW_TEXT_SIZE
        # 枠だけウィンドウの作成
        x = self.x + XRXS9::NAME_WINDOW_OFFSET_X
        y = self.y + XRXS9::NAME_WINDOW_OFFSET_Y
        w = self.contents.text_size(@current_name).width + 8 + XRXS9::NAME_WINDOW_SPACE
        h = 26 + XRXS9::NAME_WINDOW_SPACE
        @name_window_frame = Window_Base.new(x, y, w, h)
        @name_window_frame.opacity = 160
        @name_window_frame.z = self.z + 2
        # 擬似的な空中文字描写(ウィンドウ使用)を作成
        x = self.x + XRXS9::NAME_WINDOW_OFFSET_X + 3 + XRXS9::NAME_WINDOW_SPACE / 2
        y = self.y + XRXS9::NAME_WINDOW_OFFSET_Y + 1 + XRXS9::NAME_WINDOW_SPACE / 2
        @name_window_text = Air_Text.new(x,y, @current_name, XRXS9::NAME_WINDOW_TEXT_SIZE, XRXS9::NAME_WINDOW_TEXT_COLOR)
        @name_window_text.z = self.z + 3
        # フォントを復旧
        self.contents.font.size = DEFAULT_FONT_SIZE
        # エクストラウィンドウに登録
        @extra_windows.push(@name_window_frame)
        @extra_windows.push(@name_window_text)
      end
    end
    # ウィンドウを更新
    reset_window
    # コンテンツの再作成
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    self.contents.font.color = normal_color
    self.contents.font.name = DEFAULT_FONT_NAME if DEFAULT_FONT_NAME != ""
    unless @face_file.nil?
      # 顔グラを描画
      src = RPG::Cache.picture(@face_file)
      if @face_index == -1
        w = src.width
        h = src.height
        x = 0
        y = 0
      else
        w = src.width/4
        h = src.height/4
        x = (@face_index-1) % 4 * w
        y = (@face_index-1) / 4 * h
      end
      if FACE_STRETCH_ENABLE
        self.contents.stretch_blt(Rect.new(0,0,FACE_WIDTH,FACE_HEIGHT), src, Rect.new(x, y, w, h))
      else
        self.contents.blt(0, 0, src, Rect.new(x, y, w, h))
      end
    end
    #
    # 選択肢の場合
    #
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    #
    # 数値入力の場合
    #
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8 + @indent
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
    # フォントサイズを再設定
    self.contents.font.size  = DEFAULT_FONT_SIZE
    # 行初期化
    line_reset
    # 瞬間表示の場合はこのままフレーム更新へ
    update unless DEFAULT_TYPING_ENABLE
  end
  #--------------------------------------------------------------------------
  # ○ 行初期化
  #--------------------------------------------------------------------------
  def line_reset
    # 位置揃えの取得
    align = @line_aligns[@line_index]
    align = @auto_align if align == AUTO
    case align
    when LEFT
      @x  = @indent
      @x += 8 if $game_temp.choice_start <= @line_index
    when CENTER
      @x = self.width / 2 - 16 - @line_widths[@line_index].to_i / 2
    when RIGHT
      @x = self.width - 40 - @line_widths[@line_index].to_i
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 [再定義]
  #--------------------------------------------------------------------------
  def update
    # メッセージ素通り中にイベントが開始した場合
    if @passable and not $game_player.messaging_moving
      self.opacity = 0
      terminate_message
      return
    end
    # ポーズサイン
    @pause.update if @pause.visible
    # 呼び戻す
    super
    # フレーム更新↓
    update_main
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update_main
    # 動きに対応
    if !self.pop_character.nil? and self.pop_character >= 0
      update_reset_window
    end
    # フェードインの場合
    if skippable_now? and Input.press?(KEY_MESSAGE_SKIP)
      self.contents_opacity = 255
      @fade_in = false
    elsif @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    @now_text = nil if @now_text == "" # 変換
    # 表示待ちのメッセージがある場合
    if @now_text != nil and @mid_stop == false
      if @write_wait > 0
        @write_wait -= 1
        return
      end
      text_not_skip = DEFAULT_TYPING_ENABLE
      while true
        # c に 1 文字を取得 (文字が取得できなくなるまでループ)
        if (c = @now_text.slice!(/./m)) != nil
          # \\ の場合
          if c == "\000"
            # 本来の文字に戻す
            c = "\\"
          end
          # \C[n] の場合
          if c == "\001"
            # 文字色を変更
            @now_text.sub!(/\[([0-9]+)\]/, "")
            color = $1.to_i
            if color >= 0 and color <= 7
              self.contents.font.color = text_color(color)
              if @opacity != nil
                color = self.contents.font.color
                self.contents.font.color = Color.new(color.red, color.green, color.blue, color.alpha * @opacity / 255)
              end
            end
            # 次の文字へ
            c = ""
          end
          # \G の場合
          if c == "\002"
            # ゴールドウィンドウを作成
            if @gold_window == nil
              @gold_window = Window_Gold.new
              @gold_window.x = 560 - @gold_window.width
              if $game_temp.in_battle
                @gold_window.y = 192
              else
                @gold_window.y = self.y >= 128 ? 32 : 384
              end
              @gold_window.opacity = self.opacity
              @gold_window.back_opacity = self.back_opacity
            end
            # 次の文字へ
            c = ""
          end
          # \S[n] の場合
          if c == "\003"
            # 文字色を変更
            @now_text.sub!(/\[([0-9]+)\]/, "")
            speed = $1.to_i
            if speed >= 0 and speed <= 19
              @write_speed = speed
            end
            # 次の文字へ
            c = ""
          end
          # \. の場合
          if c == "\005"
            @write_wait += 5
            c = ""
          end
          # \| の場合
          if c == "\006"
            @write_wait += 20
            c = ""
          end
          # \> の場合
          if c == "\016"
            text_not_skip = false
            c = ""
          end
          # \<の場合
          if c == "\017"
            text_not_skip = true
            c = ""
          end
          # \!の場合
          if c == "\020"
            @mid_stop = true
            c = ""
          end
          # \~の場合
          if c == "\021"
            terminate_message
            return
          end
          # \Iの場合(追加部分)
          if c == "\023"
            # 今の@xをインデント位置に設定
            @indent = @x
            c = ""
          end
          # \Oの場合(追加部分)
          if c == "\024"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            @opacity = $1.to_i
            color = self.contents.font.color
            self.contents.font.color = Color.new(color.red, color.green, color.blue, color.alpha * @opacity / 255)
            c = ""
          end
          # \Hの場合(追加部分)
          if c == "\025"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            self.contents.font.size = [[$1.to_i, 6].max, 32].min
            c = ""
          end
          # \Bの場合(追加部分)
          if c == "\026"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            @x += $1.to_i
            c = ""
          end
          # \Rの場合「ルビ」
          if c == "\027"
            process_ruby
            # 文字描写のSEを演奏
            $game_system.speak_se_play
            c = ""
          end
          # アイコン描画用シーケンスの場合(追加部分)
          if c == "\030"
            # アイコンファイル名を取得
            @now_text.sub!(/\[(.*?)\]/, "")
            # アイコンを描画
            self.contents.blt(@x , @y * line_height + 8, RPG::Cache.icon($1), Rect.new(0, 0, 24, 24))
            @x += 24
            # 次の文字へ
            c = ""
          end
          #
          # 改行文字の場合
          #
          if c == "\n"
            # y に 1 を加算
            @y += 1
            #
            # 次の行へ (改行処理 + X位置設定)
            #
            @line_index += 1
            line_reset
            # 選択肢ならカーソルの更新
            if @line_index >= $game_temp.choice_start
              @cursor_width = @max_choice_x
            end
            # 次の文字へ
            c = ""
          end
          # 外字表示の場合
          if c == "\022"
            # []部分の除去
            @now_text.sub!(/\[([0-9]+)\]/, "")
            # 外字を表示
            @x += draw_gaiji(4 + @x, @y * line_height + (line_height - self.contents.font.size), $1.to_i)
            # 次の文字へ
            c = ""
          end
          # Font.boldの場合 (排他的論理和での反転)
          if c == "\031"
            self.contents.font.bold ^= true
            c = ""
          end
          # Font.italicの場合
          if c == "\032"
            self.contents.font.italic ^= true
            c = ""
          end
          if c != ""
            # 文字を描画
            self.contents.draw_text(4+@x, line_height * @y, 40, line_height, c)
            @x += self.contents.text_size(c).width
            # 文字描写のSEを演奏
            unless NOT_SOUND_CHARACTERS.include?(c)
              $game_system.speak_se_play
            end
          end
          # Bボタンが押された場合
          if skippable_now? and 
            (Input.press?(KEY_SHOW_ALL) or Input.press?(KEY_MESSAGE_SKIP)) and 
            (SKIP_BAN_SWITCH_ID == 0 ? true : !$game_switches[SKIP_BAN_SWITCH_ID])
            text_not_skip = false
          end
        else
          text_not_skip = true
          break
        end
        # 終了判定
        break if text_not_skip
      end
      @write_wait += @write_speed
      return
    end
    # 数値入力中の場合
    if @input_number_window != nil
      @input_number_window.update
      # 決定
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] = @input_number_window.number
        $game_map.need_refresh = true
        # 数値入力ウィンドウを解放
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    #
    # メッセージ表示中の場合
    #
    if @contents_showing
      # 終了前フェーズでない場合
      unless @fade_phase_before_terminate
        # 選択肢の表示中でなければポーズサインを表示
        if $game_temp.choice_max == 0
          #self.pause = true
          @pause.visible = true
        end
        # キャンセル
        if Input.trigger?(Input::B)
          if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
            $game_system.se_play($data_system.cancel_se)
            $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
            terminate_message
            @pause.visible = false
            return
          end
        end
        # 決定
        if Input.trigger?(Input::C) or 
           (skippable_now? and Input.press?(KEY_MESSAGE_SKIP))
          if $game_temp.choice_max > 0
            $game_system.se_play($data_system.decision_se)
            $game_temp.choice_proc.call(self.index)
          end
          if @mid_stop
            @mid_stop = false
            @pause.visible = false
            return
          elsif @fade_count_before_terminate.to_i > 0
            # 終了前フェーズへ
            @fade_phase_before_terminate = true
          else
            terminate_message
          end
          @pause.visible = false
        end
      end
      # 終了前：カウント + フェードアウト
      if @fade_phase_before_terminate
        # 例外補正
        @fade_count_before_terminate  = 0 if @fade_count_before_terminate == nil
        # カウント
        @fade_count_before_terminate -= 1
        # 不透明度を計算・設定
        opacity = @fade_count_before_terminate * (256 / XRXS9::FOBT_DURATION)
        self.contents_opacity = opacity
        # 終了判定
        if @fade_count_before_terminate <= 0
          @fade_count_before_terminate = 0
          @fade_phase_before_terminate = false
          terminate_message
        end
      end
      return
    end
    #
    # 以下、メッセージ表示中でない場合
    #
    # フェードアウト中以外で表示待ちのメッセージか選択肢がある場合
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # 表示すべきメッセージがないが、ウィンドウが可視状態の場合
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの位置と不透明度の設定 [再定義]
  #--------------------------------------------------------------------------
  def reset_window
    if @inforesize
      RectalCopy.copy(self, INFO_RECT)
    elsif self.pop_character != nil and self.pop_character >= 0
      update_reset_window
    else
      RectalCopy.copy(self, @default_rect)
      #
      case ($game_temp.in_battle ? 0 : $game_system.message_position)
      when 0  # 上 (戦闘中は上扱い)
        self.y = [16, -XRXS9::NAME_WINDOW_OFFSET_Y + 4].max
      when 1  # 中
        self.y = 160
      end
      # 自動リサイズ
      if DEFAULT_STRETCH_ENABLE and @lines_max >= 4
        # 拡張する差分を計算
        d = @lines_max * DEFAULT_LINE_SPACE + 32 - self.height
        if d > 0
          self.height += d
          case $game_system.message_position
          when 1  # 中
            self.y -= d/2
          when 2  # 下
            self.y -= d
          end
        end
      end
      if @face_file != nil
        self.width += FACE_WIDTH
        self.x -= FACE_WIDTH/2
      end
    end
    if $game_system.message_frame == 0
      self.back_opacity = DEFAULT_BACK_OPACITY
      @name_window_frame.back_opacity = DEFAULT_BACK_OPACITY unless @name_window_frame.nil?
    else
      self.opacity = 0
      @name_window_frame.back_opacity = 0 unless @name_window_frame.nil?
    end
    # ポーズサイン位置
    @pause.x = self.x + self.width  - 16
    @pause.y = self.y + self.height - 16
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの位置と不透明度の設定 (キャラポップ)
  #--------------------------------------------------------------------------
  def update_reset_window
    #
    # 「キャラポップ」
    #
    if self.pop_character == 0 or $game_map.events[self.pop_character] != nil
      character = get_character(self.pop_character)
      x = character.screen_x - self.width / 2
      case $game_system.message_position
      when 0
        if @name_window_frame != nil and @name_window_frame.y <= 4
          y = 4 - XRXS9::NAME_WINDOW_OFFSET_Y
        else
          y = character.screen_y - CHARPOP_HEIGHT - self.height
        end
      else
        y = character.screen_y
      end
      self.x = [[x, 4].max, 636 - self.width ].min
      self.y = [[y, 4].max, 476 - self.height].min
      if  @name_window_frame != nil
        @name_window_frame.x = self.x + XRXS9::NAME_WINDOW_OFFSET_X
        @name_window_frame.y = self.y + XRXS9::NAME_WINDOW_OFFSET_Y
        @name_window_text.x  = self.x + XRXS9::NAME_WINDOW_OFFSET_X + 1 + XRXS9::NAME_WINDOW_SPACE/2 - 16
        @name_window_text.y  = self.y + XRXS9::NAME_WINDOW_OFFSET_Y + 1 + XRXS9::NAME_WINDOW_SPACE/2 - 16
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ カーソルの矩形更新 [オーバーライド]
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8 + @indent, n * line_height, @cursor_width, line_height)
    else
      self.cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # ○ キャラクターの取得
  #     parameter : パラメータ
  #--------------------------------------------------------------------------
  def get_character(parameter)
    # パラメータで分岐
    case parameter
    when 0  # プレイヤー
      return $game_player
    else  # 特定のイベント
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  #--------------------------------------------------------------------------
  # ○ 現在キースキップが可能か？
  #--------------------------------------------------------------------------
  def skippable_now?
    return ((SKIP_BAN_SWITCH_ID == 0 ? true : !$game_switches[SKIP_BAN_SWITCH_ID]) and 
       (HISKIP_ENABLE_SWITCH_ID == 0 ? true : $game_switches[HISKIP_ENABLE_SWITCH_ID]))
  end
  #--------------------------------------------------------------------------
  # ○ 可視状態
  #--------------------------------------------------------------------------
  def visible=(b)
    @name_window_frame.visible = b unless @name_window_frame.nil?
    @name_window_text.visible  = b unless @name_window_text.nil?
    @input_number_window.visible  = b unless @input_number_window.nil?
    super
  end
  #--------------------------------------------------------------------------
  # メソッド テンプレート
  #--------------------------------------------------------------------------
  def process_ruby
  end
  def draw_gaiji(x, y, num)
  end
  def convart_value(option, index)
  end
end
#==============================================================================
# □ Air_Text (何も無いところに文字描写 = 枠の無い瞬間表示メッセージウィンドウ)
#==============================================================================
class Air_Text < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, designate_text, size, text_color)
    super(x-16, y-16, 32 + designate_text.size * 12, 56)
    self.opacity      = 0
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    w = self.contents.width
    h = self.contents.height
    self.contents.font.size = size
    self.contents.font.color = text_color
    self.contents.draw_text(0, 0, w, h, designate_text)
  end
end
#==============================================================================
# □ Window_Copy
#------------------------------------------------------------------------------
#   指定のウィンドウのコピーを作成します。
#==============================================================================
class Window_Copy < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(window)
    super(window.x, window.y, window.width, window.height)
    self.contents = window.contents.dup unless window.contents.nil?
    self.opacity = window.opacity
    self.back_opacity = window.back_opacity
    self.z = window.z
  end
end
#==============================================================================
# □ Sprite_Copy
#------------------------------------------------------------------------------
#   指定のスプライトのコピーを作成します。
#==============================================================================
class Sprite_Copy < Sprite
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(sprite)
    super()
    self.bitmap = sprite.bitmap.dup unless sprite.bitmap.nil?
    self.opacity = sprite.opacity
    self.x = sprite.x
    self.y = sprite.y
    self.z = sprite.z
    self.ox = sprite.ox
    self.oy = sprite.oy
  end
end
#==============================================================================
# ■ Interpreter
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # ● 文章の表示
  #--------------------------------------------------------------------------
  def command_101
    #
     $game_system.timer_working = false
    #
    
    # ほかの文章が message_text に設定済みの場合
    if $game_temp.message_text != nil
      # 終了
      return false
    end
    # メッセージ終了待機中フラグおよびコールバックを設定
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # message_text に 1 行目を設定
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # ループ
    loop do
      # 次のイベントコマンドが文章 2 行目以降の場合
      if @list[@index+1].code == 401
        # message_text に 2 行目以降を追加
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      # イベントコマンドが文章 2 行目以降ではない場合
      else
        # 次のイベントコマンドが文章の表示の場合
        if @list[@index+1].code == 101
          if (/\\next\Z/.match($game_temp.message_text)) != nil
            $game_temp.message_text.gsub!(/\\next/) { "" }
            $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
            # インデックスを進める
            @index += 1
            next
          end
        # 次のイベントコマンドが選択肢の表示の場合
        elsif @list[@index+1].code == 102
          # 選択肢が画面に収まる場合
          if @list[@index+1].parameters[0].size <= 4 - line_count
            # インデックスを進める
            @index += 1
            # 選択肢のセットアップ
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        # 次のイベントコマンドが数値入力の処理の場合
        elsif @list[@index+1].code == 103
          # 数値入力ウィンドウが画面に収まる場合
          if line_count < 4
            # インデックスを進める
            @index += 1
            # 数値入力のセットアップ
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        # 継続
        return true
      end
      # インデックスを進める
      @index += 1
    end
  end
end
#==============================================================================
# --- メッセージ中移動許可 ---
#==============================================================================
class Game_Player < Game_Character
  attr_accessor :messaging_moving
end
#==============================================================================
# --- 範囲コピー ---
#==============================================================================
module RectalCopy
  def self.copy(rect1, rect2)
    rect1.x      = rect2.x
    rect1.y      = rect2.y
    rect1.width  = rect2.width
    rect1.height = rect2.height
  end
end

