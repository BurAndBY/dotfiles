-- ==== WAYWALL ====
local waywall = require("waywall")
local helpers = require("waywall.helpers")

-- ==== WAYWORK ====
local Scene = require("waywork.scene")
local Modes = require("waywork.modes")
local Keys = require("waywork.keys")
local Processes = require("waywork.processes")

-- ==== USER CONFIG ====
local cfg = require("config")
local keyboard_remaps = require("remaps").remapped_kb
local other_remaps = require("remaps").normal_kb

-- ==== RESOURCES ====
local waywall_config_path = os.getenv("HOME") .. "/.config/waywall/"
local bg_path = waywall_config_path .. "resources/background.png"
local tall_overlay_path = waywall_config_path .. "resources/overlay_tall.png"
local thin_overlay_path = waywall_config_path .. "resources/overlay_thin.png"
local wide_overlay_path = waywall_config_path .. "resources/overlay_wide.png"

local pacem_path = waywall_config_path .. "resources/paceman-tracker-0.7.2.jar"
local nb_path = waywall_config_path .. "resources/Ninjabrain-Bot-1.5.1.jar"
local overlay_path = waywall_config_path .. "resources/measuring_overlay.png"
local stretched_overlay_path = waywall_config_path .. "resources/stretched_overlay.png"

-- ==== INITS ====
local remaps_active = true
local rebind_text = nil
local keybinds_text = nil

-- ==== CONFIG TABLE ====
local config = {
    input = {
        layout = (cfg.xkb_config.enabled and cfg.xkb_config.layout) or nil,
        rules = (cfg.xkb_config.enabled and cfg.xkb_config.rules) or nil,
        variant = (cfg.xkb_config.enabled and cfg.xkb_config.variant) or nil,
        options = (cfg.xkb_config.enabled and cfg.xkb_config.options) or nil,

        repeat_rate = 40,
        repeat_delay = 300,
        remaps = keyboard_remaps,
        sensitivity = (cfg.sens_change.enabled and cfg.sens_change.normal) or 1.0,
        confine_pointer = false,
    },
    theme = {
        background = cfg.bg_col,
        background_png = cfg.toggle_bg_picture and bg_path or nil,
        ninb_anchor = cfg.ninbot_anchor,
        ninb_opacity = cfg.ninbot_opacity,
    },
    experimental = {
        debug = false,
        jit = false,
        tearing = false,
    },
    window = {
        fullscreen_width = cfg.resolution[1],
        fullscreen_height = cfg.resolution[2],
    }
}

local scene = Scene.SceneManager.new(waywall)
local mode_manager = Modes.ModeManager.new(waywall)

-- ==== SCENE REGISTRATION ====
local pie_colors = {
    { input = "#EC6E4E", output = cfg.pie_chart_1 },
    { input = "#46CE66", output = cfg.pie_chart_2 },
    { input = "#CC6C46", output = cfg.pie_chart_2 },
    { input = "#464C46", output = cfg.pie_chart_2 },
    { input = "#E446C4", output = cfg.pie_chart_3 },
}

local percentage_colors = {
    { input = "#E96D4D", output = cfg.text_col },
    { input = "#45CB65", output = cfg.text_col },
}

local function register_mirror(name, options, groups)
    scene:register(name, {
        kind = "mirror",
        options = options,
        groups = groups,
    })
end

local function register_image(name, path, options, groups)
    scene:register(name, {
        kind = "image",
        path = path,
        options = options,
        groups = groups,
    })
end

if cfg.e_count.enabled then
    local e_count_color_key = cfg.e_count.colorkey and {
        input = "#DDDDDD",
        output = cfg.text_col,
    } or nil

    register_mirror("e_count_thin", {
        src = { x = 13, y = 37, w = 37, h = 9 },
        dst = { x = cfg.e_count.x, y = cfg.e_count.y, w = 37 * cfg.e_count.size, h = 9 * cfg.e_count.size },
        depth = 2,
        color_key = e_count_color_key,
    }, { "thin" })

    register_mirror("e_count_tall", {
        src = { x = 13, y = 37, w = 37, h = 9 },
        dst = { x = cfg.e_count.x, y = cfg.e_count.y, w = 37 * cfg.e_count.size, h = 9 * cfg.e_count.size },
        depth = 2,
        color_key = e_count_color_key,
    }, { "tall" })
end

if cfg.thin_pie.enabled then
    if cfg.thin_pie.colorkey then
        for i, ck in ipairs(pie_colors) do
            register_mirror("thin_pie_" .. tostring(i), {
                src = { x = cfg.thin_res[1] - 340, y = cfg.thin_res[2] - 406, w = 340, h = 178 },
                dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
                depth = 2,
                color_key = ck,
            }, { "thin" })
        end
    else
        register_mirror("thin_pie", {
            src = { x = cfg.thin_res[1] - 340, y = cfg.thin_res[2] - 406, w = 340, h = 221 },
            dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 273 * cfg.thin_pie.size / 4 },
            depth = 2,
        }, { "thin" })
    end
end


if cfg.thin_percent.enabled then
    for i, ck in ipairs(percentage_colors) do
        register_mirror("thin_percent_" .. tostring(i), {
            src = { x = cfg.thin_res[1] - 93, y = cfg.thin_res[2] - 221, w = 33, h = 25 },
            dst = { x = cfg.thin_percent.x, y = cfg.thin_percent.y, w = 33 * cfg.thin_percent.size, h = 25 * cfg.thin_percent.size },
            depth = 3,
            color_key = ck,
        }, { "thin" })
    end
end

if cfg.tall_pie.enabled then
    if cfg.tall_pie.colorkey then
        for i, ck in ipairs(pie_colors) do
            register_mirror("tall_pie_" .. tostring(i), {
                src = { x = 44, y = 15978, w = 340, h = 178 },
                dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
                depth = 2,
                color_key = ck,
            }, { "tall" })
        end
    else
        register_mirror("tall_pie", {
            src = { x = 44, y = 15978, w = 340, h = 221 },
            dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 273 * cfg.tall_pie.size / 4 },
            depth = 2,
        }, { "tall" })
    end
end

if cfg.tall_percent.enabled then
    for i, ck in ipairs(percentage_colors) do
        register_mirror("tall_percent_" .. tostring(i), {
            src = { x = 291, y = 16163, w = 33, h = 25 },
            dst = { x = cfg.tall_percent.x, y = cfg.tall_percent.y, w = 33 * cfg.tall_percent.size, h = 25 * cfg.tall_percent.size },
            depth = 3,
            color_key = ck,
        }, { "tall" })
    end
end

register_mirror("measuring_window_mirror", {
    src = cfg.stretched_measure
        and { x = (cfg.tall_res[1] - 30) / 2, y = (cfg.tall_res[2] - 580) / 2, w = 30, h = 580 }
        or { x = (cfg.tall_res[1] - 60) / 2, y = (cfg.tall_res[2] - 580) / 2, w = 60, h = 580 },
    dst = { x = cfg.measuring_window.x, y = cfg.measuring_window.y, w = 70 * cfg.measuring_window.size, h = 40 * cfg.measuring_window.size },
    depth = 2,
}, { "tall" })

register_image("measuring_window_overlay", cfg.stretched_measure and stretched_overlay_path or overlay_path, {
    dst = { x = cfg.measuring_window.x, y = cfg.measuring_window.y, w = 70 * cfg.measuring_window.size, h = 40 * cfg.measuring_window.size },
    depth = 3,
}, { "tall" })

register_image("tall_overlay", tall_overlay_path, {
    dst = { x = 0, y = 0, w = cfg.resolution[1], h = cfg.resolution[2] },
    depth = 1,
}, { "tall" })

register_image("wide_overlay", wide_overlay_path, {
    dst = { x = 0, y = 0, w = cfg.resolution[1], h = cfg.resolution[2] },
    depth = 1,
}, { "wide" })

register_image("thin_overlay", thin_overlay_path, {
    dst = { x = 0, y = 0, w = cfg.resolution[1], h = cfg.resolution[2] },
    depth = 1,
}, { "thin" })

-- ==== MODE MANAGEMENT ====
local transition_from_thin = false

local mode_dims = {
    thin = { width = cfg.thin_res[1], height = cfg.thin_res[2] },
    tall = { width = cfg.tall_res[1], height = cfg.tall_res[2] },
    wide = { width = cfg.wide_res[1], height = cfg.wide_res[2] },
}

local function set_normal_sensitivity()
    if cfg.sens_change.enabled then
        waywall.set_sensitivity(cfg.sens_change.normal)
    end
end

mode_manager:define("thin", {
    width = mode_dims.thin.width,
    height = mode_dims.thin.height,
    on_enter = function()
        set_normal_sensitivity()
        scene:enable_group("thin", true)
    end,
    on_exit = function()
        set_normal_sensitivity()
        scene:enable_group("thin", false)
    end,
})

mode_manager:define("tall", {
    width = mode_dims.tall.width,
    height = mode_dims.tall.height,
    on_enter = function()
        if cfg.sens_change.enabled and not transition_from_thin then
            waywall.set_sensitivity(cfg.sens_change.tall)
        end
        scene:enable_group("tall", true)
    end,
    on_exit = function()
        set_normal_sensitivity()
        scene:enable_group("tall", false)
    end,
})

mode_manager:define("wide", {
    width = mode_dims.wide.width,
    height = mode_dims.wide.height,
    on_enter = function()
        set_normal_sensitivity()
        scene:enable_group("wide", true)
    end,
    on_exit = function()
        set_normal_sensitivity()
        scene:enable_group("wide", false)
    end,
})

local function write_animation_target(target)
    if not cfg.enable_resize_animations then
        return
    end
    os.execute('echo "' .. target .. '" > ~/.resetti_state')
    waywall.sleep(17)
end

local function toggle_mode(name)
    transition_from_thin = (mode_manager.active == "thin")

    if cfg.enable_resize_animations then
        if mode_manager.active == name then
            write_animation_target("0x0")
        else
            local dims = mode_dims[name]
            write_animation_target(string.format("%dx%d", dims.width, dims.height))
        end
    end

    local result = mode_manager:toggle(name)
    transition_from_thin = false
    return result
end

local function resize_action(mode_cfg, mode_name)
    local run = function()
        if not remaps_active then
            return false
        end
        if mode_cfg.f3_safe and waywall.get_key("F3") then
            return false
        end
        return toggle_mode(mode_name)
    end

    if mode_cfg.ingame_only then
        return helpers.ingame_only(run)
    end

    return run
end

-- ==== PROCESS ACTIONS ====
local function launch_paceman()
    if Processes.is_running("paceman-tracker.*\\.jar") then
        print("Paceman Already Running")
        return
    end

    waywall.exec("java -jar " .. pacem_path .. " --nogui")
    print("Paceman Running")
end

local function toggle_ninbot()
    print('tog')
    if not Processes.is_running("Ninjabrain-Bot.*\\.jar") then
        waywall.exec("java -Dawt.useSystemAAFontSettings=on -jar " .. nb_path)
        print('la')
        waywall.show_floating(true)
    else
        helpers.toggle_floating()
        print('tg')
    end
end

local function ensure_ninbot_running()
    if not Processes.is_running("Ninjabrain-Bot.*\\.jar") then
        waywall.exec("java -Dawt.useSystemAAFontSettings=on  -jar " .. nb_path)
        waywall.show_floating(true)
        return true
    end
    return false
end

local function kill_windows()
    Processes.kill_matching("Ninjabrain-Bot.*\\.jar")
    Processes.kill_matching("node")
    waywall.show_floating(false)
end

local function toggle_remaps()
    if rebind_text then
        rebind_text:close()
        rebind_text = nil
    end

    if remaps_active then
        remaps_active = false
        waywall.set_remaps(other_remaps)

        if cfg.xkb_config.enabled then
            waywall.set_keymap({
                layout = nil,
                rules = nil,
                variant = nil,
                options = nil,
            })
        end

        rebind_text = waywall.text(cfg.remaps_text_config.text, {
            x = cfg.remaps_text_config.x,
            y = cfg.remaps_text_config.y,
            color = cfg.remaps_text_config.color,
            size = cfg.remaps_text_config.size,
        })
    else
        remaps_active = true
        waywall.set_remaps(keyboard_remaps)

        if cfg.xkb_config.enabled then
            waywall.set_keymap({
                layout = cfg.xkb_config.layout,
                rules = cfg.xkb_config.rules,
                variant = cfg.xkb_config.variant,
                options = cfg.xkb_config.options,
            })
        end
    end
end


-- ==== DEBUG TEXT ====
waywall.listen("load", function()

end)

-- ==== KEYBINDS ====

config.actions = Keys.actions({
    [cfg.thin.key] = resize_action(cfg.thin, "thin"),
    [cfg.wide.key] = resize_action(cfg.wide, "wide"),
    [cfg.tall.key] = resize_action(cfg.tall, "tall"),

    [cfg.toggle_fullscreen_key] = waywall.toggle_fullscreen,
    [cfg.launch_paceman_key] = launch_paceman,
    [cfg.kill_windows_key] = kill_windows,
    [cfg.toggle_ninbot_key] = toggle_ninbot,
    [cfg.toggle_remaps_key] = toggle_remaps,
})

require("extras")(config)

return config
