# boot_patch.rb

- Go to the main game folder

for example, Linux when the game is installed through Lutris : /home/YOUR_USER/Games/pokemon-prism/drive_c/users/YOUR_USER/AppData/Roaming/Pokemon Prisme/

- Copy the boot_patch.rb file in it

- Add this line to Game.rb, before the load_from_binary instruction :
`load "boot_patch.rb"`

- Launch the game with ruby
`wine ruby.exe Game.rb`

Once in the game (either create a new save or load one), open the menu and press those key combos : 

1. +10 Rare Candies : **F + G** 
2. +1 Link Stone : **F + J**
3. +1 Master Ball : **G + J**
4. +10 PP Max : **G + U**
5. 100% shiny encounters (also affects pokemon trainers) : **F + Y**
6. Set your party's IVs to 31 : **G + Y**
7. All EV items : **F + U**
