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
--	  count = 1,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"high-tech-science-pack", 1},
      },
      time = 30
    },
    order = "e-d"
  },
})