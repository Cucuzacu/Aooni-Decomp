# ▼▲▼ XRXS 9. Message Display Full-Width/Half-Width "Additional Control Characters" ▼▲▼ built 192000
# by Ouga Zaito    (\pass)
#    Kazuki, RaTTiE (\V, \e, \R)

#==============================================================================
# □ Customization Points
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # 外字
  #--------------------------------------------------------------------------
  GAIJI_FILE          = "gaiji.png" # Picture file name
  GAIJI_SIZE          =  24         # Size of a single user-defined character
end
#==============================================================================
# ■ Interpreter
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # ○ Pretend to be stopped
  #--------------------------------------------------------------------------
  def pretend_stopping=(b)
    @pretend_stopping = b
  end
  #--------------------------------------------------------------------------
  # ● Execution Status Check
  #--------------------------------------------------------------------------
  alias xrxs9_running? running?
  def running?
    return (not @pretend_stopping and xrxs9_running?)
  end
end
#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● Frame update
  #--------------------------------------------------------------------------
  alias xrxs9_update update
  def update
    # If not moving within the message
    return xrxs9_update unless @messaging_moving
    # change
    last_showing = $game_temp.message_window_showing
    $game_system.map_interpreter.pretend_stopping = true
    $game_temp.message_window_showing = false
    # to call back
    xrxs9_update
    # restoration
    $game_temp.message_window_showing = last_showing
    $game_system.map_interpreter.pretend_stopping = nil
  end
end
#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● Trigger Event
  #--------------------------------------------------------------------------
  alias xrxs9_start start
  def start
    # to call back
    xrxs9_start
    # If executed AND the player is in the process of moving through a message...
    if @starting and $game_player.messaging_moving
      $game_player.messaging_moving = false
    end
  end
end
#------------------------------------------------------------------------------
#
#
# ▽ Additional Control Character Rendering Function [Standalone]
#     (by Kazuki, RaTTiE)
#
#
#==============================================================================
# ■ Window_Message
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ External character rendering
#--------------------------------------------------------------------------
  # x     : X-coordinate
  # y     : Y-coordinate
  # num   : User-defined character number
  # Return: User-defined character width (increment for @x)
  #--------------------------------------------------------------------------
  def draw_gaiji(x, y, num)
    # If the external character cache does not exist
    if @gaiji_cache == nil
      # Load user-defined character data
      if RPG_FileTest.picture_exist?(GAIJI_FILE)
        @gaiji_cache = RPG::Cache.picture(GAIJI_FILE)
      else
        return 0
      end
    end
    # If the specified user-defined character falls outside the cache range, do nothing.
    if @gaiji_cache.width < num * GAIJI_SIZE
      return 0
    end
    # Get font size
    size = GAIJI_SIZE
    # Transfer user-defined character data using stretch_blt.
    self.contents.stretch_blt(Rect.new(x, y, size, size), @gaiji_cache, Rect.new(num * GAIJI_SIZE, 0, GAIJI_SIZE, GAIJI_SIZE))
    # Playing sound effects for text descriptions
    if SOUNDNAME_ON_SPEAK != "" then
      Audio.se_play(SOUNDNAME_ON_SPEAK)
    end
    # Returns the font size.
    return size
  end
#--------------------------------------------------------------------------
  # ○ \V Conversion
  #--------------------------------------------------------------------------
  # option : Option. If unspecified or invalid, returns the user variable value for the index.
  # index  : Index
  # Return : Conversion result (including icon display sequence)
  #--------------------------------------------------------------------------
  def convart_value(option, index)
    # Convert `option` to `""` if it is `nil` (to prevent malfunctions).
    option == nil ? option = "" : nil

    # Convert the option to lowercase.
    option.downcase!

    # \030 is a sequence for displaying icons. It is defined as \030[icon filename].
    case option
    when "i"
      unless $data_items[index].name == nil
        r = sprintf("\030[%s]%s", $data_items[index].icon_name, $data_items[index].name)
      end
    when "w"
      unless $data_weapons[index].name == nil
        r = sprintf("\030[%s]%s", $data_weapons[index].icon_name, $data_weapons[index].name)
      end
    when "a"
      unless $data_armors[index].name == nil
        r = sprintf("\030[%s]%s", $data_armors[index].icon_name, $data_armors[index].name)
      end
    when "s"
      unless $data_skills[index].name == nil
        r = sprintf("\030[%s]%s", $data_skills[index].icon_name, $data_skills[index].name)
      end
    else
      r = $game_variables[index]
    end

    r == nil ? r = "" : nil
    return r
  end
end
#==============================================================================
# --- ruby ---
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ Handling ruby ​​characters
  #--------------------------------------------------------------------------
  def process_ruby
    @now_text.sub!(/\[(.*?)\]/, "")
    # 文字とルビを描画
    x = @x
    y = @y * line_height
    w = 40
    h = line_height
    @x += self.contents.draw_ruby_text(x, y, w, h, $1)
  end
end
class Bitmap
#--------------------------------------------------------------------------
  # ○ Draw Ruby Text
  #--------------------------------------------------------------------------
  # x      : X-coordinate
  # y      : Y-coordinate
  # str    : String to draw. Input in the format "main_text,ruby_text".
  #          If there are two or more delimiters, extras are automatically ignored.
  # Return : Character width (increment for @x).
  #--------------------------------------------------------------------------
  def draw_ruby_text(x, y, w, h, str)
    # Back up the font size
    sizeback = self.font.size
    # Calculating Ruby Size
    self.font.size * 3 / 2 > 32 ? rubysize = 32 - self.font.size : rubysize = self.font.size / 2
    rubysize = [rubysize, 6].max
    
    # Split `str` and store the result in `split_s`.
    split_s = str.split(/,/)
    # Set split_s to "" if it is nil (to prevent malfunctions).
    split_s[0] = "" if split_s[0] == nil
    split_s[1] = "" if split_s[1] == nil
    
    # Calculate height and width.
    height = sizeback + rubysize
    width  = self.text_size(split_s[0]).width

    # Width calculation for the buffer (since the ruby ​​width may exceed the main text width)
    self.font.size = rubysize
    ruby_width = self.text_size(split_s[1]).width
    self.font.size = sizeback

    buf_width = [self.text_size(split_s[0]).width, ruby_width].max

    # Calculate half the difference between the rendering widths of the main text and the ruby, and store the result in a variable (for later use).
    width - ruby_width != 0 ? sub_x = (width - ruby_width) / 2 : sub_x = 0

    # Ruby rendering
    self.font.size = rubysize
    self.draw_text(x + sub_x, 4 + y - self.font.size, self.text_size(split_s[1]).width, self.font.size, split_s[1])
    self.font.size = sizeback
    # Rendering the body text
    self.draw_text(x, y, width, h, split_s[0])
    return width
  end
end

