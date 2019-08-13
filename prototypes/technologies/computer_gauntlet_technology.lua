data:extend({
  {
    type = "technology",
    name = "computer-gauntlet-technology",
    icon = "__computer_core__/graphics/icons/computer-gauntlet-technology.png",
    icon_size = 128,
    effects =
    {
    },
    prerequisites = {"modular-armor", "advanced-electronics-2", "battery"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 30
    },
    order = "e-d"
  },
})
