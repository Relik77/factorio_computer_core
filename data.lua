-- Add items
require ("prototypes.items.computer-gauntlet-item")

-- Add recipes

-- Add technology research
require ("prototypes.technologies.computer_gauntlet_technology")

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
