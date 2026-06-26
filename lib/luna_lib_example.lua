-- luna_lib example
-- Load the library from local file.
local LunaLib = loadstring(readfile("luna_lib.lua"))()

local window = LunaLib:CreateWindow({
    name = "LunaLib Example",
    keybind = Enum.KeyCode.RightShift,
    visible = true,
    theme = {
        accent = Color3.fromRGB(120, 90, 255),
    },
})

window:Notify({
    title = "Loaded",
    message = "Example UI is ready",
    kind = "success",
    duration = 3,
})

local mainTab = window:Tab({ name = "Main" })
local miscTab = window:Tab({ name = "Misc" })

local overview = mainTab:Section({ name = "Overview" })
overview:Label("All widgets are shown below.")
local runtimeInfo = overview:Info("Runtime", "idle")

overview:Button({
    text = "Primary button",
    primary = true,
    callback = function()
        runtimeInfo:Set("clicked primary button")
        window:Notify({
            title = "Button",
            message = "Primary button clicked",
            kind = "info",
        })
    end,
})

overview:Button({
    text = "Secondary button",
    callback = function()
        runtimeInfo:Set("clicked secondary button")
    end,
})

local playerSection = mainTab:Section({ name = "Player settings" })

local enabledToggle = playerSection:Toggle({
    text = "Enable feature",
    default = false,
    callback = function(state)
        runtimeInfo:Set(state and "feature enabled" or "feature disabled")
    end,
})

local speedSlider = playerSection:Slider({
    text = "Speed",
    min = 16,
    max = 120,
    default = 32,
    callback = function(value)
        runtimeInfo:Set("speed: " .. tostring(value))
    end,
})

local modeDropdown = playerSection:Dropdown({
    text = "Mode",
    options = { "Legit", "Rage", "Silent" },
    default = "Legit",
    callback = function(value)
        runtimeInfo:Set("mode: " .. tostring(value))
    end,
})

local nameInput = playerSection:Input({
    text = "Profile name",
    placeholder = "type and press Enter",
    callback = function(text, enterPressed)
        if enterPressed then
            runtimeInfo:Set("profile: " .. text)
        end
    end,
})

local hotkeySection = miscTab:Section({ name = "Hotkeys and controls" })
hotkeySection:Label("Press selected key to trigger callback.")

hotkeySection:Keybind({
    text = "Action key",
    default = Enum.KeyCode.H,
    callback = function(bind)
        runtimeInfo:Set("action key event: " .. tostring(bind and bind.Name or "nil"))
    end,
})

hotkeySection:Button({
    text = "Show current values",
    callback = function()
        local summary = string.format(
            "toggle=%s | speed=%s | mode=%s | name=%s",
            tostring(enabledToggle:Get()),
            tostring(speedSlider:Get()),
            tostring(modeDropdown:Get()),
            tostring(nameInput:Get())
        )
        window:Notify({
            title = "State",
            message = summary,
            kind = "info",
            duration = 4,
        })
    end,
})

hotkeySection:Button({
    text = "Hide window",
    callback = function()
        window:SetVisible(false)
    end,
})

hotkeySection:Button({
    text = "Show window",
    callback = function()
        window:SetVisible(true)
    end,
})
