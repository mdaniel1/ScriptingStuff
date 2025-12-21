# boot_patch.rb

- Go to the main game folder
    - Linux (Lutris) : /home/YOUR_USER/Games/pokemon-prism/drive_c/users/YOUR_USER/AppData/Roaming/Pokemon Prisme/
    - Windows : C:\Users\YOUR_USER\AppData\Roaming\Pokemon Prisme\
- Copy the boot_patch.rb file in it

- Add this line to Game.rb, before the load_from_binary instruction :
`load "boot_patch.rb"`

- Launch the game with ruby
`wine ruby.exe Game.rb` or `WINEDEBUG=fixme-all,-dinput wine ruby.exe Game.rb` if you want to disable the annoying dinput log flooding the console 

Once in the game (either create a new save or load one), open the menu and press those key combos : 

1. +10 Rare Candies : **F + G**
2. Add all HM special items : **X + C**
3. Add all TMs : **X + J**
4. +1 Link Stone : **F + J**
5. +1 Master Ball : **G + J**
6. Lots of precious consumables x10 : **G + U**
7. All EV items x25 : **F + U**
8. 100% shiny encounters (also affects pokemon trainers) : **F + Y**
9. Set your party's IVs to 31 + Happiness to max (255) : **G + Y**
10. All held items x1 : **J + Y**
11. Reset the ability for the first pokemon in the party : **J + U**
12. Override wild encounter to Pokedex ID (*) : **J + C**
----------------
(*) For now, need to manually change the ID in the code, might change it in the future to work more like old ActionReplay (first item in item pouch x999, discard to match the desired ID and then go in the tall grass)
Problem is, not all pokemons are in the game so it would probably crash the game if you set an incorrect ID, idk.
