# boot_patch.rb
puts "[INJECT] boot_patch loaded"

# --------------------------------------------------
#  Dumper (safe: no Set, no external deps)
# --------------------------------------------------
#module PSDKSaveDump
#  SAVE_DUMP_PATH = "save_dump.txt"
#
#  def self.extract_gold(trainer)
#    if defined?($game_party) && $game_party
#      return $game_party.respond_to?(:gold) ? $game_party.gold : $game_party.instance_variable_get(:@gold)
#    end
#
#    gs = if defined?(PFM) && PFM.respond_to?(:game_state)
#          PFM.game_state
#        elsif defined?($game_state)
#          $game_state
#        else
#          trainer.instance_variable_get(:@game_state) rescue nil
#        end
#
#    if gs && gs.instance_variables.include?(:@game_party)
#      gp = gs.instance_variable_get(:@game_party)
#      return gp.respond_to?(:gold) ? gp.gold : gp.instance_variable_get(:@gold)
#    end
#
#    if trainer.respond_to?(:actual_money)
#      return trainer.actual_money
#    end
#
#    nil
#  end
#
#  def self.dump(game_state)
#    File.open(SAVE_DUMP_PATH, "w:utf-8") do |f|
#      f.puts "--- SAVE DUMP START ---"
#
#      begin
#        trainer = game_state.trainer rescue nil
#        gp = $game_party
#        gp.instance_variables.each { |iv| f.puts "#{iv} = #{gp.instance_variable_get(iv).inspect}" }
#        game_state = PFM.game_state
#        bag = game_state.instance_variable_get(:@bag)
#
#        f.puts "DEBUG Input: #{defined?(Input)}"
#        f.puts "DEBUG Yuki::Keyboard: #{defined?(Yuki::Keyboard) rescue false}"
#        f.puts "DEBUG LiteRGSS: #{defined?(LiteRGSS) rescue false}"
#        File.open("litergss_dump.txt", "w:utf-8") do |ff|
#          ff.puts "=== LiteRGSS constants ==="
#          ff.puts(LiteRGSS.constants.inspect) rescue nil
#
#          ff.puts "\n=== LiteRGSS methods ==="
#          ff.puts(LiteRGSS.methods.sort.inspect) rescue nil
#
#          ff.puts "\n=== LiteRGSS singleton methods ==="
#          ff.puts(LiteRGSS.singleton_methods.sort.inspect) rescue nil
#
#          LiteRGSS.constants.each do |const|
#            begin
#              klass = LiteRGSS.const_get(const)
#              ff.puts "\n--- #{const} ---"
#              ff.puts "class: #{klass}"
#              ff.puts "methods: #{klass.methods(false).inspect}"
#              ff.puts "instance_methods: #{klass.instance_methods(false).inspect}"
#            rescue => e
#              ff.puts "\n--- #{const} ---"
#              ff.puts "ERROR: #{e}"
#            end
#          end
#        end
#
#        LiteRGSS.constants.each do |const|
#          begin
#            klass = LiteRGSS.const_get(const)
#            f.puts "\n--- #{const} ---"
#            f.puts "class: #{klass}"
#            f.puts "methods: #{klass.methods(false).inspect rescue nil}"
#            f.puts "instance_methods: #{klass.instance_methods(false).inspect rescue nil}"
#          rescue => e
#            f.puts "\n--- #{const} ---"
#            f.puts "ERROR: #{e}"
#          end
#        end
#
#        if gp
#          f.puts "== Game_Party =="
#          gp.instance_variables.each do |iv|
#            begin
#              val = gp.instance_variable_get(iv)
#              f.puts "  #{iv} = #{val.inspect}"
#            rescue => e
#              f.puts "  #{iv} = <error #{e.message}>"
#            end
#          end
#        else
#          f.puts "== Game_Party not found =="
#        end
#
#        if bag
#          f.puts "== Bag =="
#          bag.instance_variables.each do |iv|
#            begin
#              val = bag.instance_variable_get(iv)
#              f.puts "  #{iv} = #{val.inspect}"
#            rescue => e
#              f.puts "  #{iv} = <error #{e.message}>"
#            end
#          end
#        else
#          f.puts "== Bag not found =="
#        end
#
#        f.puts "=== BAG POCKET STRUCTURE ==="
#        begin
#          if bag
#            orders = bag.instance_variable_get(:@orders)
#            items  = bag.instance_variable_get(:@items)
#
#            f.puts "Number of pockets: #{orders.length rescue '???'}"
#
#            # Dump content of each pocket
#            orders.each_with_index do |pocket, idx|
#              f.puts "\n-- Pocket #{idx} --"
#              if pocket.is_a?(Array)
#                pocket.each do |sym|
#                  qty = items[sym] || 0
#                  f.puts "  #{sym.inspect} => #{qty}"
#                end
#              else
#                f.puts "  (invalid pocket: #{pocket.inspect})"
#              end
#            end
#
#            if defined?(GameData) && GameData.const_defined?(:Item)
#              f.puts "\n=== ITEM → POCKET MAP ==="
#              GameData::Item.all.each do |item|
#                begin
#                  sym = item.id
#                  pocket = bag.pocket_id(sym) rescue "ERR"
#                  f.puts "  #{sym.to_s.ljust(20)} pocket=#{pocket}"
#                rescue => e
#                  f.puts "  ERROR reading item #{item.inspect}: #{e}"
#                end
#              end
#            else
#              f.puts "GameData::Item not available!"
#            end
#
#          else
#            f.puts "Bag not found!"
#          end
#
#        rescue => e
#          f.puts "ERROR dumping pockets: #{e.class}: #{e.message}"
#        end
#
#        f.puts "=== END BAG POCKET STRUCTURE ==="
#
#        sys = game_state.instance_variable_get(:@system)
#        f.puts "(DEBUG) sys : #{sys}"
#        if sys
#          f.puts "== Game_System =="
#          sys.instance_variables.each do |iv|
#            f.puts "  #{iv} = #{sys.instance_variable_get(iv).inspect}"
#          end
#        end
#
#        if trainer
#          f.puts "== Trainer ==: #{trainer.instance_variables.inspect}"
#          trainer.instance_variables.each do |ivar|
#            begin
#              val = trainer.instance_variable_get(ivar)
#              f.puts "  #{ivar} = #{val.inspect}"
#            rescue => e
#              f.puts "  #{ivar} = <error #{e.message}>"
#            end
#          end
#
#          name =
#            if trainer.respond_to?(:actual_name)
#              trainer.actual_name
#            elsif trainer.respond_to?(:name)
#              trainer.name
#            else
#              "(no name)"
#            end
#
#          f.puts "Trainer: #{name}"
#          gold = extract_gold(trainer)
#          f.puts "Money: #{gold}"
#
#          
#        else
#          f.puts "Trainer: not found"
#        end
#
#        party = game_state.actors rescue nil
#        if party.respond_to?(:each)
#          f.puts "Party:"
#          party.each_with_index do |p, i|
#            next unless p
#
#            # Name
#            pname =
#              if p.respond_to?(:given_name) && p.given_name
#                p.given_name
#              elsif p.respond_to?(:name)
#                p.name
#              elsif p.respond_to?(:db_symbol)
#                p.db_symbol.to_s
#              else
#                "???"
#              end
#
#            # Level
#            level = p.respond_to?(:level) ? p.level : "?"
#
#            # IVs (PSDK naming convention)
#            begin
#              iv_hp  = p.iv_hp  rescue "?"
#              iv_atk = p.iv_atk rescue "?"
#              iv_def = p.iv_dfe rescue "?"
#              iv_spa = p.iv_ats rescue "?"
#              iv_spd = p.iv_dfs rescue "?"
#              iv_spe = p.iv_spd rescue "?"
#            rescue
#              iv_hp = iv_atk = iv_def = iv_spa = iv_spd = iv_spe = "?"
#            end
#
#            f.puts "  [#{i}] #{pname} Lv#{level} | IVs: (hp: #{iv_hp}, atk: #{iv_atk}, def: #{iv_def}, spa: #{iv_spa}, spd: #{iv_spd}, spe: #{iv_spe})"
#          end
#        else
#          f.puts "Party: not found"
#        end
#
#      rescue => e
#        f.puts "ERROR: #{e.class}: #{e.message}"
#      end
#
#      f.puts "=== INPUT SYSTEM DUMP ==="
#
#      begin
#        if defined?(Input::Keys)
#          f.puts "-- Input::Keys --"
#          Input::Keys.each do |sym, arr|
#            f.puts "  #{sym.inspect} => #{arr.inspect}"
#          end
#        else
#          f.puts "Input::Keys NOT FOUND"
#        end
#
#        if defined?(Input::ALIAS_KEYS)
#          f.puts "-- Input::ALIAS_KEYS --"
#          Input::ALIAS_KEYS.each do |keycode, action|
#            f.puts "  #{keycode} => #{action.inspect}"
#          end
#        else
#          f.puts "Input::ALIAS_KEYS NOT FOUND"
#        end
#
#        f.puts "-- Current pressed Input Keys --"
#        if defined?(Input)
#          Input::Keys.keys.each do |sym|
#            begin
#              if Input.press?(sym)
#                f.puts "  #{sym.inspect} => PRESSED"
#              end
#            rescue => e
#            end
#          end
#        end
#
#        if defined?(Sf) && defined?(Sf::Keyboard)
#          f.puts "-- SFML Keycodes --"
#          Sf::Keyboard.constants.each do |const|
#            val = Sf::Keyboard.const_get(const) rescue nil
#            next unless val.is_a?(Integer)
#            f.puts "  #{const} = #{val}"
#          end
#        end
#
#      rescue => e
#        f.puts "ERROR IN INPUT DUMP: #{e.class}: #{e.message}"
#      end
#
#      f.puts "=== END INPUT SYSTEM DUMP ==="
#      #File.open("pfm_wild_methods.txt", "w") do |fff|
#      if defined?(PFM::Wild_Battle)
#          f.puts PFM::Wild_Battle.methods(false)
#          f.puts PFM::Wild_Battle.singleton_methods(false)
#          f.puts PFM::Wild_Battle.instance_methods(false)
#        else
#          f.puts "NO Wild_Battle"
#        end
#      #end
#      if defined?(PFM) && defined?(PFM::Pokemon)
#        File.open("pokemon_methods.txt", "w") do |f|
#          f.puts "=== METHODS OF PFM::Pokemon ==="
#          PFM::Pokemon.instance_methods(false).each do |m|
#            f.puts m
#          end
#        end
#      end
#
#      f.puts "--- SAVE DUMP END ---"
#    end
#  end
#end

# --------------------------------------------------
#  Hook manager (no Set)
# --------------------------------------------------
module SaveEditorHook
  @@patched_classes = []   

  def self.frame_update(scene)
    gs =
      (defined?(PFM) && PFM.respond_to?(:game_state) && PFM.game_state rescue nil) ||
      (defined?($game_state) ? $game_state : nil)

    return unless gs
    # ============================================================
    # KEYBOARD INPUTS
    # ============================================================
    # A : C
    # B : X
    # L : F
    # R : G
    # START : J
    # L3 : Y
    # R3 : U
    # SELECT : Num1/Num7 only, unreliable for keyboards who don't have a numpad
    # ============================================================
    #  PSDK BAG STRUCTURE (Prism version)
    # ============================================================
    # Pocket 0 : UNUSED / VOID
    #   - Items placed here do NOT appear in the bag UI.
    #   - Never use this pocket for adding items.
    #
    # Pocket 1 : Evolution Stones / Repels / Misc Items
    #   - Examples: link_stone, fire_stone, thunder_stone, moon_stone,
    #     shiny_stone, dawn_stone, leaf_stone, sun_stone,
    #     escape_rope, super_repel, max_repel, tiny_mushroom, etc.
    #
    # Pocket 2 : Poké Balls
    #   - Examples: master_ball, ultra_ball, poke_ball,
    #     great_ball, premier_ball, etc.
    #
    # Pocket 3 : TMs / HMs
    #   - All TMxx and HMxx items are stored here.
    #
    # Pocket 4 : Berries
    #   - Examples: chesto_berry, etc.
    #
    # Pocket 5 : Key Items
    #   - Examples: town_map, bike, old_rod, mystery_gifts,
    #     dowsing_machine, running_shoes, tickets, passes,
    #     unipass, delivery_stone, sapphire, ruby, etc.
    #
    # Pocket 6 : Medicine / Healing / Stat Items
    #   - Examples: full_restore, hyper_potion, revive,
    #     x_attack, x_defense, protein, iron, zinc,
    #     hp_up, guard_spec, lemonade, etc.
    #
    # NOTE:
    # - Always place items in the proper pocket (1-6).
    # - Pocket 0 is a black hole: items exist in save data
    #   but do NOT show in the inventory screen.
    # ============================================================


    begin
       # Register each press event
      [:A, :B, :X, :Y, :L, :R, :L3, :R3, :START].each do |k|
        PSDKCheat.register_press(k) if Input.trigger?(k)
      end

      # === ADDING ITEMS ===
      if PSDKCheat.consume_combo?(:L, :R) #Keyboard input : F and G
        puts "[CHEAT] Combo L+R detected"
        PSDKCheat.give_item(gs, :rare_candy, 10, 6)
      end

      if PSDKCheat.consume_combo?(:L, :START) #Keyboard input : F + J
        puts "[CHEAT] Combo L+START detected -> Link Stone"
        PSDKCheat.give_item(gs, :link_stone, 1, 1) 
      end

      if PSDKCheat.consume_combo?(:R, :START)
        puts "[CHEAT] Combo R+START detected -> Master Ball"
        PSDKCheat.give_item(gs, :master_ball, 1, 2) #Keyboard input : G + J
      end

      if PSDKCheat.consume_combo?(:R, :R3)
        puts "[CHEAT] Combo R+START detected -> PP Max"
        PSDKCheat.give_item(gs, :pp_max, 10, 6) #Keyboard input : G + U
      end

      # === FORCING SHINY ===
      if PSDKCheat.consume_combo?(:L, :L3) #Keyboard input : F + Y
        puts "[CHEAT] Combo L+Y => Toggle shiny encounters"
        PSDKCheat.toggle_shiny_encounters
      end

      # === SETTING PARTY IVS to 31 ===
      if PSDKCheat.consume_combo?(:R, :L3)  # G + Y
        puts "[CHEAT] Combo R+L3 detected → Max IVs for party"
        PSDKCheat.max_iv_party(gs)
      end

    rescue => e
      puts "[CHEAT DEBUG] Error: #{e}"
    end

  end

  def self.install_for(klass)
    cname = klass.name rescue nil
    return unless cname
    return unless cname.start_with?("GamePlay::")
    return if @@patched_classes.include?(klass)

    @@patched_classes << klass
    puts "[INJECT] Patching #{cname}"

    klass.class_eval do
      # ---------------------------------------------------------
      # 1) Patch main (scene entry)
      # ---------------------------------------------------------
      if instance_methods(false).include?(:main)
        alias_method :__orig_main, :main

        def main(*args, &block)
          puts "[INJECT] #{self.class}#main called"
          result = __orig_main(*args, &block)

          gs =
            (defined?(PFM) && PFM.respond_to?(:game_state) && PFM.game_state rescue nil) ||
            (defined?($game_state) ? $game_state : nil)

          if gs
            #puts "[INJECT] Dumping game state"
            #PSDKSaveDump.dump(gs)
          else
            puts "[INJECT] game_state NOT FOUND"
          end

          result
        end
      end

      # ---------------------------------------------------------
      # 2) Detect the real update method
      # ---------------------------------------------------------
      klass.instance_methods.each do |m|
        next unless m == :update   # only update methods
        next if m.to_s.start_with?("__orig_")

        begin
          alias_name = :"__orig_detect_update_#{cname.gsub(/[:]/, '_')}"
          alias_method alias_name, :update

          define_method(:update) do |*args, &block|
            SaveEditorHook.frame_update(self)
            send(alias_name, *args, &block)
          end

          puts "[INJECT] Hooked #{cname}#update (detect mode)"
        rescue => e
          puts "[INJECT] ERROR patching #{cname}#update: #{e.class}: #{e.message}"
        end
      end

      # ---------------------------------------------------------
      # 3) Dump on saving
      # ---------------------------------------------------------
      if cname == "GamePlay::Save"
        alias_method :__orig_main, :main
        def main(*args, &block)
          result = __orig_main(*args, &block)
          gs = (defined?(PFM) && PFM.game_state) || $game_state
          #PSDKSaveDump.dump(gs) if gs
          result
        end
        puts "[INJECT] Dumping on Save"
      end
    end
  end
end


# --------------------------------------------------
#  Cheat manager (no Set)
# --------------------------------------------------
module PSDKCheat
  @@combo_times = {}
  @@force_shiny_encounters = false

  def self.max_iv_party(game_state)
    party = game_state.actors rescue nil
    return unless party.respond_to?(:each)

    party.each do |pkm|
      next unless pkm && pkm.is_a?(PFM::Pokemon)
      # Set all six stats to 31
      pkm.iv_hp = 31
      pkm.iv_atk = 31
      pkm.iv_dfe = 31
      pkm.iv_spd = 31
      pkm.iv_ats = 31
      pkm.iv_dfs = 31
    end

    puts "[CHEAT] Max IV applied to entire party!"
  end

  def self.register_press(key)
    @@combo_times[key] = Time.now
  end

  def self.consume_combo?(k1, k2, max_delay = 0.25)
    t1 = @@combo_times[k1]
    t2 = @@combo_times[k2]
    return false unless t1 && t2

    ok = (t1 - t2).abs < max_delay

    @@combo_times[k1] = nil
    @@combo_times[k2] = nil

    ok
  end

  def self.safe_add_item(bag, db_symbol, qty, pocket_index)
    return unless bag
    items  = bag.instance_variable_get(:@items)
    orders = bag.instance_variable_get(:@orders)

    if pocket_index
      orders[pocket_index] ||= []
    end

    old_qty = items[db_symbol] || 0
    items[db_symbol] = old_qty + qty

    if pocket_index && orders[pocket_index].is_a?(Array)
      orders[pocket_index] << db_symbol unless orders[pocket_index].include?(db_symbol)
    end

    return old_qty, items[db_symbol]
  end

  def self.give_item(game_state, db_symbol, qty = 1, pocket=0)
    bag = game_state.instance_variable_get(:@bag)
    return unless bag

    old, new = safe_add_item(bag, db_symbol, qty, pocket)
    
    begin
      bag.instance_variable_set(:@item_cache, nil) rescue nil
      bag.instance_variable_set(:@sorted_items, nil) rescue nil
    rescue
    end
    
    puts "[CHEAT] #{db_symbol}: #{old} -> #{new}"
  end

  def self.toggle_shiny_encounters
    @@force_shiny_encounters = !@@force_shiny_encounters
    puts "[CHEAT] Wild Shiny Encounters => #{@@force_shiny_encounters ? "ON" : "OFF"}"
  end

  def self.force_shiny?
    @@force_shiny_encounters
  end
end

# --------------------------------------------------
#  Wild shiny patch – only for encounter groups
# --------------------------------------------------
module PrismWildShinyPatch
  def to_creature(*args, &blk)
    pokemon = super

    if defined?(PSDKCheat) && PSDKCheat.force_shiny? && pokemon.is_a?(PFM::Pokemon)
      begin
        pokemon.shiny = true
        puts "[SHINY] Forced shiny on #{pokemon.db_symbol rescue '??'} Lv#{pokemon.level rescue '?'}"
      rescue => e
        puts "[SHINY] Error forcing shiny: #{e.class}: #{e.message}"
      end
    end

    pokemon
  end
end

TracePoint.new(:class) do |tp|
  mod = tp.self rescue nil
  name = mod.name rescue nil
  next unless name == "Studio::Group::Encounter"

  puts "[SHINY] Studio::Group::Encounter loaded → installing wild shiny patch"
  mod.prepend(PrismWildShinyPatch)
end.enable


# --------------------------------------------------
#  Trace GamePlay::* class loads and patch them
# --------------------------------------------------
tp = TracePoint.new(:class) do |tp|
  mod = tp.self
  cname = mod.name rescue nil
  next unless cname

  if cname.start_with?("GamePlay::")
    #File.open("gp_classes.txt", "a:utf-8") do |f|
    #  f.puts "Defined: #{cname}"
    #end

    SaveEditorHook.install_for(mod)
  end
end

tp.enable

puts "[INJECT] TracePoint for GamePlay::* enabled"
