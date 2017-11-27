data:extend({
    {
        type = "technology",
        name = "computer-technology",
        icon = "__computer_core__/graphics/icons/computer-technology.png",
        icon_size = 128,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "computer-recipe"
            }
        },
        prerequisites = { "computer-gauntlet-technology", "circuit-network", "logistics-3" },
        unit = {
            count = 300,
            --	  count = 1,
            ingredients = {
                { "science-pack-1", 1 },
                { "science-pack-2", 1 },
                { "science-pack-3", 1 },
                { "high-tech-science-pack", 1 },
            },
            time = 30
        },
        order = "e-d"
    },
})