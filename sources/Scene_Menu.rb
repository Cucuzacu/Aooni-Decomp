#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     menu_index : コマンドのカーソル初期位置
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # コマンドウィンドウを作成
    s1 = "Item"
    s2 = "Save"
    s3 = "End Game"
    @command_window = Window_Command.new(160, [s1, s2, s3])
    @command_window.index = @menu_index
    
    if $game_switches[180] == false
    if $game_switches[168] == true and $game_switches[169] == true
      if $game_switches[170] == true
      if $game_map.map_id == 67 and $game_player.x == 9 and $game_player.y == 14
        if $game_player.direction == 2
          $game_variables[1] = 3
          $game_switches[178] = true
          $game_party.add_actor(6)
          $game_party.remove_actor(5)
          Audio.bgm_play("Audio/BGM/horor-b",100,100)
          @command_window.disable_item(0)
          @command_window.disable_item(1)
          @command_window.disable_item(2)
        end
      end
      end
    end
    end
    
    # パーティ人数が 0 人の場合
    if $game_party.actors.size == 0
      # アイテム、スキル、装備、ステータスを無効化
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
    end
    # セーブ禁止の場合
    if $game_system.save_disabled
      # セーブを無効にする
      @command_window.disable_item(4)
    end
    # プレイ時間ウィンドウを作成
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 384
    # 歩数ウィンドウを作成
#    @steps_window = Window_Steps.new
#    @steps_window.x = 0
#    @steps_window.y = 320
    # ゴールドウィンドウを作成
#    @gold_window = Window_Gold.new
#    @gold_window.x = 0
#    @gold_window.y = 416
    # ステータスウィンドウを作成
    @status_window = Window_MenuStatus.new
    @status_window.x = 160
    @status_window.y = 0
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
    # ウィンドウを解放
    @command_window.dispose
    @playtime_window.dispose
#    @steps_window.dispose
#    @gold_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ウィンドウを更新
    @command_window.update
    @playtime_window.update
#    @steps_window.update
#    @gold_window.update
    @status_window.update
    # コマンドウィンドウがアクティブの場合: update_command を呼ぶ
    if @command_window.active
      update_command
      return
    end
    # ステータスウィンドウがアクティブの場合: update_status を呼ぶ
    if @status_window.active
      update_status
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (コマンドウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_command
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      
      if $game_switches[178] == true
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      
      # パーティ人数が 0 人で、セーブ、ゲーム終了以外のコマンドの場合
      if $game_party.actors.size == 0 and @command_window.index < 4
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 0  # アイテム
        # 決定  SE を演奏
        $game_system.se_play($data_system.decision_se)
        # アイテム画面に切り替え
        $scene = Scene_Item.new
      when 1  # セーブ
        # セーブ禁止の場合
        if $game_system.save_disabled
          # ブザー SE を演奏
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # セーブ画面に切り替え
        $scene = Scene_Save.new
      when 2  # ゲーム終了
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # ゲーム終了画面に切り替え
        $scene = Scene_End.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (ステータスウィンドウがアクティブの場合)
  #--------------------------------------------------------------------------
  def update_status
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # コマンドウィンドウをアクティブにする
      @command_window.active = true
      @status_window.active = false
      @status_window.index = -1
      return
    end
    # C ボタンが押された場合
    if Input.trigger?(Input::C)
      # コマンドウィンドウのカーソル位置で分岐
      case @command_window.index
      when 1  # スキル
        # このアクターの行動制限が 2 以上の場合
        if $game_party.actors[@status_window.index].restriction >= 2
          # ブザー SE を演奏
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # スキル画面に切り替え
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # 装備
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # 装備画面に切り替え
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # ステータス
        # 決定 SE を演奏
        $game_system.se_play($data_system.decision_se)
        # ステータス画面に切り替え
        $scene = Scene_Status.new(@status_window.index)
      end
      return
    end
  end
end
