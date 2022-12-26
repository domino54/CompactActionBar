local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")
local Options = LibStub("LibSimpleOptions-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CompactActionBar")

--- Button Colors module
-- Handles the coloring of action bar buttons when out of range, not enough mana, etc.
-- @module ButtonColors
-- @alias M
local ButtonColors, M = CompactActionBar:CreateModule("ButtonColors")

--- Default settings of the module.
local DefaultSettings = {
  EnableFastColorUpdates  = false,
  DesaturateOnCooldown    = true,
  OutOfRangeEnabled       = true,
  OutOfRangeColor         = {1.000, 0.125, 0.125},
  NotEnoughManaEnabled    = true,
  NotEnoughManaColor      = {0.125, 0.125, 1.000},
  ManaAndRangeEnabled     = false,
  ManaAndRangeColor       = {1.000, 0.125, 1.000},
  UnusableActionEnabled   = true,
  UnusableActionColor     = {0.375, 0.375, 0.375},
}

--- Options table to add to the settings.
local OptionsTable = {
  name = L["Button Colors"],
  desc = L["Signify if the target is out of range & more."],
  type = "group",
  args = {
    EnableFastColorUpdates = {
      order = 0,
      name = L["Enable Fast Color Updates"],
      desc = L["If this option is checked, the button colors will update much faster when stepping in/out of range and when the cooldown is ready. It may impact the game performance."],
      type = "toggle",
      width = "full",
    },
    DesaturateOnCooldown = {
      order = 1,
      name = L["Desaturate Spells When on Cooldown"],
      desc = L["Signifies that an ability cannot be used because it's on cooldown."],
      type = "toggle",
      width = "full",
    },
    OutOfRangeHeader = {
      order = 2,
      name = L["Out of Range"],
      type = "header",
    },
    OutOfRangeColor = {
      order = 3,
      name = "",
      type = "color",
      width = 0.15,
      get = function(info) return Options:GetColor(info[#info]) end,
      set = function(info, r, g, b) Options:Set(info[#info], {r, g, b}) end,
    },
    OutOfRangeEnabled = {
      order = 4,
      name = L["Enabled"],
      desc = L["Colorize the button if the target is out of range."],
      type = "toggle",
      width = "half",
    },
    NotEnoughManaHeader = {
      order = 5,
      name = L["Not Enough Mana"],
      type = "header",
    },
    NotEnoughManaColor = {
      order = 6,
      name = "",
      type = "color",
      width = 0.15,
      get = function(info) return Options:GetColor(info[#info]) end,
      set = function(info, r, g, b) Options:Set(info[#info], {r, g, b}) end,
    },
    NotEnoughManaEnabled = {
      order = 7,
      name = L["Enabled"],
      desc = L["Colorize the button if more mana is needed to cast the ability."],
      type = "toggle",
      width = "half",
    },
    ManaAndRangeHeader = {
      order = 8,
      name = L["Out of Range & Not Enough Mana"],
      type = "header",
    },
    ManaAndRangeColor = {
      order = 9,
      name = "",
      type = "color",
      width = 0.15,
      get = function(info) return Options:GetColor(info[#info]) end,
      set = function(info, r, g, b) Options:Set(info[#info], {r, g, b}) end,
    },
    ManaAndRangeEnabled = {
      order = 10,
      name = L["Enabled"],
      desc = L["Colorize the button if more mana is needed to cast the ability and target is out of range."],
      type = "toggle",
      width = "half",
    },
    UnusableActionHeader = {
      order = 11,
      name = L["Action Unusable"],
      type = "header",
    },
    UnusableActionColor = {
      order = 12,
      name = "",
      type = "color",
      width = 0.15,
      get = function(info) return Options:GetColor(info[#info]) end,
      set = function(info, r, g, b) Options:Set(info[#info], {r, g, b}) end,
    },
    UnusableActionEnabled = {
      order = 13,
      name = L["Enabled"],
      desc = L["Colorize the button if the ability cannot be used."],
      type = "toggle",
      width = "half",
    },
  },
}

--- Table storing previous information regarding a slot's action, to reduce unnecessary button updates.
local PrevActionInfo = {}
local PrevRangeTimer = {}

--- Periodically update buttons colors in retail.
local UPDATEPERIOD = {
  DEFAULT = 0.100,
  FAST    = 0.050,
}

--- Table storing all watched buttons in retail.
local ButtonsChecked = {}

--- Check if an action is out of range.
-- @tparam number ActionSlot - Action slot to check.
-- @treturn boolean - 'true' if out of range.
local function IsActionOutOfRange(ActionSlot)
  assert(type(ActionSlot) == "number", "ActionSlot must be a number.")

  local InRange = IsActionInRange(ActionSlot)
  return InRange ~= nil and not InRange
end

--- Check if an action has not enough mana.
-- @tparam number ActionSlot - Action slot to check.
-- @treturn boolean - 'true' if not enough mana.
local function IsActionNotEnoughMana(ActionSlot)
  assert(type(ActionSlot) == "number", "ActionSlot must be a number.")

  local _, NotEnoughMana = IsUsableAction(ActionSlot)
  return NotEnoughMana
end

--- Check if an action is currently unusable.
-- @tparam number ActionSlot - Action slot to check.
-- @treturn boolean - 'true' if currently unusable.
local function IsActionUnusable(ActionSlot)
  assert(type(ActionSlot) == "number", "ActionSlot must be a number.")

  local ActionType = GetActionInfo(ActionSlot)

  -- Unusable if there's no item in bags
  if (ActionType == "item") then
    return GetActionCount(ActionSlot) <= 0
  end

  local IsUsable = IsUsableAction(ActionSlot)
  return not IsUsable
end

--- Check if an action is on cooldown.
-- @tparam number ActionSlot - Action slot to check.
-- @treturn boolean - 'true' if on cooldown.
local function IsActionOnCooldown(ActionSlot)
  assert(type(ActionSlot) == "number", "ActionSlot must be a number.")

  local CooldownStart, CooldownDuration = GetActionCooldown(ActionSlot)
  return GetTime() <= CooldownStart + CooldownDuration
end

--- Set the color of a texture.
-- @tparam table Texture - Texture object to colorize.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
local function SetTextureVertexColor(Texture, Color)
  assert(type(Texture) == "table", "Texture must be a table.")
  assert(type(Color) == "table", "Color must be a table.")

  Texture:SetVertexColor(Color[1], Color[2], Color[3])
end

--- Update the color of an action button.
-- @tparam table ActionButton - Button to set its color.
local function UpdateActionButtonColor(ActionButton)
  if (ActionButton == nil) then return end

  -- Action button
  local ActionButtonName  = ActionButton:GetName()
  local ActionSlot        = ActionButton.action
  local ActionButtonIcon  = _G[ActionButtonName.."Icon"]

  -- Action info
  local IsOutOfRange      = M.Colors["Range"].IsEnabled     and IsActionOutOfRange(ActionSlot)
  local IsUnusable        = M.Colors["Unusable"].IsEnabled  and IsActionUnusable(ActionSlot)
  local NotEnoughMana     = M.Colors["Mana"].IsEnabled      and IsActionNotEnoughMana(ActionSlot)
  local IsOnCooldown      = M.DesaturateOnCooldown          and IsActionOnCooldown(ActionSlot)

  -- Current color properties
  local Color             = M.Colors["Default"].Color
  local Desaturate        = IsOnCooldown

  -- Mixed color if not enough mana and out of range
  if (M.Colors["ManaRange"].IsEnabled and NotEnoughMana and IsOutOfRange) then
    Color = M.Colors["ManaRange"].Color
    Desaturate = true

  -- Blue color if not enough mana
  elseif (NotEnoughMana) then
    Color = M.Colors["Mana"].Color
    Desaturate = true

  -- Slightly darken if action is unusable
  elseif (IsUnusable) then
    Color = M.Colors["Unusable"].Color

  -- Red if target is out of range
  elseif (IsOutOfRange) then
    Color = M.Colors["Range"].Color
    Desaturate = true
  end

  SetTextureVertexColor(ActionButtonIcon, Color)
  ActionButtonIcon:SetDesaturated(Desaturate)
end

--- Hooked function called on every update of the action button.
-- @tparam table self - The button calling the function.
-- @tparam number elapsed - Time since the last update.
local function ActionButton_OnUpdate(self, elapsed)
  -- If it's not fast mode, keep some time between updates
  if (not M.IsFastUpdateMode) then
    if (PrevRangeTimer[self.action] == nil) then
      PrevRangeTimer[self.action] = -1
    end

    PrevRangeTimer[self.action] = PrevRangeTimer[self.action] - elapsed
    if (PrevRangeTimer[self.action] > 0) then return end
    PrevRangeTimer[self.action] = TOOLTIP_UPDATE_TIME
  end

  local ActionInfo = {
    IsOutOfRange = IsActionOutOfRange(self.action),
    IsOnCooldown = IsActionOnCooldown(self.action),
  }

  -- Check for changes
  if (
    PrevActionInfo[self.action] == nil or
    PrevActionInfo[self.action] ~= ActionInfo
  ) then
    PrevActionInfo[self.action] = ActionInfo
    UpdateActionButtonColor(self)
  end
end

--- Hooked function called whenever a spell becomes usable or unusable.
-- @tparam table self - The button calling the function.
local function ActionButton_UpdateUsable(self)
  UpdateActionButtonColor(self)
end

--- Periodically update buttons in retail.
-- This function calls itself every 100 ms.
-- Make sure to only call this once, ever.
local function PeriodicUpdate()
  for i, Button in pairs(ButtonsChecked) do
    UpdateActionButtonColor(Button)
  end

  local UpdatePeriod = UPDATEPERIOD.DEFAULT

  if (M.IsFastUpdateMode) then
    UpdatePeriod = UPDATEPERIOD.FAST
  end

  C_Timer.After(UpdatePeriod, PeriodicUpdate)
end

--- Set the color values of a given case.
-- @tparam string Name - Name of the case, as 'Range', 'Mana', etc.
-- @tparam boolean IsEnabled - If the coloring case should be enabled or not.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
local function SetColor(Name, IsEnabled, Color)
  assert(type(Name) == "string", "Name must be a string.")
  assert(type(IsEnabled) == "boolean", "IsEnabled must be a boolean.")
  assert(type(Color) == "table", "Color must be a table.")

  M.Colors[Name] = {
    IsEnabled = IsEnabled,
    Color = Color,
  }
end

--- Listen to addon configuration update.
local function OnConfigUpdate()
  -- Settings
  M.IsFastUpdateMode        = Options:Get("EnableFastColorUpdates")
  M.DesaturateOnCooldown    = Options:Get("DesaturateOnCooldown")

  -- Set default colors
  SetColor("Range",     Options:Get("OutOfRangeEnabled"),     Options:Get("OutOfRangeColor"))
  SetColor("Mana",      Options:Get("NotEnoughManaEnabled"),  Options:Get("NotEnoughManaColor"))
  SetColor("ManaRange", Options:Get("ManaAndRangeEnabled"),   Options:Get("ManaAndRangeColor"))
  SetColor("Unusable",  Options:Get("UnusableActionEnabled"), Options:Get("UnusableActionColor"))
end

--- Initialize the module.
function ButtonColors:Init()
  -- Configure module settings
  Options:AddDefaults(DefaultSettings)
  Options:AddOptionsTable(OptionsTable)
  Options:AddListener(OnConfigUpdate)

  -- Settings
  self.IsFastUpdateMode       = DefaultSettings.EnableFastColorUpdates
  self.DesaturateOnCooldown   = DefaultSettings.DesaturateOnCooldown

  -- Set default colors
  self.Colors = {}
  SetColor("Default",    true,                                   {1.000, 1.000, 1.000})
  SetColor("Range",      DefaultSettings.OutOfRangeEnabled,      DefaultSettings.OutOfRangeColor)
  SetColor("Mana",       DefaultSettings.NotEnoughManaEnabled,   DefaultSettings.NotEnoughManaColor)
  SetColor("ManaRange",  DefaultSettings.ManaAndRangeEnabled,    DefaultSettings.ManaAndRangeColor)
  SetColor("Unusable",   DefaultSettings.UnusableActionEnabled,  DefaultSettings.UnusableActionColor)

  -- Hook action button functions - retail
  if (CompactActionBar.GameVersion == CompactActionBar.GAMEVERSION.RETAIL) then
    local Frame = EnumerateFrames()

    while Frame do
      if Frame.OnLoad == ActionBarActionButtonMixin.OnLoad then
        table.insert(ButtonsChecked, Frame)
        hooksecurefunc(Frame, "Update", ActionButton_UpdateUsable)
        hooksecurefunc(Frame, "UpdateUsable", ActionButton_UpdateUsable)
      end

      Frame = EnumerateFrames(Frame)
    end

    -- Start the periodic updates
    PeriodicUpdate()

  -- Hook action button functions - Classic and BC Classic
  elseif (
    CompactActionBar.GameVersion == CompactActionBar.GAMEVERSION.CLASSIC or
    CompactActionBar.GameVersion == CompactActionBar.GAMEVERSION.TBC or
    CompactActionBar.GameVersion == CompactActionBar.GAMEVERSION.WRATH
  ) then
    hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdate)
    hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUsable)
  end
end
