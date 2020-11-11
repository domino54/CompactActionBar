local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")

--- Button Colors module
-- Handles the coloring of action bar buttons when out of range, not enough mana, etc.
-- @module ButtonColors
-- @alias M
local ButtonColors, M = CompactActionBar:CreateModule("ButtonColors")

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
  local Desaturate        = false

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
    Desaturate = IsOnCooldown

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

--- Initialize the module.
-- @tparam number GameVersion - Current game version.
function ButtonColors:Init(GameVersion)
  assert(type(GameVersion) == "number", "GameVersion must be a number.")

  -- Settings
  self.IsFastUpdateMode       = false
  self.DesaturateOnCooldown   = true

  -- Set default colors
  self.Colors = {}
  self:SetColor("Default",    true,   {1.000, 1.000, 1.000})
  self:SetColor("Range",      true,   {1.000, 0.125, 0.125})
  self:SetColor("Mana",       true,   {0.125, 0.125, 1.000})
  self:SetColor("ManaRange",  false,  {1.000, 0.125, 1.000})
  self:SetColor("Unusable",   true,   {0.375, 0.375, 0.375})

  -- Hook action button functions - retail
  if (GameVersion == CompactActionBar.GAMEVERSION.RETAIL) then
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

  -- Hook action button functions - Classic
  elseif (GameVersion == CompactActionBar.GAMEVERSION.CLASSIC) then
    hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdate)
    hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUsable)
  end
end

--- Set the color values of a given case.
-- @tparam string Name - Name of the case, as 'Range', 'Mana', etc.
-- @tparam boolean IsEnabled - If the coloring case should be enabled or not.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
function ButtonColors:SetColor(Name, IsEnabled, Color)
  assert(type(Name) == "string", "Name must be a string.")
  assert(type(IsEnabled) == "boolean", "IsEnabled must be a boolean.")
  assert(type(Color) == "table", "Color must be a table.")

  self.Colors[Name] = {
    IsEnabled = IsEnabled,
    Color = Color,
  }
end

--- Set the color value for out of range case.
-- @tparam boolean IsEnabled - If the coloring case should be enabled or not.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
function ButtonColors:SetOutOfRangeColor(IsEnabled, Color)
  self:SetColor("Range", IsEnabled, Color)
end

--- Set the color value for not enough mana case.
-- @tparam boolean IsEnabled - If the coloring case should be enabled or not.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
function ButtonColors:SetNotEnoughManaColor(IsEnabled, Color)
  self:SetColor("Mana", IsEnabled, Color)
end

--- Set the color value for not enough mana and out of range case.
-- @tparam boolean IsEnabled - If the coloring case should be enabled or not.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
function ButtonColors:SetManaAndRangeColor(IsEnabled, Color)
  self:SetColor("ManaRange", IsEnabled, Color)
end

--- Set the color value for action unusable case.
-- @tparam boolean IsEnabled - If the coloring case should be enabled or not.
-- @tparam table Color - Table representing a color where keys 1, 2, 3 are R, G, B values.
function ButtonColors:SetUnusableColor(IsEnabled, Color)
  self:SetColor("Unusable", IsEnabled, Color)
end

--- Set if the buttons should update in fast mode.
-- @tparam boolean IsFastUpdateMode - If 'true', ActionButton_OnUpdate will skip the rangeTimer check for faster but more expensive updates.
function ButtonColors:SetIsFastUpdateMode(IsFastUpdateMode)
  assert(type(IsFastUpdateMode) == "boolean", "IsFastUpdateMode must be a boolean.")

  self.IsFastUpdateMode = IsFastUpdateMode
end

--- Set if the buttons should be desaturated if the action is on cooldown.
-- @tparam boolean DesaturateOnCooldown - If 'true', buttons will desaturate on cooldown.
function ButtonColors:SetDesaturateOnCooldown(DesaturateOnCooldown)
  assert(type(DesaturateOnCooldown) == "boolean", "DesaturateOnCooldown must be a boolean.")

  self.DesaturateOnCooldown = DesaturateOnCooldown
end
