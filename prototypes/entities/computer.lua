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
    name = "computer-lamp",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    icon = "__computer_core__/graphics/icons/computer-icon.png",
    icon_size = 32,
    subgroup = "grass",
    order = "b[decorative]-k[stone-rock]-a[big]",
    collision_box = { { -1.2, -0.65 }, { 1.2, 0.65 } },
    collision_mask = {"doodad-layer"},
    selection_priority = 0,
    selection_box = {{-0.0, -0}, {0, 0}},
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "2KW",
    light = {
        intensity = 0.4,
        size = 5
    },

    enable_gui = false,

    max_health = 10000,
    healing_per_tick = 10000,
    corpse = "medium-remnants",
    resistances = {
    },

    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },

    picture_off = blank,
    picture_on = blank
}, {
    type = "electric-energy-interface",
    name = "computer-interface-entity",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    icon = "__computer_core__/graphics/icons/computer-icon.png",
    icon_size = 32,
    subgroup = "grass",
    order = "b[decorative]-k[stone-rock]-a[big]",
    collision_box = { { -1.2, -0.65 }, { 1.2, 0.65 } },
    selection_box = { { -1.5, -1 }, { 1.5, 1 } },
    drawing_box = { { -1.5, -2.5 }, { 1.5, 1 } },
    energy_source = {
        type = "electric",
        usage_priority = "primary-input",
        buffer_capacity = "5MJ",
        input_flow_limit = "300kW",
        output_flow_limit = "0kW"
    },
    energy_production = "0kW",
    energy_usage = "50kW",
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

    picture = {
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
    }
}, {
    type = "constant-combinator",
    name = "computer-combinator",
    icon = "__base__/graphics/icons/constant-combinator.png",
    icon_size = 32,
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
}, {
    type = "constant-combinator",
    name = "computer-speaker-combinator",
    icon = "__base__/graphics/icons/constant-combinator.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable"},
    order = "y",
    max_health = 10000,
    healing_per_tick = 10000,
    corpse = "small-remnants",
    collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
    collision_mask = {"doodad-layer"},
    selection_priority = 100,
    selection_box = {{-0.0, -0}, {0, 0}},
    item_slot_count = 1,
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
            wire = { green = {-0.0, -0.0}, red = {0.2, -0.7}, }
        },
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.2, -0.7}, }
        },
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.2, -0.7}, }
        },
        {
            shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
            wire = { green = {-0.0, -0.0}, red = {0.2, -0.7}, }
        }
    },
    circuit_wire_max_distance = 10
}, {
    type = "programmable-speaker",
    name = "computer-speaker",
    icon = "__base__/graphics/icons/programmable-speaker.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable"},
    order = "y",
    max_health = 10000,
    healing_per_tick = 10000,
    corpse = "small-remnants",
    collision_box = { { -1.2, -0.65 }, { 1.2, 0.65 } },
    collision_mask = {"doodad-layer"},
    selection_priority = 0,
    selection_box = {{-0.0, -0}, {0, 0}},
    energy_source =
    {
        type = "electric",
        usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "2KW",

    sprite =
    {
        layers =
        {
            blank,
            blank
        }
    },

    audible_distance_modifier = 2, --multiplies the default 40 tiles of audible distance by this number
    maximum_polyphony = 10, --maximum number of samples that can play at the same time

    instruments = data.raw["programmable-speaker"]["programmable-speaker"].instruments,

    circuit_wire_connection_point = {
        shadow = { green = {-0.0, -0.0}, red = {0.0, 0.0}, },
        wire = { green = {0.0, 0.0}, red = {0.2, -0.7}, }
    },
    circuit_wire_max_distance = 10
}, {
    type = "item-subgroup",
    name = "virtual-music-signal",
    group = "signals",
    order = "1",
}, {
    type = "virtual-signal",
    name = "signal-music-note",
    icon = "__computer_core__/graphics/icons/note-icon.png",
    icon_size = 32,
    subgroup = "virtual-music-signal",
    order = "a-a"
}})