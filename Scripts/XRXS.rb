# ▽△▽ ライブラリ15. XRXS キャラクタートークン機構 ▽△▽
# by 桜雅 在土

#==============================================================================
# --- XRXS. キャラクタートークン機構 ---
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # ○ インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :need_refresh_token
  def need_add_tokens
    @need_add_tokens = [] if @need_add_tokens == nil
    return @need_add_tokens
  end
  def need_remove_tokens
    @need_remove_tokens = [] if @need_remove_tokens == nil
    return @need_remove_tokens
  end
  #--------------------------------------------------------------------------
  # ○ キャラクタートークンの追加
  #--------------------------------------------------------------------------
  def add_token(token_event)
    # マップに登録
    @events[token_event.id] = token_event
    # 追加予約
    self.need_add_tokens.push(token_event)
    # トークンリフレッシュを予約
    self.need_refresh_token = true
  end
  #--------------------------------------------------------------------------
  # ○ キャラクタートークンの削除
  #--------------------------------------------------------------------------
  def remove_token(token_event)
    # マップから削除
    @events.delete(token_event.id)
    # 削除予約
    self.need_remove_tokens.push(token_event)
    # トークンリフレッシュを予約
    self.need_refresh_token = true
  end
  #--------------------------------------------------------------------------
  # ○ キャラクタートークンのクリア
  #--------------------------------------------------------------------------
  def clear_tokens
    # マップから削除
    for event in @events.values.dup
      remove_token(event) if event.is_a?(Token_Event)
    end
    # セルフスイッチをクリア
    channels = ["A", "B", "C", "D"]
    for id in 1001..(token_id_shift - 1)
      for a in channels
        key = [self.map_id, id, a]
        $game_self_switches.delete(key)
      end
    end
    # トークン ID シフト用変数を消去
    clear_token_id
  end
end
#==============================================================================
# セルフスイッチの削除
#==============================================================================
class Game_SelfSwitches
  def delete(key)
    @data.delete(key)
  end
end
#==============================================================================
# --- トークン ID シフト ---
#==============================================================================
class Game_Map
  def token_id_shift
    @token_id  = 1000 if @token_id == nil
    @token_id += 1
    return @token_id
  end
  def clear_token_id
    @token_id = nil
  end
end
#==============================================================================
# --- トークンのリフレッシュ ---
#==============================================================================
module XRXS_CTS_RefreshToken
  def refresh_token
    # 追加要求イベントを処理
    for event in $game_map.need_add_tokens
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
    $game_map.need_add_tokens.clear
    # 削除要求イベントを処理
    for sprite in @character_sprites.dup
      if $game_map.need_remove_tokens.empty?
        break
      end
      if $game_map.need_remove_tokens.delete(sprite.character)
        @character_sprites.delete(sprite)
        sprite.dispose
      end
    end
    # リフレッシュ要求をクリア
    $game_map.need_refresh_token = false
  end
end
class Spriteset_Map
  include XRXS_CTS_RefreshToken
  alias xrxs_lib15_update update
  def update
    # 呼び戻す
    xrxs_lib15_update
    # リフレッシュ要請がある場合
    refresh_token if $game_map.need_refresh_token
  end
end
#==============================================================================
# --- プレイヤーの場所移動時にトークンをクリア ---
#==============================================================================
class Scene_Map
  alias xrxs_lib15_transfer_player transfer_player
  def transfer_player
    # キャラクタートークンのクリア
    $game_map.clear_tokens
    # 呼び戻す
    xrxs_lib15_transfer_player
  end
end
#==============================================================================
# □ Token_Event
#------------------------------------------------------------------------------
#   キャラクタートークンを扱うクラスです。
#==============================================================================
class Token_Event < Game_Event
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    # 今回のトークン用の ID の取得
    event.id = $game_map.token_id_shift
    # 呼び戻す
    super
  end
  #--------------------------------------------------------------------------
  # ○ 一時消去 [オーバーライド]
  #--------------------------------------------------------------------------
  def erase
    # 呼び戻す
    super
    # マップから削除
    $game_map.remove_token(self)
  end
end

