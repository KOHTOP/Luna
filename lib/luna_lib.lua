local LunaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KOHTOP/Luna/refs/heads/main/lib/luna_lib.lua"))()

local window = LunaLib:CreateWindow({
    name = "LUNA",
    subtitle = "LIBRARY DEMO",
    keybind = Enum.KeyCode.RightShift,
    visible = true,
})

window:Notify({
    title = "LUNA",
    message = "Demo loaded. RightShift to toggle.",
    kind = "success",
    duration = 4,
})

-- Menu style is Luna-like, but demo is intentionally not 1:1 copy.
local homeTab = window:Tab({ name = "Главная" })
local visualsTab = window:Tab({ name = "Визуалы" })
local playersTab = window:Tab({ name = "Игроки" })
local configTab = window:Tab({ name = "Конфиг" })
local settingsTab = window:Tab({ name = "Настройки" })

local state = {
    mode = "Legit",
    speed = 50,
    profile = "Player",
}

do
    local cols = homeTab:Columns(2)

    local intro = homeTab:Section({ parent = cols[1], name = "О библиотеке" })
    intro:Label("Здесь показаны все элементы LunaLib.")
    intro:Paragraph("Это демонстрация возможностей библиотеки. Меню стилизовано под Luna, но без 1:1 копирования старого интерфейса.")
    local statusInfo = intro:Info("Status", "idle", LunaLib.Theme.green)
    intro:Button({
        text = "Primary button",
        primary = true,
        callback = function()
            statusInfo:Set("clicked primary")
            window:Notify({
                title = "Button",
                message = "Primary button pressed",
                kind = "success",
            })
        end,
    })
    intro:Button({
        text = "Secondary button",
        callback = function()
            statusInfo:Set("clicked secondary")
        end,
    })

    local notifications = homeTab:Section({ parent = cols[2], name = "Уведомления" })
    notifications:Button({
        text = "Info",
        callback = function()
            window:Notify({ title = "Info", message = "Example info", kind = "info" })
        end,
    })
    notifications:Button({
        text = "Success",
        callback = function()
            window:Notify({ title = "Success", message = "Example success", kind = "success" })
        end,
    })
    notifications:Button({
        text = "Warning",
        callback = function()
            window:Notify({ title = "Warning", message = "Example warning", kind = "warning" })
        end,
    })
    notifications:Button({
        text = "Error",
        callback = function()
            window:Notify({ title = "Error", message = "Example error", kind = "error" })
        end,
    })
end

do
    local toggles = visualsTab:Section({ name = "Toggle / Slider / Dropdown" })
    local enableToggle = toggles:Toggle({
        text = "Enable visuals",
        default = false,
        callback = function(v)
            window:Notify({
                title = "Toggle",
                message = "Enable visuals: " .. tostring(v),
                kind = "info",
                duration = 2,
            })
        end,
    })
    local speedSlider = toggles:Slider({
        text = "Effect speed",
        min = 1,
        max = 100,
        default = 50,
        callback = function(v)
            state.speed = v
        end,
    })
    local modeDropdown = toggles:Dropdown({
        text = "Mode",
        options = { "Legit", "Rage", "Silent" },
        default = "Legit",
        callback = function(v)
            state.mode = v
        end,
    })

    local values = visualsTab:Section({ name = "Get / Set controllers" })
    values:Button({
        text = "Show current values",
        callback = function()
            window:Notify({
                title = "Values",
                message = ("toggle=%s | speed=%d | mode=%s"):format(
                    tostring(enableToggle:Get()),
                    speedSlider:Get(),
                    modeDropdown:Get()
                ),
                kind = "info",
            })
        end,
    })
    values:Button({
        text = "Apply preset (Set)",
        callback = function()
            enableToggle:Set(true)
            speedSlider:Set(80)
            modeDropdown:Set("Rage")
            window:Notify({
                title = "Preset",
                message = "Applied via controller:Set(...)",
                kind = "success",
            })
        end,
    })
end

do
    local inputs = playersTab:Section({ name = "Input / Keybind / DisabledToggle" })
    local profileInput = inputs:Input({
        text = "Profile",
        default = "Player",
        placeholder = "Введите имя профиля",
        callback = function(text)
            state.profile = text
        end,
    })
    inputs:Keybind({
        text = "Action key",
        default = Enum.KeyCode.H,
        callback = function(bind)
            window:Notify({
                title = "Keybind",
                message = "Triggered: " .. tostring(bind and bind.Name or "None"),
                kind = "info",
                duration = 1.5,
            })
        end,
    })
    inputs:DisabledToggle({
        text = "Experimental feature",
        reason = "Temporarily disabled in demo.",
    })
    inputs:Button({
        text = "Show profile",
        callback = function()
            window:Notify({
                title = "Profile",
                message = "Current: " .. profileInput:Get(),
                kind = "info",
            })
        end,
    })
end

do
    local cols = configTab:Columns(2)
    local left = configTab:Section({ parent = cols[1], name = "Column A" })
    left:Label("Tab:Columns(count) demo")
    left:Paragraph("Ты можешь строить layout как угодно через parent = columns[i].")

    local right = configTab:Section({ parent = cols[2], name = "Column B" })
    local runtimeInfo = right:Info("Runtime", "0s")
    local started = os.time()
    task.spawn(function()
        while runtimeInfo and window and window.ui and window.ui.gui and window.ui.gui.Parent do
            runtimeInfo:Set(tostring(os.time() - started) .. "s")
            task.wait(1)
        end
    end)
end

do
    local actions = settingsTab:Section({ name = "Window methods" })
    actions:Button({
        text = "window:SetVisible(false)",
        callback = function()
            window:SetVisible(false)
        end,
    })
    actions:Button({
        text = "window:SetVisible(true)",
        callback = function()
            window:SetVisible(true)
        end,
    })
    actions:Button({
        text = "window:Toggle()",
        callback = function()
            window:Toggle()
        end,
    })
    actions:Button({
        text = "window:SetBrand(...)",
        callback = function()
            window:SetBrand("LUNA CUSTOM", "PROFILE: " .. state.profile)
        end,
    })
    actions:Button({
        text = "Reset brand",
        callback = function()
            window:SetBrand("LUNA", "LIBRARY DEMO")
        end,
    })
end
