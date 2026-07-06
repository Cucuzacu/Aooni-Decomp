# ▼▲▼ XAS_BA. バトラーアタッチメント ▼▲▼ built 211109
# by 桜雅 在土

#==============================================================================
# カスタマイズポイント
#==============================================================================
module XAS_BA
  #
  # エネミーID保有変数ID
  #
  ENEMY_ID_VARIABLE_ID = 25
  #
  # 「感知」　基本距離[単位:マス]　と　感知時に有効になるセルフスイッチ
  #
  SENSOR_DEFAULT_RANGE =  3
  SENSOR_SELF_SWITCH   = "D"
  #
  # アタックID→スキルID 関連付けハッシュ
  #  (ダメージを与えることの出来るアクションは全てココに記述)
  #
  ATTACK_ACTIONS = {
    1=>1, 2=>7
  }
  #
  # 無生物アタッカーID
  #
  OBJECTAL_ATTACKER_ID = 2
  #
  # 攻撃を受けたあとの無敵時間[単位:F]
  #
  DAMAGE_FLASH_DURATION = 60
  #
  # プレイヤーゲームオーバー時にONにするスイッチID
  #
  GAMEOVER_SWITCH_ID = 50
  #
  # ノックバックスピード
  #
  KNOCK_BACK_SPEED = 5
  #
  # 基本ノックバック持続時間[単位:F]
  #
  KNOCK_BACK_DURATION = 28
  #
  # 撃破匹数保持変数 ID (0:不使用)
  #
  DEFEAT_NUMBER_ID = 0
  #--------------------------------------------------------------------------
  # ME/SE (レベルアップ、アイテムドロップ取得、シールド)
  #--------------------------------------------------------------------------
#  LEVEL_UP_ME = RPG::AudioFile.new(None)
  ITEMDROP_SE = RPG::AudioFile.new("056-Right02", 70, 140)
    SHIELD_SE = RPG::AudioFile.new("097-Attack09", 80, 150)
end
#==============================================================================
# カスタマイズポイント：エネミー設定
#==============================================================================
module XAS_BA_ENEMY
  #
  # シールド向き ハッシュ {エネミーID=>[向き配列]}
  #  (向きは、下向きを基本としてテンキーを参照。2が正面、など)
  #
  SHILED_DIRECTIONS = {99=>[2]}
  #
  # シールドアクション ハッシュ {エネミーID=>[アクション配列]}
  #
  SHILED_ACTIONS = {
    99=>[1,2]
  }
  #
  # ノックバック無効 配列 [エネミーID]
  #
  KNOCK_BACK_DISABLES = [3,7]
  #
  # くらい判定範囲 ハッシュ {エネミーID=>SQUAREサイズ} (サイズの基本は 0 )
  #
  BODY_SQUARE = {9=>1,10=>1}
  #
  # エネミーIDから「撃破時ONにするスイッチID」の関連付けハッシュ
  #
  DEFEAT_SWITCH_IDS = {4=>23,7=>63}
end
#=============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # エネミー撃破時の処理
  #--------------------------------------------------------------------------
  def enemy_defeat_process(enemy)
    # 取得前のレベルを保持
    last_level = $game_player.battler.level
    # EXP とゴールドの獲得 (XRXS. パーティEXP獲得機構)
    $game_party.gain_exp(enemy.exp)
    $game_party.gain_gold(enemy.gold)
    # レベルアップ判定
    if last_level < $game_player.battler.level
      # レベルアップ SE の演奏
#      $game_system.me_play(XAS_BA::LEVEL_UP_ME)
      # "Level up!"文字をポップ
      $game_player.battler.damage = "Level up!"
      $game_player.battler.damage_pop = true
      # リフレッシュ要求
      $game_player.need_refresh = true
    end
    # [撃破回数]
    id = XAS_BA::DEFEAT_NUMBER_ID
    $game_variables[id] += 1 if id != 0
    # [撃破時ONにするスイッチ]
    switch_id = XAS_BA_ENEMY::DEFEAT_SWITCH_IDS[self.enemy_id]
    if switch_id != nil
      $game_switches[switch_id] = true
      $game_map.refresh # コレ必須
    end
  end
end
#
# カスタマイズポイントここまで △
#------------------------------------------------------------------------------

#==============================================================================
# --- XRXS. パーティEXP獲得機構 ---
#==============================================================================
class Game_Party
  #--------------------------------------------------------------------------
  # ○ EXPの獲得
  #--------------------------------------------------------------------------
  def gain_exp(exp)
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        actor.exp += exp
      end
    end
  end
end

#==============================================================================
# --- プレイヤー：マップステータスリフレッシュ要求---
#==============================================================================
class Game_Player < Game_Character
  attr_accessor :need_refresh
end

#==============================================================================
# --- 飛び道具 SP 消費 モジュール---
#==============================================================================
module XAS_BA_BULLET_SP_COST
  def shoot_bullet(action_id)
    # スキルの取得
    skill_id = XAS_BA::ATTACK_ACTIONS[action_id]
    skill    = skill_id == nil ? nil : $data_skills[skill_id]
    if skill != nil
      # 消費SPの取得
      sp_cost  = skill.sp_cost
      # SP が足りるか？
      if self.battler.sp < sp_cost
        # ブザー SE を演奏
        $game_system.se_play($data_system.buzzer_se)
        return false
      end
      # SP の消費
      self.battler.sp -= sp_cost
      self.need_refresh = true
    end
    # 呼び戻す
    return super
  end
end
class Game_Player < Game_Character
  include XAS_BA_BULLET_SP_COST
end

#------------------------------------------------------------------------------
#
#
# ▽ 感知
#
#
#==============================================================================
# --- 感知判定 ---
#==============================================================================
module XRXS_EnemySensor
  def update_sensor
    # 距離の取得
    distance = ($game_player.x - self.x).abs + ($game_player.y - self.y).abs
    enable   = (distance <= XAS_BA::SENSOR_DEFAULT_RANGE)
    # セルフスイッチのキーを作成
    key = [$game_map.map_id, self.id, XAS_BA::SENSOR_SELF_SWITCH]
    # 変更前のセルフスイッチを取得して比較
    last_enable = $game_self_switches[key]
    last_enable = false if last_enable == nil
    if enable != last_enable
      # セルフスイッチを変更
      $game_self_switches[key] = enable
      
      # マップをリフレッシュ
      $game_map.need_refresh = true
    end
  end
end
class Game_Event < Game_Character
  include XRXS_EnemySensor
end
#------------------------------------------------------------------------------
#
#
# ▽ バトラーアタッチメント
#
#
#==============================================================================
# --- Game_Character の不透明度操作 ---
#==============================================================================
class Game_Character
  attr_writer   :opacity
end
#==============================================================================
# --- XRXS. バトラーアタッチメント機構 ---
#==============================================================================
module XRXS_BattlerAttachment
  #--------------------------------------------------------------------------
  # ○ 通常攻撃の効果適用
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    # バトラーの取得　→　存在しない場合
    return super if self.battler.nil? or attacker.nil?
    # 攻撃の命中判定
    result = (not self.battler.dead? and self.battler.hiblink_duration.to_i <= 0)
    # 攻撃の命中
    if result
      # 戦闘状態へ
      $game_temp.in_battle = true
      # 通常攻撃の効果適用
      self.battler.attack_effect(attacker.battler)
      self.battler.damage_pop = false
      # 戦闘状態から復帰
      $game_temp.in_battle = false
      # ダメージ命中時の処理
      if self.battler.damage.to_i > 0
        # ブロー
        self.blow(attacker.direction, 1)
      end
      # ダメージハイブリンク
      self.battler.hiblink_duration = self.damage_hiblink_duration
      # プレイヤーへのリフレッシュ要求
      if self.is_a?(Game_Player)
        self.need_refresh = true
      end
    end
    # 撃破時の処理 (カスタマイズポイントに記述)
    # 例外補正
    @xrxs64c_defeat_done = false if @xrxs64c_defeat_done == nil
    if not @xrxs64c_defeat_done and self.battler.dead?
      defeat_process
      # 撃破済み
      @xrxs64c_defeat_done = true
    end
  end
  #--------------------------------------------------------------------------
  # ○ アクションの効果適用
  #--------------------------------------------------------------------------
  def action_effect(bullet, action_id)
    # バトラーの取得　→　存在しない場合
    return super if self.battler.nil?
    # ダメージハイブリンク中はアクションの効果を受けない (貫通でないなら)
    if self.battler.hiblink_duration.to_i > 0 and
       not bullet.action.ignore_invincible
      return false
    end
    # スキルIDの取得
    skill_id = XAS_BA::ATTACK_ACTIONS[action_id]
    return if skill_id == nil
    # ユーザーとバトラーの取得
    user     = bullet.action.user
    attacker = (user == nil ? nil : user.battler)
    # バトラーが存在しない場合は無生物アタッカーと判断
    attacker = $game_actors[XAS_BA::OBJECTAL_ATTACKER_ID] if attacker == nil
    # 攻撃の命中判定
    result = (user != nil and not self.battler.dead?)
    skill_id = XAS_BA::ATTACK_ACTIONS[action_id]
    # シールド判定 (アクション/向き)
    dirset    = [2,6,8,4]
    dir_index = (dirset.index(bullet.direction) + 2) % 4
    shield    = self.shield_actions.include?(action_id)
    for direction in self.shield_directions
      dir_index2 = (dirset.index(self.direction) + dirset.index(direction)) % 4
      shield    |= dirset[dir_index2] == dirset[dir_index]
    end
    if shield
      # シールド SE の演奏
      $game_system.se_play(XAS_BA::SHIELD_SE)
      # ユーザーをノックパック
      user.blow(dirset[dir_index])
      # シールド発生!! ここで super を呼び、強制的に true を返還
      super
      return true
    end
    # 攻撃の命中
    if result
      # スキルの取得
      skill = $data_skills[skill_id]
      if skill_id == 2 and $game_switches[120]
        skill = skill.dup
        skill.power = 8
      end
      # スキルの効果適用
      $game_temp.in_battle = true
      self.battler.skill_effect(attacker, skill)
      self.battler.damage_pop = true
      $game_temp.in_battle = false
      # 1以上のダメージ命中時の処理
      if self.battler.damage.to_i > 0
        # ブロー
        d = bullet.direction
        p = bullet.action.blow_power.to_i
        self.blow(d, p)
        # ダメージハイブリンク
        self.battler.hiblink_duration = self.damage_hiblink_duration
      end
      # プレイヤーへのリフレッシュ要求
      if self.is_a?(Game_Player)
        self.need_refresh = true
      end
    end
    # 撃破時の処理 (カスタマイズポイントに記述)
    if not @xrxs64c_defeat_done and self.battler.dead?
      defeat_process
      @xrxs64c_defeat_done = true
    end
    # 呼び戻す
    return (super or result) 
  end
  #--------------------------------------------------------------------------
  # ○ シールド向きの取得
  #--------------------------------------------------------------------------
  def shield_directions
    return []
  end
  #--------------------------------------------------------------------------
  # ○ シールドアクションの取得
  #--------------------------------------------------------------------------
  def shield_actions
    return []
  end
  #--------------------------------------------------------------------------
  # ○ ノックバック無効化の取得
  #--------------------------------------------------------------------------
  def knock_back_disable
    return false
  end
  #--------------------------------------------------------------------------
  # ○ ダメージハイブリンク(無敵)持続時間の取得
  #--------------------------------------------------------------------------
  def damage_hiblink_duration
    return XAS_BA::DAMAGE_FLASH_DURATION
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘不能判定
  #--------------------------------------------------------------------------
  def dead?
    return self.battler == nil ? false : self.battler.dead?
  end
  #--------------------------------------------------------------------------
  # ○ 撃破時の処理 (内容はサブクラスで定義されます)
  #--------------------------------------------------------------------------
  def defeat_process
  end
  #--------------------------------------------------------------------------
  # ○ バトラーの取得 (このメソッドはサブクラスで定義されます)
  #--------------------------------------------------------------------------
  # battler
end
#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ◇ インクルード
  #--------------------------------------------------------------------------
  include XRXS_BattlerAttachment
  #--------------------------------------------------------------------------
  # ○ バトラーの取得
  #--------------------------------------------------------------------------
  def battler
    return $game_party.actors[0]
  end
  #--------------------------------------------------------------------------
  # ○ 撃破時の処理 (プレイヤー)
  #--------------------------------------------------------------------------
  def defeat_process
    super
    # ゲームオーバー時スイッチを ON にし、リフレッシュして適用。
    $game_switches[XAS_BA::GAMEOVER_SWITCH_ID] = true
    $game_map.refresh
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias xrxs64c_update update
  def update
    # 呼び戻す
    xrxs64c_update
    # ステート自然解除
    self.battler.remove_states_auto if self.battler != nil
    # コラプスが終了した場合
    if self.collapse_done
      # ゲームオーバーの瞬間に、各状態を復旧させる。
      self.collapse_done        = false
      #$game_party.actors[0].hp += 1
      @xrxs64c_defeat_done      = false
    end
  end
end
#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ◇ インクルード
  #--------------------------------------------------------------------------
  include XRXS_BattlerAttachment
  #--------------------------------------------------------------------------
  # ○ バトラーの取得
  #--------------------------------------------------------------------------
  def battler
    return @battler
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias xrxs64c_refresh refresh
  def refresh
    # 呼び戻す
    xrxs64c_refresh
    # バトラーの再チェック
    self.battler_recheck
  end
  #--------------------------------------------------------------------------
  # ○ バトラーの再チェック
  #--------------------------------------------------------------------------
  def battler_recheck
    # すでに設定されている場合は終了
    return if @battler != nil
    # 一つ以上有効になっているページが存在するかチェック
    if @page == nil
      return
    end
    # 設定されているエネミーを取得
    @enemy_id = 0
    for page in @event.pages.reverse
      condition = page.condition
      if condition.variable_valid and
         condition.variable_id == XAS_BA::ENEMY_ID_VARIABLE_ID and
       (!condition.switch1_valid or $game_switches[condition.switch1_id]) and
       (!condition.switch2_valid or $game_switches[condition.switch2_id])
        @enemy_id = condition.variable_value
        break
      end
    end
    if @enemy_id == 0
      return
    end
    # 面倒だがトループから検索する
    troop_id     = -1
    member_index = -1
    for troop in $data_troops
      next if troop == nil
      for enemy in troop.members
        if enemy.enemy_id == @enemy_id
          troop_id     = $data_troops.index(troop)
          member_index = troop.members.index(enemy)
          break
        end
      end
    end
    # バトラーが見つかったかどうか
    if troop_id != -1 and member_index != -1
      @battler = Game_Enemy.new(troop_id, member_index)
    end
  end
  #--------------------------------------------------------------------------
  # ○ エネミーID の取得
  #--------------------------------------------------------------------------
  def enemy_id
    self.battler
    return @enemy_id
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias xrxs64c_update update
  def update
    #
    # コラプス後ウェイトとカウント
    #
    if @collapse_wait_count.to_i > 0
      @collapse_wait_count -= 1
      if @collapse_wait_count == 0
        @collapse_wait_count = nil
        # キャラクターの削除
        $game_map.remove_token(self)    
      end
      # コラプス中はイベントを動かさないためここで終了
      return
    end
    # 感知
    update_sensor
    # 呼び戻す
    xrxs64c_update
    # ステート自然解除
    if self.battler != nil
      self.battler.remove_states_auto
    end
    # コラプス中の場合
    if self.collapse_duration.to_i > 0
      # [すり抜け]強制開始
      @through = true
    end
    # コラプスが終了した場合
    if self.collapse_done
      # 完全に透明にする
      @opacity = 0
      # コラプス後ウェイトを開始
      @collapse_wait_count = 32
      return
    end
  end
  #--------------------------------------------------------------------------
  # ○ シールドの有効/無効
  #--------------------------------------------------------------------------
  def shield_enable!
    @shield_disable = nil
  end
  def shield_disable!
    @shield_disable = true
  end
  #--------------------------------------------------------------------------
  # ○ シールド向きの取得
  #--------------------------------------------------------------------------
  def shield_directions
    set = @shield_disable ? [] : XAS_BA_ENEMY::SHILED_DIRECTIONS[self.enemy_id]
    set = [] if set == nil
    return set
  end
  #--------------------------------------------------------------------------
  # ○ シールドアクションの取得
  #--------------------------------------------------------------------------
  def shield_actions
    set = @shield_disable ? [] : XAS_BA_ENEMY::SHILED_ACTIONS[self.enemy_id]
    set = [] if set == nil
    return set
  end
  #--------------------------------------------------------------------------
  # ○ ノックバック無効化の取得
  #--------------------------------------------------------------------------
  def knock_back_disable
    return XAS_BA_ENEMY::KNOCK_BACK_DISABLES.include?(self.enemy_id)
  end
  #--------------------------------------------------------------------------
  # ○ くらい判定の取得 (拡張)
  #--------------------------------------------------------------------------
  def body_size
    return XAS_BA_ENEMY::BODY_SQUARE[self.enemy_id].to_i
  end
  #--------------------------------------------------------------------------
  # ○ 撃破時の処理 (エネミー)
  #--------------------------------------------------------------------------
  def defeat_process
    super
    enemy_defeat_process(self.battler)
  end
end

#==============================================================================
# --- 接触攻撃ON/OFF モジュール ---
#==============================================================================
class Game_Event < Game_Character
  attr_reader   :collision_attack
  def attack_on
    @collision_attack = true
  end
  def attack_off
    @collision_attack = false
  end
end
#==============================================================================
# --- 接触イベントの起動判定 (＋接触攻撃) ---
#==============================================================================
class Game_Player < Game_Character
  alias xrxs64c_check_event_trigger_touch check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    # 呼び戻す
    xrxs64c_check_event_trigger_touch(x, y)
    # イベント実行中の場合
    if $game_system.map_interpreter.running?
      return
    end
    # 全イベントのループ
    for event in $game_map.events.values
      # 接触攻撃が OFF なら飛ばす
      next unless event.collision_attack
      # 接触トリガーが一致しない場合
      unless [1,2].include?(event.trigger)
        # イベントがバトラーアタッチしている、かつプレイヤーの座標と一致した場合
        if event.battler != nil and event.x == x and event.y == y
          if $game_switches[150] == false
            $game_player.attack_effect(event)
          end
        end
      end
    end
  end
end
class Game_Event < Game_Character
  alias xrxs64c_check_event_trigger_touch check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    # 呼び戻す
    xrxs64c_check_event_trigger_touch(x, y)
    # イベント実行中の場合
    if $game_system.map_interpreter.running?
      return
    end
    # 接触攻撃が OFF なら飛ばす
    return unless self.collision_attack
    # イベントがバトラーアタッチしている、かつプレイヤーの座標と一致した場合
    if self.battler != nil and x == $game_player.x and y == $game_player.y
      if $game_switches[150] == false
        $game_player.attack_effect(self)
      end
    end
  end
end
#==============================================================================
# --- バトラーアタッチされているイベント はイベント中動かさない ---
#==============================================================================
module XAS_BA_BATTLEEVENT_NONPREEMPT
  def update
    # イベント実行中の場合
    return if self.battler != nil and $game_system.map_interpreter.running?
    # 呼び戻す
    super
  end
end
class Game_Event < Game_Character
  include XAS_BA_BATTLEEVENT_NONPREEMPT
end

#------------------------------------------------------------------------------
#
#
# ▽ ダメージハイブリンク
#
#
#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler
  attr_accessor :hiblink_duration           # ハイブリンク持続時間
end
#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias xrxs64c_update update
  def update
    # バトラーの取得
    if @battler == nil
      @battler = @character.battler
    end
    # 呼び戻す
    xrxs64c_update
    # バトラーが nil の場合
    if @battler == nil
      return
    end
    # コラプス中の場合
    if @_collapse_duration > 0
      return
    end
    if @character.collapse_done
      return
    end
    # ブリンク持続時間の更新
    if @battler.hiblink_duration.is_a?(Numeric)
      @character.opacity = (@character.opacity + 70) % 160 + 40
      @battler.hiblink_duration -= 1
      if @battler.hiblink_duration <= 0
        @battler.hiblink_duration = nil
        @character.opacity = 255
      end
    end
  end
end

#------------------------------------------------------------------------------
#
#
# ▽ アイテムドロップ
#
#
#==============================================================================
# --- アイテムドロップ モジュール ---
#==============================================================================
module XAS_BA_ItemDrop
  #--------------------------------------------------------------------------
  # ○ 撃破時の処理 [インクルードオーバーライド]
  #--------------------------------------------------------------------------
  def defeat_process
    # 呼び戻す
    super
    #
    # バトラーはエネミー、バトラーが戦闘不能、
    #   の場合
    if self.battler.is_a?(Game_Enemy) and self.battler.dead?
      # トレジャー出現判定
      treasure = nil
      enemy = self.battler
      if rand(100) < enemy.treasure_prob
        if enemy.item_id > 0
          treasure = $data_items[enemy.item_id]
        end
        if enemy.weapon_id > 0
          treasure = $data_weapons[enemy.weapon_id]
        end
        if enemy.armor_id > 0
          treasure = $data_armors[enemy.armor_id]
        end
      end
      # ドロップ発射
      if treasure != nil
        #
        # [リスト]の設定 ([RPG::EventCommand.new])
        #
        item_se = XAS_BA::ITEMDROP_SE
        opecode = treasure.is_a?(RPG::Item) ? 126 :
                  treasure.is_a?(RPG::Weapon) ? 127 :
                  treasure.is_a?(RPG::Armor) ? 128 :
                  nil
        list = []
        if opecode != nil
          list[0] = RPG::EventCommand.new(opecode, 0, [treasure.id,0,0,1])
          list[1] = RPG::EventCommand.new(250, 0, [item_se]) # 250:SE
          list[2] = RPG::EventCommand.new(116, 0, [])
        end
        list.push(RPG::EventCommand.new) # 空白
        #
        # [ルート]
        #
        command = RPG::MoveCommand.new
        command.code = 14
        command.parameters = [0,0]
        route = RPG::MoveRoute.new
        route.repeat = false
        route.list = [command, RPG::MoveCommand.new]
        #
        # [ページ]
        #
        page = RPG::Event::Page.new
        page.move_type = 3
        page.move_route = route
        page.move_frequency = 6
        page.always_on_top = true
        page.trigger = 1
        page.list = list
        # [イベント]
        event = RPG::Event.new(self.x, self.y)
        event.pages = [page]
        token = Token_Event.new($game_map.id, event)
        token.icon_name = treasure.icon_name
        # マップに登録
        $game_map.add_token(token)
      end
    end
  end
end
class Game_Event < Game_Character
  include XAS_BA_ItemDrop
end
#==============================================================================
# --- キャラクターアイコン表示機構 ---
#==============================================================================
class Game_Character
  attr_accessor :icon_name
end
class Sprite_Character < RPG::Sprite
  alias xrxs_charactericon_update update
  def update
    # 呼び戻す
    xrxs_charactericon_update
    # アイコンが前のものと異なる場合
    if @character.icon_name != nil #and @icon_name != @character.icon_name
      @icon_name = @character.icon_name
      self.bitmap = RPG::Cache.icon(@icon_name)
      self.src_rect.set(0, 0, 24, 24)
      self.ox = 12
      self.oy = 24
    end
  end
end

#------------------------------------------------------------------------------
#
#
# ▽ ノックバック
#
#
#==============================================================================
# ■ Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # ○ ブロー
  #     d     :強制的に移動させる向き
  #     power :移動マス数
  #--------------------------------------------------------------------------
  def blow(d, power = 1)
    return if self.knock_back_disable
    # ノックバック前の移動速度を保存 (すでに保持されていない場合のみ)
    @knock_back_prespeed = @move_speed if @knock_back_prespeed == nil
    # 指定回数繰り返す
    power.times do
      # 移動可能か判定
      if passable?(self.x, self.y, d)
        # 座標を変更する。この後の動作はRGSS基本に一任
        @x += ([3,6,9].include?(d) ? 1 : [1,4,7].include?(d) ? -1 : 0)
        @y += ([1,2,3].include?(d) ? 1 : [7,8,9].include?(d) ? -1 : 0)
      end
    end
    # ノックバック持続時間の設定
    @knock_back_duration = XAS_BA::KNOCK_BACK_DURATION
    # 移動速度を変化
    @move_speed = XAS_BA::KNOCK_BACK_SPEED
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias xrxs64c_nb_update update
  def update
    # 自律移動停止
    @stop_count = -1 if self.knockbacking? or self.dead?
    # 呼び戻す
    xrxs64c_nb_update
    # ノックバックカウント
    if self.knockbacking?
      # ノックバック持続中はパターンをリセットし続ける
      @pattern = 0
      # ノックバック終了判定
      @knock_back_duration -= 1
      if @knock_back_duration <= 0
        @knock_back_duration = nil
        @move_speed = @knock_back_prespeed
        @knock_back_prespeed = nil
      end
      return
    end
  end
  def knockbacking?
    return @knock_back_duration != nil
  end
  def collapsing?
    return self.collapse_duration.to_i > 0
  end
end
#==============================================================================
# --- ダメージ中は移動不可能 ---
#==============================================================================
# 通常に加え、「ノックバック中」「コラプス中」の二個を追加。
# collapse_duration はキャラクターダメージポップ機構にアクセサとして記述
#
module XAS_DamageStop
  def acting?
    return (super or self.knockbacking? or self.collapsing?)
  end
end
class Game_Player < Game_Character
  include XAS_DamageStop
end
class Game_Event < Game_Character
  include XAS_DamageStop
end

