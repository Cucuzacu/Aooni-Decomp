#==============================================================================
# ★ タイトル画面編集 var 1.7 (06.7.24)  by shun
#------------------------------------------------------------------------------
#   タイトル画面を編集するスクリプトです。
#   追加機能は、以下です。
#     ・ロゴグラフィックの挿入
#     ・タイトルグラフィックのランダム表示
#     ・簡易タイトル表示（スクリプトでタイトルを画面に表示）
#     ・コンティニューを使用するかどうか
#     ・ヘルプコマンドの追加
#     ・サイトコマンドの追加（タイトル画面から任意のサイトへ）
#     ・スクリーンコマンドの追加（画面サイズ切り替え）
#     ・トランジションの長さの設定
#
#   ランダム機能を使う場合、
#     ファイル名の語尾に二桁の数字（01,02...99）を付けて下さい。
#   ヘルプはヘルプグラフィックを表示するもので、サイズは640×480です。
#==============================================================================

module SIMP
  #============================================================================
  # □ 設定
  #============================================================================
  #
  # ロゴ
  #   ファイルは、Graphics/Pictures内（ピクチャーと同様にインポート）
  #
  LOGO = ""                         # ロゴのファイル名（無記入で使用しない）
  LOGO_SE = ""                      # SEのファイル名（無記入で使用しない）
  LOGO_SE_VOLUME = 80               # SEのボリューム
  LOGO_SE_PITCH = 100               # SEのピッチ
  #
  # ランダムグラフィック機能
  #
  RANDAM = false                    # ランダム機能を使う（true）か否（false）か
  #
  # 簡易タイトル表示
  #
  TITLE_SIMPLE_TEXT = ""            # タイトル名（無記入で使用しない）
  TITLE_SIMPLE_X = 0                # X座標
  TITLE_SIMPLE_Y = 0                # Y座標（多少ズレる）
  c = Color.new(255, 255, 255, 255) # 文字の色(赤の値,緑の値,青の値,不透明度）
  TITLE_SIMPLE_COLOR = c
  TITLE_SIMPLE_SIZE = 50            # 文字のサイズ
  TITLE_SIMPLE_FONT = "ＭＳ 明朝"   # 文字のフォント名
  #
  # コマンドウィンドウ
  #
  TITLE_SKIN = "wskin_n"         # ウィンドウスキン（拡張子省略可能）
  TITLE_X = 320 - 192 / 2           # X座標
  TITLE_Y = 188                     # Y座標
  TITLE_WIDTH = 192                 # 横幅
  TITLE_OPACITY = 0               # ウィンドウの不透明度（0～255）
  TITLE_BACK_OPACITY = 0          # ウィンドウ背景の不透明度（0～255）
  #
  # コマンド名
  #
  NEWGAME = "NEW GAME"          # ニューゲーム
  CONTINUE = "CONTINUE"       # コンティニュー
  HELP = "ヘルプ"                   # ヘルプ
  SITE = "サイト"                   # サイト
  SCREEN = "スクリーン"             # 画面サイズ切り替え
  SHUTDOWN = "SHUTDOWN"       # シャットダウン
  #
  # コンティニュー
  #
  CONTINUE_USE = true               # 使用する（true）か否（false）か
  #
  # 画面サイズ切り替え
  #
  SCREEN_USE = false                # 使用する（true）か否（false）か
  #
  # サイトのURL
  #
  SITE_URL = ""                     # http://から記入（無記入で使用しない）
  SITE_EXIT = true                  # 選択した時にゲームを終了するか否か
  #
  # ヘルプグラフィックのファイル名
  #   Graphics/Gameovers内（ゲームオーバーと同様にインポート）
  #
  HELP_FILE = ""                    # 拡張子は省略可能（無記入で使用しない）
  #
  # トランジション
  #  （初期値は8）
  #
  TITLE_TRANSITION1 = 20       # ロゴ表示のトランジションにかけるフレーム数
  TITLE_TRANSITION2 = 20       # ロゴ消去のトランジションにかけるフレーム数
  TITLE_TRANSITION3 = 20       # タイトル表示のトランジションにかけるフレーム数
end

class Scene_Title
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # 戦闘テストの場合
    if $BTEST
      battle_test
      return
    end    
    # データベースをロード
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # システムオブジェクトを作成
    $game_system = Game_System.new
    # スプライトを作成
    @sprite = Sprite.new
    # ロゴ画面を作成
    unless SIMP::LOGO == ""
      @sprite.bitmap = RPG::Cache.picture(SIMP::LOGO)
      @sprite.x = (640 - @sprite.bitmap.width) / 2
      @sprite.y = (480 - @sprite.bitmap.height) / 2
      # SEを演奏
      unless SIMP::LOGO_SE == ""
        filename = "Audio/SE/" + SIMP::LOGO_SE
        Audio.se_play(filename, SIMP::LOGO_SE_VOLUME, SIMP::LOGO_SE_PITCH)
      end
      # トランジション実行
      Graphics.transition(SIMP::TITLE_TRANSITION1)
      loop do
        # ゲーム画面を更新
        Graphics.update
        # 入力情報を更新
        Input.update
        # B ボタンか C ボタンが押されたら続行
        if Input.trigger?(Input::B) or Input.trigger?(Input::C)
          # トランジション準備
          Graphics.freeze
          # ロゴグラフィックを解放
          @sprite.bitmap.dispose
          # スプライトの座標を元に戻す
          @sprite.x = @sprite.y = 0
          # トランジション実行
          Graphics.transition(SIMP::TITLE_TRANSITION2)
          # トランジション準備
          Graphics.freeze
          break
        end
      end
    end
    # ランダム機能を使う場合
    if SIMP::RANDAM
      # 元となるファイル名を取得
      size = $data_system.title_name.size - 2
      basic = $data_system.title_name[0, size]
      # ファイル数を取得
      i = 1
      loop do
        i += 1
        n = "0" + i.to_s if i < 10
        # ファイルが存在しない場合、ループを中断
        unless title_exist?(basic + n)
          break
        end
      end
      # ファイル名を決定
      n = rand(i) + 1
      n = "0" + n.to_s if n < 10
      name = basic + n
    # ランダム機能を使わない場合
    else
      name = $data_system.title_name
    end
    # タイトルグラフィックを作成
    @sprite.bitmap = RPG::Cache.title(name)
    # 簡易タイトルを作成
    unless SIMP::TITLE_SIMPLE_TEXT == ""
      x = SIMP::TITLE_SIMPLE_X
      y = SIMP::TITLE_SIMPLE_Y
      height = SIMP::TITLE_SIMPLE_SIZE + 10
      @sprite.bitmap.font.color = SIMP::TITLE_SIMPLE_COLOR
      @sprite.bitmap.font.size = SIMP::TITLE_SIMPLE_SIZE
      @sprite.bitmap.font.name = ["ＭＳ Ｐゴシック", "Tahoma"]
      @sprite.bitmap.draw_text(x, y, 640, height, SIMP::TITLE_SIMPLE_TEXT)
    end
    # コマンドウィンドウを作成
    s1 = SIMP::NEWGAME
    s2 = SIMP::CONTINUE
    s3 = SIMP::HELP
    s4 = SIMP::SITE
    s5 = SIMP::SCREEN
    s6 = SIMP::SHUTDOWN
    @commands = [s1]
    # コンティニューを使う場合
    if SIMP::CONTINUE_USE
      @commands.push(s2)
    end
    # ヘルプを使う場合
    unless SIMP::HELP_FILE == ""
      @commands.push(s3)
    end
    # サイトを使う場合
    unless SIMP::SITE_URL == ""
      @commands.push(s4)
    end
    # 画面サイズ切り替えを使う場合
    if SIMP::SCREEN_USE
      @commands.push(s5)
    end
    @commands.push(s6)
    @command_window = Window_Command.new(SIMP::TITLE_WIDTH, @commands)
    @command_window.windowskin = RPG::Cache.windowskin(SIMP::TITLE_SKIN)
    @command_window.opacity = SIMP::TITLE_OPACITY
    @command_window.back_opacity = SIMP::TITLE_BACK_OPACITY
    @command_window.x = SIMP::TITLE_X
    @command_window.y = SIMP::TITLE_Y
    # コンティニュー有効判定
    # セーブファイルがひとつでも存在するかどうかを調べる
    # 有効なら @continue_enabled を true、無効なら false にする
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # コンティニューが有効な場合、カーソルをコンティニューに合わせる
    # 無効な場合、コンティニューの文字をグレー表示にする
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # タイトル BGM を演奏
    $game_system.bgm_play($data_system.title_bgm)
    # ME、BGS の演奏を停止
    Audio.me_stop
    Audio.bgs_stop
    # トランジション実行
    Graphics.transition(SIMP::TITLE_TRANSITION3)
    # メインループ
    loop do
      # ゲーム画面を更新
      Graphics.update
      # 入力情報を更新
      Input.update
      # フレーム更新
      update
      # 画面が切り替わったらループを中断
      if $scene != self
        break
      end
    end
    # トランジション準備
    Graphics.freeze
    # コマンドウィンドウを解放
    @command_window.dispose
    # 簡易タイトルを解放
    @title.dispose unless SIMP::TITLE_SIMPLE_TEXT == ""
    # タイトルグラフィックを解放
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ○ タイトルグラフィックの有無
  #--------------------------------------------------------------------------
  def title_exist?(filename)
    # 読み込みテスト
    begin
      RPG::Cache.title(filename)
    rescue
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # コマンドウィンドウを更新
    @command_window.update
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # コマンドウィンドウのカーソル位置で分岐
      case @commands[@command_window.index]
      when SIMP::NEWGAME   # ニューゲーム
        command_new_game
      when SIMP::CONTINUE  # コンティニュー
        command_continue
      when SIMP::HELP      # ヘルプ
        command_help
      when SIMP::SITE      # サイト
        command_site
      when SIMP::SCREEN    # スクリーン
        command_screen
      when SIMP::SHUTDOWN  # シャットダウン
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ コマンド : ヘルプ
  #--------------------------------------------------------------------------
  def command_help
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # ヘルプ画面に切り替え
    $scene = Scene_Help.new
  end
  #--------------------------------------------------------------------------
  # ○ コマンド : サイト
  #--------------------------------------------------------------------------
  def command_site
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # ブラウザでサイトを開く
    Thread.start do
      system("explorer.exe", SIMP::SITE_URL)
    end
    # ゲームを終了
    exit if SIMP::SITE_EXIT
  end
  #--------------------------------------------------------------------------
  # ○ コマンド : スクリーン
  #--------------------------------------------------------------------------
  def command_screen
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # 画面サイズ切り替え
    keybd = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
    keybd.call 0xA4, 0, 0, 0
    keybd.call 13, 0, 0, 0
    keybd.call 13, 0, 2, 0
    keybd.call 0xA4, 0, 2, 0
  end
end

class Scene_Help
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # ヘルプグラフィックを作成
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover(SIMP::HELP_FILE)
    # トランジション実行
    Graphics.transition
    # メインループ
    loop do
      # ゲーム画面を更新
      Graphics.update
      # 入力情報を更新
      Input.update
      # フレーム更新
      update
      # 画面が切り替わったらループを中断
      if $scene != self
        break
      end
    end
    # トランジション準備
    Graphics.freeze
    # ヘルプグラフィックを解放
    @sprite.bitmap.dispose
    @sprite.dispose
    # トランジション実行
    Graphics.transition
    # トランジション準備
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # タイトル画面に切り替え
      $scene = Scene_Title.new
    end
  end
end

#==============================================================================
# ★ 情報
#------------------------------------------------------------------------------
#   製作
#     shun
#      HP : Simp                  (http://simp.u-abel.net)
#
#   参考
#      HP : Ambition              (http://milkey.net/~rpgxp)
#      HP : RPGTKOOLXP/RGSS Wiki  (http://tkool.web-ghost.net/wiki/wiki.cgi)
#==============================================================================
