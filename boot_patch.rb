# boot_patch.rb
puts "[INJECT] boot_patch loaded"

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
      if PSDKCheat.consume_combo?(:L, :R) #Keyboard input : F + G
        puts "[CHEAT] Combo L+R detected"
        PSDKCheat.give_item(gs, :rare_candy, 10, 6)
      end

      if PSDKCheat.consume_combo?(:L, :START) #Keyboard input : F + J
        puts "[CHEAT] Combo L+START detected -> Link Stone"
        PSDKCheat.give_item(gs, :link_stone, 1, 1) 
      end

      if PSDKCheat.consume_combo?(:R, :START) #Keyboard input : G + J
        puts "[CHEAT] Combo R+START detected -> Master Ball"
        PSDKCheat.give_item(gs, :master_ball, 1, 2) 
      end

      if PSDKCheat.consume_combo?(:R, :R3) #Keyboard input : G + U
        puts "[CHEAT] Combo R+START detected -> PP Max"
        PSDKCheat.give_item(gs, :pp_max, 10, 6) 
      end

      if PSDKCheat.consume_combo?(:L, :R3) #Keyboard input : F + U
        puts "[CHEAT] Combo L+START detected -> All EV items"
        PSDKCheat.give_item(gs, :iron, 100, 6)
        PSDKCheat.give_item(gs, :protein, 100, 6)
        PSDKCheat.give_item(gs, :calcium, 100, 6)
        PSDKCheat.give_item(gs, :zinc, 100, 6)
        PSDKCheat.give_item(gs, :hp_up, 100, 6)
        PSDKCheat.give_item(gs, :carbos, 100, 6)
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
