# LunaLib

Compact Roblox UI library extracted into a reusable module.

## Files

- `luna_lib.lua` - library module
- `luna_lib_example.lua` - full example with all interfaces

## Quick Start

```lua
local LunaLib = loadstring(readfile("luna_lib.lua"))()

local window = LunaLib:CreateWindow({
    name = "My UI",
    keybind = Enum.KeyCode.RightShift,
})

local tab = window:Tab({ name = "Main" })
local section = tab:Section({ name = "Controls" })

section:Toggle({
    text = "God mode",
    default = false,
    callback = function(v)
        print("God mode:", v)
    end,
})
```

## Window API

- `LunaLib:CreateWindow(config)` -> `window`
- `window:Tab({ name = "..." })` -> `tab`
- `window:Notify({ title, message, kind, duration })`
- `window:SetVisible(boolean)`
- `window:Toggle()`
- `window:Destroy()`

### Window config

- `name` (string) - title in sidebar
- `size` (UDim2) - window size, default `UDim2.fromOffset(980, 600)`
- `position` (UDim2) - default center
- `keybind` (Enum.KeyCode or Enum.UserInputType) - toggle key
- `visible` (boolean) - initial visibility
- `destroyExisting` (boolean) - remove old `LunaLibraryUI` if true
- `theme` (table) - override theme colors

## Tab API

- `tab:Section({ name = "..." })` -> `section`

## Section Widgets

Each widget returns a small controller object.

- `section:Label(text)` -> `{ Set, Get }`
- `section:Info(key, value, valueColor?)` -> `{ Set, Get }`
- `section:Button({ text, primary?, callback })` -> `{ SetText }`
- `section:Toggle({ text, default?, callback })` -> `{ Set, Get }`
- `section:Slider({ text, min, max, default?, callback })` -> `{ Set, Get }`
- `section:Dropdown({ text, options, default?, callback })` -> `{ Set, Get }`
- `section:Keybind({ text, default?, callback })` -> `{ Set, Get }`
- `section:Input({ text, placeholder?, default?, callback, clearOnFocus? })` -> `{ Set, Get }`

## Notes

- `Toggle`, `Slider`, `Dropdown`, `Keybind`, `Input` call callback on value changes.
- `Keybind` callback also fires when the bind key is pressed.
- Press the window keybind to show/hide the menu.

## Theme Keys

`bg`, `side`, `card`, `elem`, `elemHover`, `track`, `border`, `accent`, `accentDim`, `text`, `sub`, `dim`, `green`, `red`, `orange`

Example:

```lua
local window = LunaLib:CreateWindow({
    name = "Custom Theme",
    theme = {
        accent = Color3.fromRGB(255, 80, 160),
        bg = Color3.fromRGB(10, 10, 16),
    },
})
```
