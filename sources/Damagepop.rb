# ▽△▽ XRXS. キャラクターダメージポップ機構 ▽△▽
# by 桜雅 在土

#==============================================================================
# --- XRXS.ダメージ表示位置 補正モジュール ---
#==============================================================================
module XRXS_DAMAGE_OFFSET
  def update
    # 呼び戻す
    super
    # 例外補正
    @damage_sprites   = [] if @damage_sprites.nil?
    # ダメージの更新
    for damage_sprite in @damage_sprites
      damage_sprite.x = self.x
      damage_sprite.y = self.y
    end
  end
end
class Sprite_Character < RPG::Sprite
  include XRXS_DAMAGE_OFFSET
end
#==============================================================================
# --- XRXS. キャラクターダメージポップ モジュール ---
#==============================================================================
class Game_Character
  attr_accessor :collapse_duration
  attr_accessor :battler_visible
  attr_writer   :opacity
  attr_accessor :collapse_done
end
module XRXS_CharacterDamagePop
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # 呼び戻す
    super
    # バトラーが nil の場合
    if @battler == nil
      return
    end
    # キャラクターが保持している状態を復旧
    if @character.collapse_duration != nil
      if @character.collapse_duration > 0
        collapse
      end
      @_collapse_duration = @character.collapse_duration
    end
    @battler_visible = @character.battler_visible
    @battler_visible = true if @battler_visible == nil
    # ダメージ
    if @battler.damage_pop
      damage(@battler.damage, @battler.critical)
      @battler.damage = nil
      @battler.critical = false
      @battler.damage_pop = false
    end
    # 不可視の場合
    unless @battler_visible
      # 出現
      if not @battler.hidden and not @battler.dead? and
         (@battler.damage == nil or @battler.damage_pop)
        appear
        @battler_visible = true
      end
    end
    if @battler_visible
      # コラプス
      if @battler.damage == nil and @battler.dead?
        if @battler.is_a?(Game_Enemy)
          $game_system.se_play($data_system.enemy_collapse_se)
        else
 #         $game_system.se_play($data_system.actor_collapse_se)
        end
        collapse
        @battler_visible = false
      end
    else
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        @character.opacity = 256 - (48 - @_collapse_duration) * 6
        if @_collapse_duration == 0
          @character.collapse_done = true
        end
      end
    end
    # キャラクターに対して状態を保存
    @character.collapse_duration = @_collapse_duration
    @character.battler_visible   = @battler_visible
  end
end
class Sprite_Character < RPG::Sprite
  include XRXS_CharacterDamagePop
end

