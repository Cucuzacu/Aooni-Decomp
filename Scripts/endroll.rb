#==============================================================================
# ★ エンドロール ver 1.6                                         [2008-06-04]
#------------------------------------------------------------------------------
#   テキストファイルを読み込みエンドロールさせるスクリプトです。
#
#   テキストファイルの文字コードは、UTF-8に指定して下さい。
#   （メモ帳などで、保存時に選択できます）
#   ウェイトをかけたい場合は、文章中にwait<数字>と記述してください。
#   これにより、その行が表示される直前に数字分ウェイトします。
#    (例 : wait20この行の表示前にウェイトを入れました)
#
#   イベントコマンド[スクリプト]で以下を書き込むことによって開始します。
#------------------------------------------------------------------------------
#  ○ start_er
#       エンドロールを開始
#------------------------------------------------------------------------------
# スクリプト : shun  (Simp : http://simp.u-abel.net)
#==============================================================================


#==============================================================================
# □ Endr
#------------------------------------------------------------------------------
#   Simp のスクリプト素材 [エンドロール] の設定を扱うモジュールです。定数をそれ
# ぞれのクラス, モジュールから参照します。
#------------------------------------------------------------------------------
#   スクリプトユーザーは、このモジュールで定義する定数を変更することにより設定
# を変更することができます。
#==============================================================================

module Endr
  #
  # ◇ ファイル
  #
  FILE_PATH = "endroll"      # ファイルのパス (文字コードは UTF-8, 拡張子不要)
  REVERSE = false            # テキストの行を逆向きに読むかどうか
  #
  # ◇ フォント
  #
  FONT  = ["MS Pゴシック", "MS PGothic", "MS UI Gothic"]              # テキストのフォント
  SIZE  = 17                             # テキストのフォントサイズ
  COLOR = Color.new(255, 255, 255, 255)  # テキストの色
  ALIGN = 0                             # アライン
                                         #  (0..左揃え, 1..中央揃え, 2..右揃え)
  MARGIN1 = 8                            # 行間の余白
  MARGIN2 = 32                           # 左右の余白
  #
  # ◇ エフェクト
  #
  SPEED = 2            # スクロール速度 (数値が大きい程早い, 負の値で逆向き)
  BACK_GROUND = ""      # 背景グラフィック (Graphics/Gameovers 内)
  BGM = ""  # BGM (Audio/BGM 内)
  #
  # ◇ ウェイト
  #
  START = 120           # 開始までのトランジションにかけるフレーム数
  WAIT = 80             # 終了後、入力可能になるまでの、ウェイト数
  NOINPUT = true        # 入力を待たずに終了する (true) か否 (false) か
  FINISH = 40           # タイトル画面に戻る時のトランジションのフレーム数
  #
  # ◇ 復帰
  #
  BACK = 2              # 戻るシーン
                        #  (0..ゲームを終了, 1..タイトル, 2..マップ)
  MAP = [0, 10, 10]     # マップに戻る場合の戻り先 (配列)
                        #  ([マップの ID, X 座標, Y 座標]
                        #    ...ID は 0, 座標は -1 で変化無し
end


#==============================================================================
# ■ Interpreter
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ○ エンドロールを開始
  #--------------------------------------------------------------------------
  def start_er
    $scene = Scene_Endroll.new
    return true
  end
end


#==============================================================================
# □ Scene_Endroll
#------------------------------------------------------------------------------
# 　エンドロール画面の処理を行うクラスです。
#==============================================================================

class Scene_Endroll
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ファイルを読み込み
    open(Endr::FILE_PATH + ".txt", "rb") {|file| @text = file.readlines}
    @text[0] = @text[0][-(@text[0].size - 1), @text[0].size - 1]
    @text.reverse! if Endr::REVERSE
    @index = 0
    # 1 行の高さを取得
    test = Bitmap.new(1, 1)
    test.font.name, test.font.size = Endr::FONT, Endr::SIZE
    @height = test.text_size(@text[0]).height + Endr::MARGIN1
    # 各種スプライトを作成
    @sprites = []
    @sprites[0] = (Endr::SPEED > 0 ? make_sprite(480) : make_sprite(0-@height))
    @bg = Sprite.new
    @bg.bitmap = RPG::Cache.gameover(Endr::BACK_GROUND)
    # ウェイトカウントを初期化
    @wait_count = 0
    # BGM、BGS を停止
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # トランジション実行
    Graphics.transition(Endr::START)
    # BGM を演奏開始
 #   Audio.bgm_play("Audio/BGM/" + Endr::BGM)
    # メインループ
    loop do
      # ゲーム画面を更新
      Graphics.update
      # 入力情報を更新
      Input.update
      # フレーム更新
      update
      # 画面が切り替わったらループを中断
      break if $scene != self
    end
    # トランジション準備
    Graphics.freeze
    # 各種スプライトを解放
    @bg.bitmap.dispose
    @bg.dispose
    # トランジション実行
    Graphics.transition(Endr::FINISH)
    # トランジション準備
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウェイトカウントを減らす
    return (@wait_count -= 1) if @wait_count > 0
    # 終了フラグが有効な場合
    if @finish_indicating
      # B または C ボタンが押された場合
      if Input.trigger?(Input::B) or Input.trigger?(Input::C) or Endr::NOINPUT
        Audio.se_play("Audio/SE/025-Door02",100,100)
        case Endr::BACK
        when 0 ; $scene = nil
        when 1 ; $scene = Scene_Title.new
        when 2
          # 新しいマップをセットアップ
          $game_map.setup(Endr::MAP[0]) unless Endr::MAP[0] == 0
          # プレイヤーの位置を設定
          x = (Endr::MAP[1] == -1 ? $game_player.x : Endr::MAP[1])
          y = (Endr::MAP[2] == -1 ? $game_player.y : Endr::MAP[2])
          $game_player.moveto(x, y)
          $scene = Scene_Map.new
        end
      end
      return
    end
    # 行を進める
    update_sprites
    # 最後の行まで終わった場合
    if @finish_writing and @sprites.empty?
      # ウェイトカウントをセット
      @wait_count = Endr::WAIT
      # 終了フラグをセット
      @finish_indicating = true
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (スプライト)
  #--------------------------------------------------------------------------
  def update_sprites
    dispose_flag = false
    @sprites.each {|sprite|
      sprite.update
      sprite.y -= Endr::SPEED
      dispose_flag = true if Endr::SPEED > 0 and sprite.y + @height < 0
      dispose_flag = true if Endr::SPEED < 0 and sprite.y > 480
    }
    if dispose_flag
      @sprites[0].bitmap.dispose
      @sprites[0].dispose
      @sprites.shift
    end
    return if @finish_writing
    # スプライトを作成
    if Endr::SPEED > 0
      if @sprites[-1].y + @height < 480
        @sprites.push(make_sprite(@sprites[-1].y + @height))
      end
    else
      if @sprites[-1].y > 0
        @sprites.push(make_sprite(-@height))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 文字列のスプライトを作成
  #     y : 作成先 Y 座標
  #--------------------------------------------------------------------------
  def make_sprite(y)
    sprite = Sprite.new
    sprite.x, sprite.y = Endr::MARGIN2, y
    s_width = 640 - Endr::MARGIN2 * 2
    sprite.bitmap = Bitmap.new(s_width, @height)
    sprite.bitmap.font.name  = Endr::FONT
    sprite.bitmap.font.size  = Endr::SIZE
    sprite.bitmap.font.color = Endr::COLOR
    string = @text[@index].chomp
    # ウェイト処理
    unless string[/wait([0-9]*)/].nil?
      @wait_count = $1.to_i
      string[/wait[0-9]*/] = ""
    end
    sprite.bitmap.draw_text(0, 0, s_width, @height, string, Endr::ALIGN)
    @index += 1
    @finish_writing = true if @index == @text.size
    return sprite
  end
end
