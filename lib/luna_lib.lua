local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LunaLib = {}
LunaLib.__index = LunaLib

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local DefaultTheme = {
    bg = Color3.fromRGB(13, 11, 24),
    side = Color3.fromRGB(17, 14, 30),
    card = Color3.fromRGB(22, 18, 38),
    elem = Color3.fromRGB(30, 25, 48),
    elemHover = Color3.fromRGB(40, 33, 64),
    track = Color3.fromRGB(45, 38, 66),
    border = Color3.fromRGB(48, 40, 74),
    accent = Color3.fromRGB(138, 99, 247),
    accentDim = Color3.fromRGB(96, 70, 180),
    text = Color3.fromRGB(232, 228, 245),
    sub = Color3.fromRGB(150, 142, 175),
    dim = Color3.fromRGB(110, 104, 135),
    green = Color3.fromRGB(86, 214, 142),
    red = Color3.fromRGB(232, 78, 95),
    orange = Color3.fromRGB(245, 175, 80),
}

local MOUSE_NAMES = {
    [Enum.UserInputType.MouseButton1] = "LMB",
    [Enum.UserInputType.MouseButton2] = "RMB",
    [Enum.UserInputType.MouseButton3] = "MMB",
}

local function cloneTable(src)
    local out = {}
    for k, v in pairs(src) do
        out[k] = v
    end
    return out
end

local function newInstance(className, props, children)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        if key ~= "Parent" then
            object[key] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    if props and props.Parent then
        object.Parent = props.Parent
    end
    return object
end

local function withCorner(parent, radius)
    return newInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function withStroke(parent, color, thickness, transparency)
    return newInstance("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function withPadding(parent, left, top, right, bottom)
    return newInstance("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        Parent = parent,
    })
end

local function tween(object, info, properties)
    return TweenService:Create(object, info or QUICK, properties)
end

local function bindDisplay(bind)
    if not bind then
        return "None"
    end
    if MOUSE_NAMES[bind] then
        return MOUSE_NAMES[bind]
    end
    return bind.Name
end

local function resolveBind(bindValue)
    if typeof(bindValue) == "EnumItem" then
        return bindValue
    end
    if type(bindValue) ~= "string" then
        return nil
    end
    local key = Enum.KeyCode[bindValue]
    if key then
        return key
    end
    local inputType = Enum.UserInputType[bindValue]
    if inputType then
        return inputType
    end
    return nil
end

local function bindMatches(bind, input)
    if not bind then
        return false
    end
    return bind == input.KeyCode or bind == input.UserInputType
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local function normalizeWindowConfig(config)
    local cfg = config or {}
    return {
        name = cfg.name or "Luna Library",
        size = cfg.size or UDim2.fromOffset(980, 600),
        position = cfg.position or UDim2.fromScale(0.5, 0.5),
        keybind = cfg.keybind or Enum.KeyCode.RightShift,
        destroyExisting = cfg.destroyExisting ~= false,
        theme = cfg.theme or {},
        visible = cfg.visible ~= false,
    }
end

local function createNotificationHolder(gui)
    local holder = newInstance("Frame", {
        Name = "NotifHolder",
        Size = UDim2.new(0, 320, 1, -32),
        Position = UDim2.new(1, -16, 0, 16),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Parent = gui,
    })
    newInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = holder,
    })
    return holder
end

local function createBaseGui(cfg)
    if cfg.destroyExisting then
        local existing = PlayerGui:FindFirstChild("LunaLibraryUI")
        if existing then
            existing:Destroy()
        end
    end

    local gui = newInstance("ScreenGui", {
        Name = "LunaLibraryUI",
        ResetOnSpawn = false,
        DisplayOrder = 50,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = PlayerGui,
    })

    local backdrop = newInstance("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Parent = gui,
    })

    local window = newInstance("Frame", {
        Name = "Window",
        Size = cfg.size,
        Position = cfg.position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Visible = cfg.visible,
        Parent = gui,
    })

    local scale = newInstance("UIScale", {
        Scale = 1,
        Parent = window,
    })

    local sidebar = newInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 188, 1, 0),
        BorderSizePixel = 0,
        Parent = window,
    })
    withCorner(sidebar, 14)
    newInstance("Frame", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local logo = newInstance("TextLabel", {
        Name = "Logo",
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = cfg.name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 19,
        Font = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(20, 18),
        Parent = sidebar,
    })

    local navHolder = newInstance("Frame", {
        Name = "NavHolder",
        Size = UDim2.new(1, 0, 1, -86),
        Position = UDim2.fromOffset(0, 80),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    newInstance("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = navHolder,
    })
    withPadding(navHolder, 12, 0, 12, 0)

    local contentWrap = newInstance("Frame", {
        Name = "ContentWrap",
        Size = UDim2.new(1, -188, 1, 0),
        Position = UDim2.fromOffset(188, 0),
        BackgroundTransparency = 1,
        Parent = window,
    })

    local header = newInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
        Parent = contentWrap,
    })

    local title = newInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.fromOffset(600, 28),
        Position = UDim2.fromOffset(24, 18),
        BackgroundTransparency = 1,
        Text = "Home",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 22,
        Font = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local closeButton = newInstance("TextButton", {
        Name = "CloseButton",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -42, 0, 16),
        BackgroundColor3 = Color3.fromRGB(30, 25, 48),
        Text = "X",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(150, 142, 175),
        Font = FONT_BOLD,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = header,
    })
    withCorner(closeButton, 8)

    local pages = newInstance("Frame", {
        Name = "Pages",
        Size = UDim2.new(1, 0, 1, -58),
        Position = UDim2.fromOffset(0, 58),
        BackgroundTransparency = 1,
        Parent = contentWrap,
    })

    local dragHitbox = header
    local notifications = createNotificationHolder(gui)

    return {
        gui = gui,
        backdrop = backdrop,
        window = window,
        windowScale = scale,
        sidebar = sidebar,
        logo = logo,
        navHolder = navHolder,
        contentWrap = contentWrap,
        header = header,
        title = title,
        closeButton = closeButton,
        pages = pages,
        dragHitbox = dragHitbox,
        notifications = notifications,
    }
end

local function applyTheme(frame, theme)
    frame.window.BackgroundColor3 = theme.bg
    withCorner(frame.window, 14)
    withStroke(frame.window, theme.border, 1, 0.35)

    frame.sidebar.BackgroundColor3 = theme.side
    frame.logo.TextColor3 = theme.text

    local ext = frame.sidebar:FindFirstChildOfClass("Frame")
    if ext then
        ext.BackgroundColor3 = theme.side
    end

    frame.title.TextColor3 = theme.text
    frame.closeButton.BackgroundColor3 = theme.elem
    frame.closeButton.TextColor3 = theme.sub

    frame.closeButton.MouseEnter:Connect(function()
        tween(frame.closeButton, QUICK, {
            BackgroundColor3 = theme.red,
            TextColor3 = theme.text,
        }):Play()
    end)
    frame.closeButton.MouseLeave:Connect(function()
        tween(frame.closeButton, QUICK, {
            BackgroundColor3 = theme.elem,
            TextColor3 = theme.sub,
        }):Play()
    end)
end

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createNavButton(window, name, index)
    local button = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = window.theme.side,
        Text = name,
        TextColor3 = window.theme.sub,
        TextSize = 13,
        Font = FONT_BOLD,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = index,
        Parent = window.ui.navHolder,
    })
    withCorner(button, 8)

    local bar = newInstance("Frame", {
        Size = UDim2.fromOffset(3, 18),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = window.theme.accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = button,
    })
    withCorner(bar, 2)

    button.MouseEnter:Connect(function()
        if window.currentTabName ~= name then
            tween(button, QUICK, {
                BackgroundColor3 = window.theme.elem,
                TextColor3 = window.theme.text,
            }):Play()
        end
    end)

    button.MouseLeave:Connect(function()
        if window.currentTabName ~= name then
            tween(button, QUICK, {
                BackgroundColor3 = window.theme.side,
                TextColor3 = window.theme.sub,
            }):Play()
        end
    end)

    return button, bar
end

function Window:_selectTab(name)
    if self.currentTabName == name then
        return
    end

    for tabName, tabData in pairs(self.tabs) do
        local selected = tabName == name
        tabData.page.Visible = selected
        tween(tabData.navButton, QUICK, {
            BackgroundColor3 = selected and self.theme.elem or self.theme.side,
            TextColor3 = selected and self.theme.text or self.theme.sub,
        }):Play()
        tween(tabData.navBar, QUICK, {
            BackgroundTransparency = selected and 0 or 1,
        }):Play()
    end

    self.ui.title.Text = name
    self.currentTabName = name
end

function Window:Notify(options)
    local cfg = options or {}
    local title = cfg.title or "Info"
    local message = cfg.message or ""
    local kind = cfg.kind or "info"
    local duration = cfg.duration or 4

    local accent = self.theme.accent
    if kind == "success" then
        accent = self.theme.green
    elseif kind == "error" then
        accent = self.theme.red
    elseif kind == "warning" then
        accent = self.theme.orange
    end

    self.notificationIndex += 1
    local card = newInstance("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = self.theme.card,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        LayoutOrder = -self.notificationIndex,
        Parent = self.ui.notifications,
    })
    withCorner(card, 9)
    withStroke(card, accent, 1, 0.4)
    withPadding(card, 12, 8, 12, 8)

    newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.theme.text,
        TextSize = 14,
        Font = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.fromOffset(0, 20),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = self.theme.sub,
        TextSize = 12,
        Font = FONT,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })

    tween(card, TweenInfo.new(0.25), {
        GroupTransparency = 0,
    }):Play()

    task.delay(duration, function()
        if card.Parent == nil then
            return
        end
        tween(card, TweenInfo.new(0.25), {
            GroupTransparency = 1,
        }):Play()
        task.wait(0.28)
        if card.Parent then
            card:Destroy()
        end
    end)
end

function Window:SetVisible(visible)
    self.visible = visible
    if visible then
        self.ui.window.Visible = true
        self.ui.backdrop.Visible = true
        self.ui.windowScale.Scale = 0.9
        tween(self.ui.windowScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = 1,
        }):Play()
        tween(self.ui.backdrop, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.45,
        }):Play()
    else
        tween(self.ui.backdrop, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
        }):Play()
        local hideTween = tween(self.ui.windowScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = 0.9,
        })
        hideTween:Play()
        hideTween.Completed:Wait()
        self.ui.window.Visible = false
        self.ui.backdrop.Visible = false
    end
end

function Window:Toggle()
    self:SetVisible(not self.visible)
end

function Window:Destroy()
    for _, conn in ipairs(self.connections) do
        conn:Disconnect()
    end
    self.connections = {}
    self.ui.gui:Destroy()
end

function Window:Tab(options)
    local cfg = options or {}
    local name = cfg.name or ("Tab " .. tostring(#self.tabOrder + 1))

    if self.tabs[name] then
        error("Tab already exists: " .. name)
    end

    local page = newInstance("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.theme.accent,
        Visible = false,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.ui.pages,
    })
    withPadding(page, 24, 4, 24, 24)
    newInstance("UIListLayout", {
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    local navButton, navBar = createNavButton(self, name, #self.tabOrder + 1)
    navButton.MouseButton1Click:Connect(function()
        self:_selectTab(name)
    end)

    local tabData = {
        name = name,
        page = page,
        navButton = navButton,
        navBar = navBar,
    }
    self.tabs[name] = tabData
    table.insert(self.tabOrder, name)

    local tabObject = setmetatable({
        window = self,
        page = page,
        sections = {},
    }, Tab)

    if not self.currentTabName then
        self:_selectTab(name)
    end

    return tabObject
end

function Tab:Section(options)
    local cfg = options or {}
    local title = cfg.name or cfg.title

    local card = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.window.theme.card,
        BorderSizePixel = 0,
        Parent = self.page,
    })
    withCorner(card, 10)
    withStroke(card, self.window.theme.border, 1, 0.6)
    withPadding(card, 16, 14, 16, 14)
    newInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = card,
    })

    if title then
        newInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.window.theme.text,
            TextSize = 15,
            Font = FONT_BOLD,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = -1,
            Parent = card,
        })
    end

    local section = setmetatable({
        window = self.window,
        card = card,
    }, Section)

    table.insert(self.sections, section)
    return section
end

function Section:Label(text)
    local label = newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        TextColor3 = self.window.theme.sub,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.card,
    })
    return {
        Set = function(_, value)
            label.Text = tostring(value or "")
        end,
        Get = function()
            return label.Text
        end,
    }
end

function Section:Info(key, value, valueColor)
    local row = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = self.card,
    })
    newInstance("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(key or ""),
        TextColor3 = self.window.theme.sub,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local valueLabel = newInstance("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.fromScale(0.5, 0),
        BackgroundTransparency = 1,
        Text = tostring(value or ""),
        TextColor3 = valueColor or self.window.theme.text,
        TextSize = 13,
        Font = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    return {
        Set = function(_, nextValue)
            valueLabel.Text = tostring(nextValue or "")
        end,
        Get = function()
            return valueLabel.Text
        end,
    }
end

function Section:Button(options)
    local cfg = options or {}
    local text = cfg.text or "Button"
    local callback = cfg.callback
    local primary = cfg.primary == true

    local button = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = primary and self.window.theme.accent or self.window.theme.elem,
        Text = text,
        TextColor3 = primary and self.window.theme.text or self.window.theme.sub,
        TextSize = 13,
        Font = FONT_BOLD,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = self.card,
    })
    withCorner(button, 7)
    if not primary then
        withStroke(button, self.window.theme.border, 1, 0.5)
    end

    button.MouseEnter:Connect(function()
        tween(button, QUICK, {
            BackgroundColor3 = primary and self.window.theme.accentDim or self.window.theme.elemHover,
            TextColor3 = self.window.theme.text,
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        tween(button, QUICK, {
            BackgroundColor3 = primary and self.window.theme.accent or self.window.theme.elem,
            TextColor3 = primary and self.window.theme.text or self.window.theme.sub,
        }):Play()
    end)
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return {
        SetText = function(_, nextText)
            button.Text = tostring(nextText or "")
        end,
    }
end

function Section:Toggle(options)
    local cfg = options or {}
    local text = cfg.text or "Toggle"
    local callback = cfg.callback
    local state = cfg.default == true

    local row = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = self.card,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, -54, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.window.theme.text,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local switch = newInstance("Frame", {
        Size = UDim2.fromOffset(40, 21),
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = state and self.window.theme.accent or self.window.theme.track,
        BorderSizePixel = 0,
        Parent = row,
    })
    withCorner(switch, 11)

    local knob = newInstance("Frame", {
        Size = UDim2.fromOffset(15, 15),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = switch,
    })
    withCorner(knob, 8)

    local function setState(nextState, silent)
        state = nextState == true
        tween(switch, QUICK, {
            BackgroundColor3 = state and self.window.theme.accent or self.window.theme.track,
        }):Play()
        tween(knob, QUICK, {
            Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }):Play()
        if callback and not silent then
            callback(state)
        end
    end

    newInstance("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    }).MouseButton1Click:Connect(function()
        setState(not state, false)
    end)

    if callback then
        callback(state)
    end

    return {
        Set = function(_, nextState)
            setState(nextState, true)
            if callback then
                callback(state)
            end
        end,
        Get = function()
            return state
        end,
    }
end

function Section:Slider(options)
    local cfg = options or {}
    local text = cfg.text or "Slider"
    local min = cfg.min or 0
    local max = cfg.max or 100
    local callback = cfg.callback
    local value = math.clamp(cfg.default or min, min, max)

    local row = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.card,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, -60, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.window.theme.sub,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLabel = newInstance("TextLabel", {
        Size = UDim2.fromOffset(60, 16),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = self.window.theme.accent,
        TextSize = 13,
        Font = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local track = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.fromOffset(0, 26),
        BackgroundColor3 = self.window.theme.track,
        BorderSizePixel = 0,
        Parent = row,
    })
    withCorner(track, 3)

    local fill = newInstance("Frame", {
        Size = UDim2.fromScale((value - min) / (max - min), 1),
        BackgroundColor3 = self.window.theme.accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    withCorner(fill, 3)
    newInstance("UIGradient", {
        Color = ColorSequence.new(self.window.theme.accentDim, self.window.theme.accent),
        Parent = fill,
    })

    newInstance("Frame", {
        Size = UDim2.fromOffset(13, 13),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = fill,
    }, {
        newInstance("UICorner", {
            CornerRadius = UDim.new(0, 7),
        }),
    })

    local dragging = false

    local function commit(newValue)
        value = math.clamp(math.floor(newValue + 0.5), min, max)
        local ratio = (value - min) / (max - min)
        fill.Size = UDim2.fromScale(ratio, 1)
        valueLabel.Text = tostring(value)
        if callback then
            callback(value)
        end
    end

    local function fromMouseX(mouseX)
        local ratio = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local newValue = min + (max - min) * ratio
        commit(newValue)
    end

    local hitbox = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 18),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })

    hitbox.MouseButton1Down:Connect(function(x)
        dragging = true
        fromMouseX(x)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            fromMouseX(input.Position.X)
        end
    end)

    if callback then
        callback(value)
    end

    return {
        Set = function(_, nextValue)
            commit(nextValue)
        end,
        Get = function()
            return value
        end,
    }
end

function Section:Dropdown(options)
    local cfg = options or {}
    local text = cfg.text or "Dropdown"
    local list = cfg.options or {}
    local callback = cfg.callback

    local selected = cfg.default or list[1] or ""
    local isOpen = false

    local row = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = self.card,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.window.theme.sub,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local box = newInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.fromOffset(0, 18),
        BackgroundColor3 = self.window.theme.elem,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = row,
    })
    withCorner(box, 7)
    withStroke(box, self.window.theme.border, 1, 0.5)

    local selectedLabel = newInstance("TextLabel", {
        Size = UDim2.new(1, -34, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = tostring(selected),
        TextColor3 = self.window.theme.text,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })

    local arrow = newInstance("TextLabel", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -24, 0.5, -9),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = self.window.theme.sub,
        TextSize = 14,
        Font = FONT_BOLD,
        Parent = box,
    })

    local listFrame = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 48),
        BackgroundColor3 = self.window.theme.elem,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = row,
    })
    withCorner(listFrame, 7)
    withStroke(listFrame, self.window.theme.border, 1, 0.5)
    newInstance("UIListLayout", {
        Parent = listFrame,
    })

    local function setSelected(value, silent)
        selected = value
        selectedLabel.Text = tostring(value)
        if callback and not silent then
            callback(value)
        end
    end

    for _, optionValue in ipairs(list) do
        local optionButton = newInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = self.window.theme.elem,
            AutoButtonColor = false,
            Text = tostring(optionValue),
            TextColor3 = self.window.theme.sub,
            TextSize = 13,
            Font = FONT,
            ZIndex = 11,
            BorderSizePixel = 0,
            Parent = listFrame,
        })

        optionButton.MouseEnter:Connect(function()
            tween(optionButton, QUICK, {
                BackgroundColor3 = self.window.theme.elemHover,
                TextColor3 = self.window.theme.text,
            }):Play()
        end)
        optionButton.MouseLeave:Connect(function()
            tween(optionButton, QUICK, {
                BackgroundColor3 = self.window.theme.elem,
                TextColor3 = self.window.theme.sub,
            }):Play()
        end)
        optionButton.MouseButton1Click:Connect(function()
            setSelected(optionValue, false)
            isOpen = false
            listFrame.Visible = false
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            row.Size = UDim2.new(1, 0, 0, 44)
            arrow.Text = "v"
        end)
    end

    box.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local height = #list * 26
            listFrame.Visible = true
            row.Size = UDim2.new(1, 0, 0, 48 + height)
            tween(listFrame, QUICK, {
                Size = UDim2.new(1, 0, 0, height),
            }):Play()
            arrow.Text = "^"
        else
            row.Size = UDim2.new(1, 0, 0, 44)
            listFrame.Visible = false
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            arrow.Text = "v"
        end
    end)

    if callback and selected ~= "" then
        callback(selected)
    end

    return {
        Set = function(_, value)
            setSelected(value, true)
            if callback then
                callback(selected)
            end
        end,
        Get = function()
            return selected
        end,
    }
end

function Section:Keybind(options)
    local cfg = options or {}
    local text = cfg.text or "Keybind"
    local callback = cfg.callback
    local bind = resolveBind(cfg.default) or cfg.default
    local listening = false

    local row = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = self.card,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, -84, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.window.theme.text,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local button = newInstance("TextButton", {
        Size = UDim2.fromOffset(74, 22),
        Position = UDim2.new(1, -74, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.window.theme.elem,
        Text = bindDisplay(bind),
        TextColor3 = self.window.theme.sub,
        TextSize = 12,
        Font = FONT_BOLD,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Parent = row,
    })
    withCorner(button, 6)
    withStroke(button, self.window.theme.border, 1, 0.5)

    local function setBind(newBind, silent)
        bind = newBind
        button.Text = bindDisplay(bind)
        button.TextColor3 = self.window.theme.sub
        if callback and not silent then
            callback(bind)
        end
    end

    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "..."
        button.TextColor3 = self.window.theme.accent
    end)

    local conn = UserInputService.InputBegan:Connect(function(input)
        if listening then
            if input.KeyCode == Enum.KeyCode.Escape then
                listening = false
                setBind(nil, false)
                return
            end
            local nextBind = nil
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                nextBind = input.KeyCode
            elseif MOUSE_NAMES[input.UserInputType] then
                nextBind = input.UserInputType
            end
            if nextBind then
                listening = false
                setBind(nextBind, false)
            end
            return
        end

        if bindMatches(bind, input) and callback then
            callback(bind)
        end
    end)

    table.insert(self.window.connections, conn)

    return {
        Set = function(_, nextBind)
            local resolved = resolveBind(nextBind) or nextBind
            setBind(resolved, true)
            if callback then
                callback(bind)
            end
        end,
        Get = function()
            return bind
        end,
    }
end

function Section:Input(options)
    local cfg = options or {}
    local text = cfg.text or "Input"
    local placeholder = cfg.placeholder or ""
    local callback = cfg.callback
    local clearOnFocus = cfg.clearOnFocus == true

    local row = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Parent = self.card,
    })

    newInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.window.theme.sub,
        TextSize = 13,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local box = newInstance("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = self.window.theme.elem,
        BorderSizePixel = 0,
        Text = tostring(cfg.default or ""),
        PlaceholderText = placeholder,
        PlaceholderColor3 = self.window.theme.dim,
        TextColor3 = self.window.theme.text,
        TextSize = 13,
        Font = FONT,
        ClearTextOnFocus = clearOnFocus,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    withCorner(box, 7)
    withStroke(box, self.window.theme.border, 1, 0.5)
    withPadding(box, 10, 0, 10, 0)

    box.FocusLost:Connect(function(enterPressed)
        if callback then
            callback(box.Text, enterPressed)
        end
    end)

    return {
        Set = function(_, value)
            box.Text = tostring(value or "")
        end,
        Get = function()
            return box.Text
        end,
    }
end

function LunaLib:CreateWindow(config)
    local cfg = normalizeWindowConfig(config)
    local theme = cloneTable(DefaultTheme)
    for key, value in pairs(cfg.theme) do
        theme[key] = value
    end

    local ui = createBaseGui(cfg)
    applyTheme(ui, theme)
    makeDraggable(ui.dragHitbox, ui.window)

    local window = setmetatable({
        ui = ui,
        theme = theme,
        tabs = {},
        tabOrder = {},
        currentTabName = nil,
        visible = cfg.visible,
        keybind = cfg.keybind,
        connections = {},
        notificationIndex = 0,
    }, Window)

    local closeConnection = ui.closeButton.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)
    local toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if bindMatches(window.keybind, input) then
            window:Toggle()
        end
    end)

    table.insert(window.connections, closeConnection)
    table.insert(window.connections, toggleConnection)

    return window
end

LunaLib.Theme = cloneTable(DefaultTheme)

return LunaLib
