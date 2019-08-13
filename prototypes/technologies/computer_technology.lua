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
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "utility-science-pack", 1 },
            },
            time = 30
        },
        order = "e-d"
    },
})
