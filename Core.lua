local CompactActionBar = LibStub("AceAddon-3.0"):NewAddon("CompactActionBar")
local Media = LibStub("LibSharedMedia-3.0")

--- Table of supported game versions.
CompactActionBar.GAMEVERSION = {
  UNKNOWN  = 0,   -- TBC Classic! Or something else
  RETAIL   = 1,   -- World of Warcraft Shadowlands
  CLASSIC  = 2,   -- World of Warcraft Classic
}

--- Table of available Compact Action Bar modes.
CompactActionBar.COMPACTBARMODE = {
  DISABLED  = 0,  -- Long bar as default look of WoW Classic
  TOGGLE    = 1,  -- Shortened bar, left and right side toggled via button
  STACKED   = 2,  -- Shortened bar, left and right side above each other
}

--- Table of possible toggle button positions.
CompactActionBar.TOGGLEBUTTONPOS = {
  DISABLED  = 0,  -- Hidden
  LEFT      = 1,  -- Left side of the action bar
  RIGHT     = 2,  -- Right side of the action bar
}

--- Table of available modules ready to be initialized.
CompactActionBar.Modules      = {}
--- Base path to the resources of the addon.
CompactActionBar.MediaRoot    = "Interface/Addons/CompactActionBar/"
--- Current game version the addon is loaded in.
CompactActionBar.GameVersion  = CompactActionBar.GAMEVERSION.UNKNOWN

--- Gets the version of the game the addon is running in.
-- @treturn number - Current game version.
local function GetGameVersion()
  -- Retail
  if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
    return CompactActionBar.GAMEVERSION.RETAIL

  -- Classic
  elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then
    return CompactActionBar.GAMEVERSION.CLASSIC
  end

  -- Unknown
  return CompactActionBar.GAMEVERSION.UNKNOWN
end

--- Create a new module for the addon.
-- @tparam string ModuleName - Name of the module to create.
-- @treturn table - Newly created module.
function CompactActionBar:CreateModule(ModuleName)
  assert(type(ModuleName) == "string", "ModuleName must be a string.")
  assert(self.Modules[ModuleName] == nil, "A module named \""..ModuleName.."\" has already been created.")

  local Module = {
    ModuleName = ModuleName
  }

  self.Modules[ModuleName] = Module

  -- Double return for easier handle declaration within module files
  return Module, Module
end

--- Subscribe a module to select game events.
-- @tparam table Frame - Frame that subscribes to events.
-- @tparam table EventNames - Table of 'string' names of events to watch.
-- @tparam function Callback - Event handler to call upon receiving an event.
function CompactActionBar:ModuleSubscribeToEvents(Frame, EventNames, Callback)
  assert(type(Frame) == "table", "Frame must be a table.")
  assert(type(EventNames) == "table", "EventNames must be a table.")
  assert(type(Callback) == "function", "Callback must be a function.")

  for i, EventName in pairs(EventNames) do
    Frame:RegisterEvent(EventName)
  end

  Frame:SetScript("OnEvent", Callback)
end

--- Get a created module and initialize it.
-- @tparam string ModuleName - Name of the module to get.
-- @treturn table - Initialized module.
function CompactActionBar:GetAndInitModule(ModuleName)
  assert(type(ModuleName) == "string", "ModuleName must be a string.")
  assert(self.Modules[ModuleName] ~= nil, "No module named \""..ModuleName.."\" exists.")
  assert(type(self.Modules[ModuleName]) == "table", "Module \""..ModuleName.."\" is not a table.")

  local Module = self.Modules[ModuleName]
  Module:Init(CompactActionBar.GameVersion)
  return Module
end

--- Apply font properties table to a FontString.
-- @tparam table FontString - Target FontString to apply font properties.
-- @tparam table FontProperties - Properties of the font.
function CompactActionBar:ApplyFontProperties(FontString, FontProperties)
  assert(type(FontString) == "table", "FontString must be a table.")
  assert(type(FontProperties) == "table", "FontProperties must be a table.")
  assert(type(FontProperties.Face) == "string", "FontProperties.Face must be a string.")
  assert(type(FontProperties.Height) == "number", "FontProperties.Height must be a number.")
  assert(type(FontProperties.Outline) == "string", "FontProperties.Outline must be a string.")
  assert(type(FontProperties.Monochrome) == "boolean", "FontProperties.Monochrome must be a boolean.")

  -- Create font flags string
  local FontFlagsList = {}

  if (FontProperties.Outline ~= "") then
    table.insert(FontFlagsList, FontProperties.Outline)
  end

  if (FontProperties.Monochrome) then
    table.insert(FontFlagsList, "MONOCHROME")
  end

  local FontFlags = table.concat(FontFlagsList, ", ")

  FontString:SetFont(Media:Fetch("font", FontProperties.Face), FontProperties.Height, FontFlags)
end

--- Initialize the Compact Action Bar addon.
function CompactActionBar:OnInitialize()
  self.GameVersion      = GetGameVersion()
  self.Options          = self:GetAndInitModule("Options")
  self.ToggleButton     = self:GetAndInitModule("ToggleButton")
  self.ButtonColors     = self:GetAndInitModule("ButtonColors")

  -- Modules to load if running RETAIL
  if (self.GameVersion == CompactActionBar.GAMEVERSION.RETAIL) then
    --self.LayoutManager  = self.GetAndInitModule("LayoutManager/Retail")

  -- Modules to load if running CLASSIC
  elseif (self.GameVersion == CompactActionBar.GAMEVERSION.CLASSIC) then
    self.LayoutManager  = self:GetAndInitModule("LayoutManager/Classic")
  end

  self:Update()
end

--- Global update, called when a module requests a global update.
function CompactActionBar:Update()
  if (self.Options == nil) then return end

  local LabelFontProperties = self.Options:Get("LabelFontProperties")
  local IsToggled = false

  -- Update toggle button
  if (self.ToggleButton ~= nil) then
    IsToggled = self.ToggleButton.IsToggled

    self.ToggleButton:SetToggleButtonVisibility     (self.Options:Get("CompactBarMode") == CompactActionBar.COMPACTBARMODE.TOGGLE and self.Options:Get("ToggleButtonPosition") ~= CompactActionBar.TOGGLEBUTTONPOS.DISABLED)
    self.ToggleButton:SetToggleButtonInLeft         (self.Options:Get("ToggleButtonPosition") == CompactActionBar.TOGGLEBUTTONPOS.LEFT)
    self.ToggleButton:SetAutoSwitchOnCombat         (self.Options:Get("AutoSwitchOnCombat"))
    self.ToggleButton:SetShowBagSlotsCount          (self.Options:Get("ToggleButtonBagSlots"))
    self.ToggleButton:SetBagSlotsCountText          (LabelFontProperties["ToggleButtonBagCount"])

    self.ToggleButton:Update()
  end

  -- Update layout manager
  if (self.LayoutManager ~= nil) then
    -- Compact Bar Mode
    self.LayoutManager:SetCompactBarMode            (self.Options:Get("CompactBarMode"))
    self.LayoutManager:SetPageSwitchInLeft          (self.Options:Get("IncludeBarSwitcher"))
    self.LayoutManager:SetIsActionBarToggled        (IsToggled)

    -- Position & Scale
    self.LayoutManager:SetMainMenuBarScale          (self.Options:Get("MainMenuBarScale"))
    self.LayoutManager:SetMainMenuBarOffset         (self.Options:Get("MainMenuBarOffsetX"), self.Options:Get("MainMenuBarOffsetY"))
    self.LayoutManager:SetMainMenuBarStrata         (self.Options:Get("MainMenuBarStrata"))
    self.LayoutManager:SetMainMenuBarOpacity        (self.Options:Get("MainMenuBarOpacity"))
    self.LayoutManager:SetMainMenuTextureOpacity    (self.Options:Get("MainMenuTextureOpacity"))

    -- Experience Bar
    self.LayoutManager:SetExperienceBarHeight       (self.Options:Get("ExperienceBarHeight"))
    self.LayoutManager:SetReputationBarHeight       (self.Options:Get("ReputationBarHeight"))
    self.LayoutManager:SetXPBarTextureOpacity       (self.Options:Get("XPBarTextureOpacity"))
    self.LayoutManager:SetExperienceBarAtBottom     (self.Options:Get("ExperienceBarAtBottom"))

    -- Multi bar stacking
    self.LayoutManager:SetStackMultiBarLeft         (self.Options:Get("StackMultiBarLeft"))
    self.LayoutManager:SetStackMultiBarRight        (self.Options:Get("StackMultiBarRight"))

    -- End caps
    self.LayoutManager:SetEndCapsTextureScale       (self.Options:Get("EndCapsTextureScale"))
    self.LayoutManager:SetEndCapsTextureOpacity     (self.Options:Get("EndCapsTextureOpacity"))
    self.LayoutManager:SetMainMenuBarTextureStyle   (self.Options:Get("EndCapsTextureStyle"))

    -- Font properties
    self.LayoutManager:SetActionButtonNameFont      (LabelFontProperties["ActionButtonName"])
    self.LayoutManager:SetActionButtonHotKeyFont    (LabelFontProperties["ActionButtonHotKey"])
    self.LayoutManager:SetActionButtonCountFont     (LabelFontProperties["ActionButtonCount"])
    self.LayoutManager:SetExperienceBarTextFont     (LabelFontProperties["ExperienceBarText"])
    self.LayoutManager:SetReputationBarTextFont     (LabelFontProperties["ReputationBarText"])

    self.LayoutManager:Update()
  end

  -- Update button colors
  if (self.ButtonColors) then
    self.ButtonColors:SetIsFastUpdateMode           (self.Options:Get("EnableFastColorUpdates"))
    self.ButtonColors:SetDesaturateOnCooldown       (self.Options:Get("DesaturateOnCooldown"))
    self.ButtonColors:SetOutOfRangeColor            (self.Options:Get("OutOfRangeEnabled"),     self.Options:Get("OutOfRangeColor"))
    self.ButtonColors:SetNotEnoughManaColor         (self.Options:Get("NotEnoughManaEnabled"),  self.Options:Get("NotEnoughManaColor"))
    self.ButtonColors:SetManaAndRangeColor          (self.Options:Get("ManaAndRangeEnabled"),   self.Options:Get("ManaAndRangeColor"))
    self.ButtonColors:SetUnusableColor              (self.Options:Get("UnusableActionEnabled"), self.Options:Get("UnusableActionColor"))
  end
end

--- Toggle between left and right section, called on configurable keybind press.
function CompactActionBarToggleButtons()
  if (CompactActionBar.Options:Get("CompactBarMode") ~= CompactActionBar.COMPACTBARMODE.TOGGLE) then return end

  if (CompactActionBar.ToggleButton ~= nil) then
    CompactActionBar.ToggleButton:InvertToggleState()
  end
end
