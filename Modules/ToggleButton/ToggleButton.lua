local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")
local Options = LibStub("LibSimpleOptions-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CompactActionBar")

--- Toggle Button module
-- Handles the display of toggle button and action bars toggling.
-- @module ToggleButton
-- @alias M
local ToggleButton, M = CompactActionBar:CreateModule("ToggleButton")

--- Table of possible toggle button positions.
M.TOGGLEBUTTONPOS = {
  DISABLED  = 0,  -- Hidden
  LEFT      = 1,  -- Left side of the action bar
  RIGHT     = 2,  -- Right side of the action bar
}

--- Default settings of the module.
local DefaultSettings = {
  ToggleButtonPosition    = M.TOGGLEBUTTONPOS.RIGHT,
  AutoSwitchOnCombat      = true,
  ToggleButtonBagSlots    = true,
}

--- Default properties of the module's fonts.
local DefaultFontProperties = {
  ToggleButtonBagCount = {
    Name        = L["Toggle Button: Bag Slots"],
    Face        = "Arial Narrow",
    Height      = 14,
    Outline     = "OUTLINE",
    Monochrome  = false,
  },
}

--- Options table to add to the settings.
local OptionsTable = {
  name = L["Toggle Button"],
  desc = L["Set the Toggle Button properties."],
  type = "group",
  args = {
    ToggleButtonPosition = {
      order = 0,
      name = L["Show Toggle Button"],
      desc = L["Set if the button to toggle displayed Action Bar side should be visible or not."],
      type = "select",
      values = {
        [M.TOGGLEBUTTONPOS.DISABLED]  = L["Disabled"],
        [M.TOGGLEBUTTONPOS.LEFT]      = L["Left"],
        [M.TOGGLEBUTTONPOS.RIGHT]     = L["Right"],
      },
    },
    AutoSwitchOnCombat = {
      order = 1,
      name = L["Automatically Toggle on Entering Combat"],
      desc = L["Compact Action Bar cannot be toggled while in combat due to Blizzard restrictions. Turn this option on if you want to automatically switch to the Action Bar upon entering combat."],
      type = "toggle",
      width = "full",
    },
    ToggleButtonBagSlots = {
      order = 2,
      name = L["Show the Number of Free Bag Slots"],
      desc = L["Display the number of free bag slots on the Toggle Button."],
      type = "toggle",
      width = "full",
    },
  },
}

--- Default icons enum.
local ICON = {
  BACKPACK  = "Interface/Buttons/Button-Backpack-Up",
  DEFAULT   = 134400, -- Unknown macro
}

--- Toggle button colors enum.
local BUTTONCOLOR = {
  DEFAULT   = {1.000, 1.000, 1.000},
  RED       = {1.000, 0.125, 0.125},
}

--- Set if the button texture is desaturated.
-- @tparam boolean IsDesaturated - Desaturates the button if 'true'.
local function SetButtonIsDesaturated(IsDesaturated)
  assert(type(IsDesaturated) == "boolean", "IsDesaturated must be a boolean.")

  M.ToggleButtonTexture:SetDesaturated(IsDesaturated)
end

--- Set if the button texture should be colored red.
-- @tparam boolean IsRed - Makes the button red if 'true'.
local function SetButtonIsRed(IsRed)
  assert(type(IsRed) == "boolean", "IsRed must be a boolean.")

  local ButtonColor = BUTTONCOLOR.DEFAULT

  if (IsRed) then
    ButtonColor = BUTTONCOLOR.RED
  end

  M.ToggleButtonTexture:SetVertexColor(ButtonColor[1], ButtonColor[2], ButtonColor[3])
end

--- Set if the button should display action icon or backpack icon.
-- Looks for first visible action button in main bar and uses its icon.
-- If no buttons are visible, sets the default [?] macro icon.
-- @tparam boolean IsActionIcon - Sets the action icon if 'true', backpack icon otherwise.
local function SetIsActionButtonIcon(IsActionIcon)
  assert(type(IsActionIcon) == "boolean", "IsActionIcon must be a boolean.")

  local ButtonTexture = nil

  -- Get first visible action button icon
  if (IsActionIcon) then
    for i = 1, 12 do
      if (ButtonTexture ~= nil) then break end

      local ActionButton = _G["ActionButton"..i.."Icon"]
      local ActionButtonTexture = ActionButton:GetTexture()

      if (ActionButton:IsShown() and ActionButtonTexture ~= nil) then
        ButtonTexture = ActionButtonTexture
      end
    end

    -- If we couldn't find a button, show default [?] macro icon
    if (ButtonTexture == nil) then
      ButtonTexture = ICON.DEFAULT
    end

  -- Backpack icon
  else
    ButtonTexture = ICON.BACKPACK
  end

  M.ToggleButtonTexture:SetTexture(ButtonTexture)
end

--- Set the visibility of the toggle button.
-- @tparam boolean IsVisible - Whether the button is visible or not.
local function SetToggleButtonVisibility(IsVisible)
  assert(type(IsVisible) == "boolean", "IsVisible must be a boolean.")

  M.ToggleButtonFrame:SetShown(IsVisible)
end

--- Set the side at hich the button is shown.
-- @tparam boolean InLeft - Will show the button on left side if 'true', otherwise on right.
local function SetToggleButtonInLeft(InLeft)
  assert(type(InLeft) == "boolean", "InLeft must be a boolean.")

  M.ToggleButtonContainer:ClearAllPoints()

  if (InLeft) then
    M.ToggleButtonContainer:SetPoint("CENTER", MainMenuBar, "BOTTOMLEFT", -21, 21)
  else
    M.ToggleButtonContainer:SetPoint("CENTER", MainMenuBar, "BOTTOMRIGHT", 21, 21)
  end
end

--- Set the visibility of free bag slots counter label.
-- @tparam boolean IsVisible - Label visibility.
local function SetBagSlotsCountVisibility(IsVisible)
  assert(type(IsVisible) == "boolean", "IsVisible must be a boolean.")

  M.FreeBagSlotsCount:SetShown(IsVisible)
end

--- Set the text of free bag slots counter label.
-- @param Text - Text to show, can be 'string' or 'number'.
local function SetBagSlotsCountText(Text)
  M.FreeBagSlotsCount:SetText(Text)
end

--- Set the properties of the bag slots counter label.
-- @tparam table FontProperties - Properties of the font to set.
local function SetBagSlotsCountFontProperties(FontProperties)
  assert(type(FontProperties) == "table", "FontProperties must be a table.")

  Options:ApplyFontProperties(M.FreeBagSlotsCount, FontProperties)
end

--- Catch a WoW interface event.
-- @tparam table self - Event handling frame.
-- @tparam string Event - Name of the caught event.
local function OnEvent(self, Event)
  -- Entering combat
  if (Event == "PLAYER_REGEN_DISABLED") then
    M.IsInCombat = true

  -- Leaving combat
  elseif (Event == "PLAYER_REGEN_ENABLED") then
    M.IsInCombat = false
  end

  -- Auto switch on combat
  if (M.AutoSwitchOnCombat and M.IsInCombat) then
    M:SetToggleState(false)
  end

  M:Update()
end

--- Listen to addon configuration update.
local function OnConfigUpdate()
  -- Settings
  M.ToggleButtonPosition    = Options:Get("ToggleButtonPosition")
  M.AutoSwitchOnCombat      = Options:Get("AutoSwitchOnCombat")
  M.ShowBagSlotsCount       = Options:Get("ToggleButtonBagSlots")

  SetBagSlotsCountFontProperties(Options:GetFontProperties("ToggleButtonBagCount"))

  M:Update()
end

--- Initialize the module.
function ToggleButton:Init()
  if (CompactActionBar.GameVersion ~= CompactActionBar.GAMEVERSION.CLASSIC) then return end

  -- Togle button container
  self.ToggleButtonContainer = CreateFrame("Frame", "CompactActionBarToggleButtonContainer", MainMenuBar)
  self.ToggleButtonContainer:SetPoint("CENTER", MainMenuBar, "BOTTOMRIGHT", 21, 21)
  self.ToggleButtonContainer:SetWidth(42)
  self.ToggleButtonContainer:SetHeight(42)
  self.ToggleButtonContainer:SetFrameLevel(5)

  -- The toggle button
  local FrameType = "Button"
  local FrameTemplate = "ItemButtonTemplate"

  -- Retail uses a separate frame type for item buttons
  if (CompactActionBar.GameVersion == CompactActionBar.GAMEVERSION.RETAIL) then
    FrameType = "ItemButton"
    FrameTemplate = nil
  end

  self.ToggleButtonFrame = CreateFrame(FrameType, "CompactActionBarToggleButton", self.ToggleButtonContainer, FrameTemplate)
  self.ToggleButtonFrame:SetPoint("CENTER", self.ToggleButtonContainer, "CENTER", 0, 0)
  self.ToggleButtonFrame:SetScale(0.75)
  self.ToggleButtonFrame:SetScript("OnClick", function() self:InvertToggleState() end)
  self.ToggleButtonTexture = _G[self.ToggleButtonFrame:GetName().."IconTexture"]

  -- Free bag slots counter
  -- Separate FontString as button count scales button itself
  self.FreeBagSlotsCount = self.ToggleButtonFrame:CreateFontString(self.ToggleButtonFrame, "HIGH")
  self.FreeBagSlotsCount:SetPoint("BOTTOMRIGHT", self.ToggleButtonFrame, "BOTTOMRIGHT", -1, 1)
  self.FreeBagSlotsCount:SetFont("Fonts\\ARIALN.TTF", 14, "OUTLINE")
  self.FreeBagSlotsCount:SetScale(1 / self.ToggleButtonFrame:GetScale())
  SetBagSlotsCountText("48")

  -- Configure module settings
  Options:AddDefaults(DefaultSettings)
  Options:AddFontProperties(DefaultFontProperties)
  Options:AddOptionsTable(OptionsTable)
  Options:AddListener(OnConfigUpdate)

  -- Init
  self.IsToggled            = false
  self.IsToggleButtonShown  = true
  self.IsInCombat           = InCombatLockdown()
  self.AutoSwitchOnCombat   = DefaultSettings.AutoSwitchOnCombat
  self.ShowBagSlotsCount    = DefaultSettings.ToggleButtonBagSlots

  -- Call self update if any of these events are fired
  local WatchedEvents = {
    "PLAYER_REGEN_DISABLED",  -- Enter combat
    "PLAYER_REGEN_ENABLED",   -- Leave combat
    "ACTIONBAR_PAGE_CHANGED",
    "ACTIONBAR_UPDATE_STATE",
    "BAG_UPDATE",
  }

  CompactActionBar:ModuleSubscribeToEvents(self.ToggleButtonContainer, WatchedEvents, OnEvent)

  -- Key bindings localisation
  BINDING_NAME_COMPACTACTIONBAR_TOGGLEBUTTONS = L["Toggle Action Bar / Options"]

  -- Update
  self:Update()
end

--- Module global update.
function ToggleButton:Update()
  if (CompactActionBar.GameVersion ~= CompactActionBar.GAMEVERSION.CLASSIC) then return end

  local LayoutManager = CompactActionBar:GetModule("LayoutManager")

  --- Set button visibility based on current compact bar mode.
  if (LayoutManager ~= nil) then
    self.IsToggleButtonShown = LayoutManager.CompactBarMode == LayoutManager.COMPACTBARMODE.TOGGLE
  end

  SetToggleButtonVisibility(self.ToggleButtonPosition ~= self.TOGGLEBUTTONPOS.DISABLED and self.IsToggleButtonShown)

  -- Continue if not visible
  if (not self.ToggleButtonFrame:IsShown()) then return end

  -- Free bag slots
  local ShowBagSlotsCount = not self.IsToggled and self.ShowBagSlotsCount
  local FreeBagSlotsCount = 0

  for i = 0, 4 do
    FreeBagSlotsCount = FreeBagSlotsCount + GetContainerNumFreeSlots(i)
  end

  -- Set appearance
  local IsButtonRed = ShowBagSlotsCount and FreeBagSlotsCount <= 0

  SetToggleButtonInLeft(self.ToggleButtonPosition == self.TOGGLEBUTTONPOS.LEFT)
  SetButtonIsDesaturated(self.IsInCombat or IsButtonRed)
  SetButtonIsRed(IsButtonRed)
  SetIsActionButtonIcon(self.IsToggled)
  SetBagSlotsCountVisibility(ShowBagSlotsCount)
  SetBagSlotsCountText(FreeBagSlotsCount)
  self.ToggleButtonFrame:SetEnabled(not self.IsInCombat)
end

--- Set the toggle state of the button.
-- This method will fail in combat or if the target state is already active.
-- @tparam boolean IsToggled - Whether the button is toggled or not.
function ToggleButton:SetToggleState(IsToggled)
  assert(type(IsToggled) == "boolean", "IsToggled must be a boolean.")

  if (InCombatLockdown() or self.IsToggled == IsToggled) then return end

  self.IsToggled = IsToggled
  self:Update()

  -- Trigger an update on the addon.
  CompactActionBar:Update()
end

--- Invert the current toggle state of the button.
-- This method will fail in combat and send a warning in chat.
function ToggleButton:InvertToggleState()
  if (InCombatLockdown()) then
    SendSystemMessage(L["Can't toggle the action bar while in combat."])
    return
  end

  self:SetToggleState(not self.IsToggled)
  PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end

--- Toggle between left and right section, called on configurable keybind press.
function CompactActionBar_ToggleButton_InvertToggleState()
  if (not M.IsToggleButtonShown) then return end

  M:InvertToggleState()
end
