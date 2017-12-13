data:extend({
    {
        type = "item",
        name = "computer-item",
        icon = "__computer_core__/graphics/icons/computer-icon.png",
        flags = {"goes-to-main-inventory"},
        subgroup = "circuit-network",
        order = "g[computer]-a[computer-item]",
        stack_size = 10,
        place_result = "computer-entity",
        default_request_amount = 1,
        icon_size = 32
    }
})

