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
2. +1 Link Stone : **F + J**
3. +1 Master Ball : **G + J**
4. Lots of consumables : **G + U**
5. All EV items : **F + U**
6. 100% shiny encounters (also affects pokemon trainers) : **F + Y**
7. Set your party's IVs to 31 : **G + Y**
8. All held items (pouch 1) : **J + Y**
9. Reset the ability for the first pokemon in the party : **J + U**
