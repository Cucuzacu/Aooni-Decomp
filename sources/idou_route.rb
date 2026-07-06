#==============================================================================
#　Zenith RGSS6　「移動ルートの設定」拡張  ver1.30
#　　 by 水夜
#　　http://zenith.ifdef.jp/
#------------------------------------------------------------------------------
# ありそうでなかったルート指定を追加します。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 指定イベントに近づく
  #--------------------------------------------------------------------------
  def move_toward_event(id)
    # 指定イベントの座標との差を求める
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 差の絶対値を求める
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横の距離と縦の距離が等しい場合
    if abs_sx == abs_sy
      # ランダムでどちらかを 1 増やす
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横の距離のほうが長い場合
    if abs_sx > abs_sy
      # 左右方向を優先し、指定イベントのいるほうへ移動
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # 縦の距離のほうが長い場合
    else
      # 上下方向を優先し、指定イベントのいるほうへ移動
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定イベントから遠ざかる
  #--------------------------------------------------------------------------
  def move_away_from_event(id)
    # 指定イベントの座標との差を求める
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 差の絶対値を求める
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横の距離と縦の距離が等しい場合
    if abs_sx == abs_sy
      # ランダムでどちらかを 1 増やす
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横の距離のほうが長い場合
    if abs_sx > abs_sy
      # 左右方向を優先し、指定イベントのいないほうへ移動
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # 縦の距離のほうが長い場合
    else
      # 上下方向を優先し、指定イベントのいないほうへ移動
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定座標に近づく
  #--------------------------------------------------------------------------
  def move_toward_position(x, y)
    # 座標の差を求める
    sx = @x - x
    sy = @y - y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 差の絶対値を求める
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横の距離と縦の距離が等しい場合
    if abs_sx == abs_sy
      # ランダムでどちらかを 1 増やす
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横の距離のほうが長い場合
    if abs_sx > abs_sy
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # 縦の距離のほうが長い場合
    else
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定座標から遠ざかる
  #--------------------------------------------------------------------------
  def move_away_from_position(x, y)
    # 座標の差を求める
    sx = @x - x
    sy = @y - y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 差の絶対値を求める
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 横の距離と縦の距離が等しい場合
    if abs_sx == abs_sy
      # ランダムでどちらかを 1 増やす
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 横の距離のほうが長い場合
    if abs_sx > abs_sy
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # 縦の距離のほうが長い場合
    else
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定イベントの方を向く
  #--------------------------------------------------------------------------
  def turn_toward_event(id)
    # 指定イベントの座標との差を求める
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 横の距離のほうが長い場合
    if sx.abs > sy.abs
      # 左右方向で指定イベントのいるほうを向く
      sx > 0 ? turn_left : turn_right
    # 縦の距離のほうが長い場合
    else
      # 上下方向で指定イベントのいるほうを向く
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定イベントの逆を向く
  #--------------------------------------------------------------------------
  def turn_away_from_event(id)
    # 指定イベントの座標との差を求める
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 横の距離のほうが長い場合
    if sx.abs > sy.abs
      # 左右方向で指定イベントのいないほうを向く
      sx > 0 ? turn_right : turn_left
    # 縦の距離のほうが長い場合
    else
      # 上下方向で指定イベントのいないほうを向く
      sy > 0 ? turn_down : turn_up
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定座標の方を向く
  #--------------------------------------------------------------------------
  def turn_toward_position(x, y)
    # 座標の差を求める
    sx = @x - x
    sy = @y - y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 横の距離のほうが長い場合
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    # 縦の距離のほうが長い場合
    else
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定座標の逆を向く
  #--------------------------------------------------------------------------
  def turn_away_from_position(x, y)
    # 座標の差を求める
    sx = @x - x
    sy = @y - y
    # 座標が等しい場合
    if sx == 0 and sy == 0
      return
    end
    # 横の距離のほうが長い場合
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    # 縦の距離のほうが長い場合
    else
      sy > 0 ? turn_down : turn_up
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定範囲内をランダムに移動
  #--------------------------------------------------------------------------
  def move_random_area(x, y, distance)
    # 自分とエリア中心の座標の差を求める
    sx = @x - x
    sy = @y - y
    # 既に範囲外にいる場合
    if sx.abs + sy.abs > distance
      # エリア中心に近づく
      move_toward_position(x, y)
      return
    end
    # とりあえずどの方向に進むか決定した後に距離判定
    case rand(4)
    when 0  # 下に移動
      if sx.abs + sy < distance
        move_down(false)
      end
    when 1  # 左に移動
      if -sx + sy.abs < distance
        move_left(false)
      end
    when 2  # 右に移動
      if sx + sy.abs < distance
        move_right(false)
      end
    when 3  # 上に移動
      if sx.abs - sy < distance
        move_up(false)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● パーティー n 人目のグラフィックに変更
  #--------------------------------------------------------------------------
  def set_graphic_party(n)
    # アクターの取得
    actor = $game_party.actors[n - 1]
    # アクターが存在しない場合 (none) に
    if actor == nil
      @character_name = ""
      return
    end
    # グラフィック変更
    @tile_id = 0
    @character_name = actor.character_name
    @character_hue = actor.character_hue
  end
end

