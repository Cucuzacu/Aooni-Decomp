#==============================================================================
#　Zenith RGSS15　BGM・BGSのフェードイン  ver1.02
#　　 by 水夜
#　　http://zenith.ifdef.jp/
#------------------------------------------------------------------------------
# BGM・BGSの演奏にフェードイン機能を追加します。
#==============================================================================

class Game_System
#==============================================================================
# □ カスタマイズポイント
#==============================================================================

  # フェード時間を指定する変数のID
  FADE_VARIABLE = 10

#==============================================================================
end

class Game_Temp
  attr_accessor :bgm_fade_time            # BGM フェード時間
  attr_accessor :bgs_fade_time            # BGS フェード時間
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias zenith15_initialize initialize
  def initialize
    # 呼び戻す
    zenith15_initialize
    @bgm_fade_time = 0
    @bgs_fade_time = 0
  end
end

class Game_System
  #--------------------------------------------------------------------------
  # ● BGM の演奏
  #     bgm : 演奏する BGM
  #--------------------------------------------------------------------------
  alias zenith15_bgm_play bgm_play
  def bgm_play(bgm)
    # $game_temp が nil の場合
    if $game_temp == nil or $game_variables == nil
      # 呼び戻す
      zenith15_bgm_play(bgm)
      return
    end
    # フェード時間設定
    $game_temp.bgm_fade_time = $game_variables[FADE_VARIABLE] * 40
    # フェード時間が 0 の場合
    if $game_temp.bgm_fade_time == 0
      # 呼び戻す
      zenith15_bgm_play(bgm)
      return
    end
    # 変数をリセット
    $game_variables[FADE_VARIABLE] = 0
    @playing_bgm = bgm
    if bgm == nil or bgm.name == ""
      Audio.bgm_stop
      $game_temp.bgm_fade_time = 0
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● BGM の停止
  #--------------------------------------------------------------------------
  alias zenith15_bgm_stop bgm_stop
  def bgm_stop
    $game_temp.bgm_fade_time = 0 if $game_temp != nil
    # 呼び戻す
    zenith15_bgm_stop
  end
  #--------------------------------------------------------------------------
  # ● BGM のフェードアウト
  #     time : フェードアウト時間 (秒)
  #--------------------------------------------------------------------------
  alias zenith15_bgm_fade bgm_fade
  def bgm_fade(time)
    $game_temp.bgm_fade_time = 0 if $game_temp != nil
    # 呼び戻す
    zenith15_bgm_fade(time)
  end
  #--------------------------------------------------------------------------
  # ● BGS の演奏
  #     bgs : 演奏する BGM
  #--------------------------------------------------------------------------
  alias zenith15_bgs_play bgs_play
  def bgs_play(bgs)
    # $game_temp が nil の場合
    if $game_temp == nil
      # 呼び戻す
      zenith15_bgm_play(bgm)
      return
    end
    # フェード時間設定
    $game_temp.bgs_fade_time = $game_variables[FADE_VARIABLE] * 40
    # フェード時間が 0 の場合
    if $game_temp.bgs_fade_time == 0
      # 呼び戻す
      zenith15_bgs_play(bgs)
      return
    end
    # 変数をリセット
    $game_variables[FADE_VARIABLE] = 0
    @playing_bgs = bgs
    if bgs == nil or bgs.name == ""
      Audio.bgs_stop
      $game_temp.bgs_fade_time = 0
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● BGS のフェードアウト
  #     time : フェードアウト時間 (秒)
  #--------------------------------------------------------------------------
  alias zenith15_bgs_fade bgs_fade
  def bgs_fade(time)
    $game_temp.bgs_fade_time = 0 if $game_temp != nil
    # 呼び戻す
    zenith15_bgs_fade(time)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias zenith15_update update
  def update
    # 呼び戻す
    zenith15_update
    # フェードイン実行
    audio_fade_in
  end
  #--------------------------------------------------------------------------
  # ● フェードイン実行
  #--------------------------------------------------------------------------
  def audio_fade_in
    # BGM フェードイン
    if $game_temp.bgm_fade_time > 0
      @bgm_fade_count += 1
      bgm = @playing_bgm
      volume = bgm.volume * @bgm_fade_count / $game_temp.bgm_fade_time
      Audio.bgm_play("Audio/BGM/" + bgm.name, volume, bgm.pitch)
      if @bgm_fade_count >= $game_temp.bgm_fade_time
        $game_temp.bgm_fade_time = 0
      end
    else
      @bgm_fade_count = 0
    end
    # BGS フェードイン
    if $game_temp.bgs_fade_time > 0
      @bgs_fade_count += 1
      bgs = @playing_bgs
      volume = bgs.volume * @bgs_fade_count / $game_temp.bgs_fade_time
      Audio.bgs_play("Audio/BGS/" + bgs.name, volume, bgs.pitch)
      if @bgs_fade_count >= $game_temp.bgs_fade_time
        $game_temp.bgs_fade_time = 0
      end
    else
      @bgs_fade_count = 0
    end
  end
end

