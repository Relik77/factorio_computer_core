local blank = {
    filename = "__computer_core__/graphics/blank.png",
    priority = "high",
    width = 1,
    height = 1,
    frame_count = 1,
    axially_symmetrical = false,
    direction_count = 1,
    shift = { 0.0, 0.0 },
}

data:extend({{
    type = "lamp",
    name = "computer-entity",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    icon = "__computer_core__/graphics/icons/computer-icon.png",
    subgroup = "grass",
    order = "b[decorative]-k[stone-rock]-a[big]",
    collision_box = { { -1.2, -0.65 }, { 1.2, 0.65 } },
    selection_box = { { -1.5, -1 }, { 1.5, 1 } },
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        buffer_capacity = "5MJ"
    },
    energy_usage_per_tick = "50KW",
    light = {
        intensity = 0.4,
        size = 5
    },

    minable = {
        mining_time = 2,
        result = "computer-item",
        count = 1
    },

    enable_gui = false,

    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    max_health = 250,
    corpse = "medium-remnants",
    resistances = {
        {
            type = "physical",
            decrease = 3,
            percent = 60
        },
        {
            type = "impact",
            decrease = 45,
            percent = 60
        },
        {
            type = "explosion",
            decrease = 10,
            percent = 30
        },
        {
            type = "fire",
            percent = 0
        },
        {
            type = "laser",
            percent = 0
        }
    },

    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },

    picture_off = {
        filename = "__computer_core__/graphics/entities/computer.png",
        priority = "high",
        width = 250,
        height = 200,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        shift = { 2.1, -1.1 },
        scale = 1,
        hr_version =
        {
            filename = "__computer_core__/graphics/entities/computer_hr.png",
            priority = "high",
            width = 1000,
            height = 800,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = { 2.1, -1.1 },
            scale = 0.25,
        }
    },
    picture_on = {
        filename = "__computer_core__/graphics/blank.png",
        priority = "high",
        width = 1,
        height = 1,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        shift = { 0.0, 0.0 },
    },
}, {
    type = "constant-combinator",
    name = "computer-combinator",
    icon = "__base__/graphics/icons/constant-combinator.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable"},
    order = "y",
    max_health = 10000,
    healing_per_tick = 10000,
    corpse = "small-remnants",
    collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
    collision_mask = {"doodad-layer"},
    selection_priority = 100,
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    item_slot_count = 18,
    sprites =
    {
        north = blank,
        east = blank,
        south = blank,
        west = blank
    },
    activity_led_sprites =
    {
        north = blank,
        east = blank,
        south = blank,
        west = blank
    },
    activity_led_light =
    {
        intensity = 0,
        size = 1,
    },
    activity_led_light_offsets =
    {
        {0, 0},
        {0, 0},
        {0, 0},
        {0, 0}
    },
    circuit_wire_connection_points =
    {
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.0, 0.0}, }
        },
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.0, 0.0}, }
        },
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.0, 0.0}, }
        },
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.0, 0.0}, }
        }
    },
    circuit_wire_max_distance = 10
}})