#==============================================================================
#　Zenith RGSS13　記憶＆復帰シリーズ  ver1.03
#　　 by 水夜
#　　http://zenith.ifdef.jp/
#------------------------------------------------------------------------------
# 色々記憶＆復帰。
#==============================================================================

class Game_Switches
  #--------------------------------------------------------------------------
  # ● 全スイッチの記憶
  #--------------------------------------------------------------------------
  def data_memorize
    @data_memo = @data.dup
  end
  #--------------------------------------------------------------------------
  # ● 全スイッチの復帰
  #--------------------------------------------------------------------------
  def data_restore
    if @data_memo != nil
      @data = @data_memo
    end
  end
end

class Game_Variables
  #--------------------------------------------------------------------------
  # ● 全変数の記憶
  #--------------------------------------------------------------------------
  def data_memorize
    @data_memo = @data.dup
  end
  #--------------------------------------------------------------------------
  # ● 全変数の復帰
  #--------------------------------------------------------------------------
  def data_restore
    if @data_memo != nil
      @data = @data_memo
    end
  end
end
  
class Game_SelfSwitches
  #--------------------------------------------------------------------------
  # ● 全セルフスイッチの記憶
  #--------------------------------------------------------------------------
  def data_memorize
    @data_memo = @data.dup
  end
  #--------------------------------------------------------------------------
  # ● 全セルフスイッチの復帰
  #--------------------------------------------------------------------------
  def data_restore
    if @data_memo != nil
      @data = @data_memo
    end
  end
end

class Game_Screen
  #--------------------------------------------------------------------------
  # ● 画面の色調の記憶
  #--------------------------------------------------------------------------
  def tone_memorize
    @tone_memo = [@tone.red, @tone.green, @tone.blue, @tone.gray]
  end
  #--------------------------------------------------------------------------
  # ● 画面の色調の復帰
  #--------------------------------------------------------------------------
  def tone_restore(duration = 20)
    if @tone_memo != nil
      tone = Tone.new(@tone_memo[0], @tone_memo[1], @tone_memo[2], @tone_memo[3])
      start_tone_change(tone, duration * 2)
    end
  end
end

class Game_Battler
  #--------------------------------------------------------------------------
  # ● ステートの記憶
  #--------------------------------------------------------------------------
  def states_memorize
    if self.is_a?(Game_Actor)
      # オートステートを一旦解除
      update_auto_state($data_armors[@armor1_id], nil)
      update_auto_state($data_armors[@armor2_id], nil)
      update_auto_state($data_armors[@armor3_id], nil)
      update_auto_state($data_armors[@armor4_id], nil)
    end
    # ステートを記憶
    @states_memo = @states.dup
    if self.is_a?(Game_Actor)
      # オートステートを再び付加
      update_auto_state(nil, $data_armors[@armor1_id])
      update_auto_state(nil, $data_armors[@armor2_id])
      update_auto_state(nil, $data_armors[@armor3_id])
      update_auto_state(nil, $data_armors[@armor4_id])
    end
  end
  #--------------------------------------------------------------------------
  # ● ステートの復帰
  #--------------------------------------------------------------------------
  def states_restore
    if @states_memo != nil
      # ステートを復帰
      @states = @states_memo
      if self.is_a?(Game_Actor)
        # オートステートを更新
        update_auto_state(nil, $data_armors[@armor1_id])
        update_auto_state(nil, $data_armors[@armor2_id])
        update_auto_state(nil, $data_armors[@armor3_id])
        update_auto_state(nil, $data_armors[@armor4_id])
      end
    end
  end
end

class Game_Party
  #--------------------------------------------------------------------------
  # ● パーティーメンバーの記憶
  #--------------------------------------------------------------------------
  def actors_memorize
    @actors_memo = @actors.dup
  end
  #--------------------------------------------------------------------------
  # ● パーティーメンバーの復帰
  #--------------------------------------------------------------------------
  def actors_restore
    if @actors_memo == nil
      return
    end
    new_actors = []
    for i in 0...@actors_memo.size
      if $data_actors[@actors_memo[i].id] != nil
        new_actors.push($game_actors[@actors_memo[i].id])
      end
    end
    @actors = new_actors
  end
  #--------------------------------------------------------------------------
  # ● 所持品の記憶
  #--------------------------------------------------------------------------
  def belongings_memorize
    @items_memo = @items.dup
    @weapons_memo = @weapons.dup
    @armors_memo = @armors.dup
  end
  #--------------------------------------------------------------------------
  # ● 所持品の復帰
  #--------------------------------------------------------------------------
  def belongings_restore
    if @items_memo != nil
      @items = @items_memo
      @weapons = @weapons_memo
      @armors = @armors_memo
    end
  end
end  

