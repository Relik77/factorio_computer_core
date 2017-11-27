-- Add items
require ("prototypes.items.computer-gauntlet-item")
require ("prototypes.items.computer-item")

-- Add entities
require ("prototypes.entities.computer")

-- Add recipes
require ("prototypes.recipes.computer_recipe")

-- Add technology research
require ("prototypes.technologies.computer_gauntlet_technology")
require ("prototypes.technologies.computer_technology")

-- Add gui styles
require ("prototypes.style.style")
require ("prototypes.sprites.sprites")

-- Add keys
data:extend{
    {
        type = "custom-input",
        name = "open-computer",
        key_sequence = "CONTROL + Left mouse button",
        consuming = "script-only"
    }
}
