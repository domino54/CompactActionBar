local CompactActionBar = LibStub("AceAddon-3.0"):NewAddon("CompactActionBar")
local L = LibStub("AceLocale-3.0"):GetLocale("CompactActionBar")
local Options = LibStub("LibSimpleOptions-1.0")

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

--- Initialize the Compact Action Bar addon.
function CompactActionBar:OnInitialize()
  self.GameVersion      = GetGameVersion()

  --- Initialize the created modules.
  for ModuleName, Module in pairs(self.Modules) do
    Module:Init()
  end

  --self.Options:BuildDatabaseAndOptions()
  Options:Build("CompactActionBar", "CompactActionBarDB", L["Compact Action Bar"])

  -- Key bindings localisation
  BINDING_HEADER_COMPACTACTIONBAR = L["Compact Action Bar"]
end

--- Global update, called when a module requests a global update.
function CompactActionBar:Update()
  if (self.Options == nil) then return end

  local LabelFontProperties = self.Options:Get("LabelFontProperties")
  local IsToggled = false

  -- Get the current toggle state
  if (self.ToggleButton ~= nil) then
    IsToggled = self.ToggleButton.IsToggled
  end

  -- Set the toggle state in layout
  --

  -- Set toggle button visibility
  if (self.ToggleButton ~= nil) then
    self.ToggleButton:SetShown(true)
  end

  -- Update layout manager
  --[[
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
  ]]
end
