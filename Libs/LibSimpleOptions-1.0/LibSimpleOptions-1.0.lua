
local MAJOR, MINOR = "LibSimpleOptions-1.0", 1
local SimpleOptions = LibStub:NewLibrary(MAJOR, MINOR)

if (not SimpleOptions) then return end

--- Localisation.
local Locale, L = GetLocale(), {}

-- English (default)
L["Settings"] = "Settings"
L["Adjust the addon to your needs."] = "Adjust the addon to your needs."
L["Fonts Properties"] = "Fonts Properties"
L["Customize the fonts of the addon."] = "Customize the fonts of the addon."
L["Edited Label"] = "Edited Label"
L["Choose the label to edit its font."] = "Choose the label to edit its font."
L["Properties of"] = "Properties of"
L["Font Face"] = "Font Face"
L["Font Height"] = "Font Height"
L["Outline Type"] = "Outline Type"
L["None"] = "None"
L["Outline"] = "Outline"
L["Thick Outline"] = "Thick Outline"
L["Monochrome"] = "Monochrome"

--- Merge two tables, copying the keys from Table2 to Table1.
-- Doesn't reference the keys in Table2, creates a copy instead.
-- @tparam table Table1 - Target table to copy the keys to.
-- @tparam table Table2 - Source table to copy the keys from.
-- @treturn table - Table with merged keys.
local function TableMerge(Table1, Table2)
  assert(type(Table1) == "table", "Table1 must be a table.")
  assert(type(Table2) == "table", "Table2 must be a table.")

  for Key, Value in pairs(Table2) do
    if (type(Value) == "table") then
      if (type(Table1[Key] or false) == "table") then
        TableMerge(Table1[Key] or {}, Table2[Key] or {})
      else
        Table1[Key] = Value
      end
    else
      Table1[Key] = Value
    end
  end

  return Table1
end

--- Get the length of a table.
-- @tparam table Table - Table to count its length.
-- @treturn number - Length of the table.
local function TableLength(Table)
  assert(type(Table) == "table", "Table must be a table.")

  local i = 0
  for Key, Value in pairs(Table) do i = i + 1 end
  return i
end

--- Table of registered config listeners.
local ConfigListeners = {}

--- Add a listener function called on config updates.
-- @tparam function Callback - Callback function.
function SimpleOptions:AddListener(Callback)
  assert(type(Callback) == "function", "Callback must be a function.")

  table.insert(ConfigListeners, Callback)
end

--- Called whenever the configuration is updated.
-- Calls an update in the subscribed addon modules.
function SimpleOptions:RefreshConfig()
  for i, Callback in pairs(ConfigListeners) do
    Callback()
  end
end

--- Table of the settings tabs to create.
local OptionsTabs = {}
--- Sorting order of the next added settings tab.
local NextOptionsTabIndex = 1

--- Register a new settings tab of a module.
-- @tparam table OptionsTab - Settings tab to register in AceConfig-3.0 format.
function SimpleOptions:AddTab(OptionsTab)
  assert(type(OptionsTab) == "table", "OptionsTab must be a table.")

  if (type(OptionsTab.order) ~= "number") then
    OptionsTab.order = NextOptionsTabIndex
  end

  OptionsTabs["SettingsTab"..NextOptionsTabIndex] = OptionsTab
  NextOptionsTabIndex = NextOptionsTabIndex + 1
end

--- Table of the option tables to create.
local OptionsTables = {}
--- Sorting order of the next added SimpleOptions table.
local NextOptionsTableIndex = 1

--- Register a new SimpleOptions table of a module.
-- @tparam table OptionsTable - SimpleOptions tabel to register in AceConfig-3.0 format.
function SimpleOptions:AddOptionsTable(OptionsTable)
  assert(type(OptionsTable) == "table", "OptionsTable must be a table.")

  OptionsTable.order = NextOptionsTableIndex
  OptionsTables["OptionsTable"..OptionsTable.order] = OptionsTable
  NextOptionsTableIndex = NextOptionsTableIndex + 1
end

--- Table of default settings of all modules.
SimpleOptions.DefaultSettings = {
  LabelFontProperties = {}
}

--- Register module default settings in the SimpleOptions.
-- @tparam table ModuleDefaults - Table of default settings of a module.
function SimpleOptions:AddDefaults(ModuleDefaults)
  assert(type(ModuleDefaults) == "table", "ModuleDefaults must be a table.")

  for SettingName, SettingValue in pairs(ModuleDefaults) do
    assert(self.DefaultSettings[SettingName] == nil, "Setting with name \""..SettingName.."\" has already been registered.")

    self.DefaultSettings[SettingName] = SettingValue
  end
end

--- Get the current value of a setting.
-- @tparam string SettingName - Name of the setting.
-- @return - Current value of the setting.
function SimpleOptions:Get(SettingName)
  assert(type(SettingName) == "string", "SettingName must be a string.")

  -- Return saved setting
  if (self.db.profile.Settings[SettingName] ~= nil) then
    return self.db.profile.Settings[SettingName]
  end

  -- Return defaults
  if (self.DefaultSettings[SettingName] ~= nil) then
    return self.DefaultSettings[SettingName]
  end

  assert(false, "Setting \""..SettingName.."\" does not exist in current profile, nor in default settings table.")
end

--- Set the new value of a setting.
-- @tparam string SettingName - Name of the setting.
-- @param SettingValue - New value of the setting, can be any type.
function SimpleOptions:Set(SettingName, SettingValue)
  assert(type(SettingName) == "string", "SettingName must be a string.")

  self.db.profile.Settings[SettingName] = SettingValue
  self:RefreshConfig()
end

--- Get the current setting value as a color.
-- @tparam string SettingName - Name of the setting.
-- @treturn number - Red channel.
-- @treturn number - Green channel.
-- @treturn number - Blue channel.
-- @treturn number - Alpha channel.
function SimpleOptions:GetColor(SettingName)
  assert(type(SettingName) == "string", "SettingName must be a string.")

  local Color = self:Get(SettingName)
  assert(type(Color) == "table", "Setting \""..SettingName.."\" is not a table.")

  return Color[1], Color[2], Color[3], Color[4]
end

--- Merge settings list into current settings.
-- @tparam table SettingsTable - Table of the settings to merge.
function SimpleOptions:MergeSettings(SettingsTable)
  assert(type(SettingsTable) == "table", "SettingsTable must be a table.")

  self.db.profile.Settings = TableMerge(self.db.profile.Settings, SettingsTable)
  self:RefreshConfig()
end

--- Table of font names, where key is label id and value is the label name.
local FontPropertyLabelNames = {}

--- Register module font properties to the settings.
-- @tparam table FontPropertiesList - Table font properties to register.
function SimpleOptions:AddFontProperties(FontPropertiesList)
  assert(type(FontPropertiesList) == "table", "FontPropertiesList must be a table.")

  for LabelId, LabelInfo in pairs(FontPropertiesList) do
    assert(self.DefaultSettings.LabelFontProperties[LabelId] == nil, "Label with id \""..LabelId.."\" has already been registered.")

    FontPropertyLabelNames[LabelId] = LabelInfo.Name
    self.DefaultSettings.LabelFontProperties[LabelId] = {
      Face        = LabelInfo.Face,
      Height      = LabelInfo.Height,
      Outline     = LabelInfo.Outline,
      Monochrome  = LabelInfo.Monochrome,
    }
  end
end

--- Get properties of a label's font.
function SimpleOptions:GetFontProperties(LabelId)
  assert(type(LabelId) == "string", "LabelId must be a string.")

  local LabelFontProperties = self:Get("LabelFontProperties")

  assert(LabelFontProperties[LabelId] ~= nil, "Label \""..LabelId.."\" does not exist in the fonts configuration.")
  assert(type(LabelFontProperties[LabelId]) == "table", "Label \""..LabelId.."\" exists in configuration under different type than table.")

  return LabelFontProperties[LabelId]
end

--- Get a property of a label's font.
-- @tparam string LabelId - Name of the label to get its property.
-- @tparam string PropertyName - Name of the property to get.
-- @return - Current value of given property.
function SimpleOptions:GetFontProperty(LabelId, PropertyName)
  assert(type(LabelId) == "string", "LabelId must be a string.")
  assert(type(PropertyName) == "string", "PropertyName must be a string.")

  local LabelProperties = self:GetFontProperties(LabelId)

  assert(LabelProperties[PropertyName] ~= nil, "Label \""..LabelId.."\" has no property \""..PropertyName.."\" specified.")

  return LabelProperties[PropertyName]
end

--- Set a property of a label's font.
-- @tparam string LabelId - Name of the label to set its property.
-- @tparam string PropertyName - Name of the property to set.
-- @param PropertyValue - Value of the property, must match the target type.
function SimpleOptions:SetFontProperty(LabelId, PropertyName, PropertyValue)
  assert(type(LabelId) == "string", "LabelId must be a string.")
  assert(type(PropertyName) == "string", "PropertyName must be a string.")

  local LabelProperties = self:GetFontProperties(LabelId)
  local PropertyType = type(LabelProperties[PropertyName])

  assert(type(PropertyValue) == PropertyType, "Property \""..PropertyName.."\" does not match the target type \""..PropertyType.."\".")

  LabelProperties[PropertyName] = PropertyValue
  self:RefreshConfig()
end

--- Id of currently edited label font.
local EditedFontLabelId = nil

--- Table of edited label font properties.
local FontPropertiesOptionsTable = {
  name = L["Fonts Properties"],
  desc = L["Customize the fonts of the addon."],
  type = "group",
  get = function(info) return SimpleOptions:GetFontProperty(EditedFontLabelId, info[#info]) end,
  set = function(info, value) SimpleOptions:SetFontProperty(EditedFontLabelId, info[#info], value) end,
  args = {
    SelectedFontElement = {
      order = 0,
      name = L["Edited Label"],
      desc = L["Choose the label to edit its font."],
      type = "select",
      values = FontPropertyLabelNames,
      get = function(info) return EditedFontLabelId end,
      set = function(info, value) EditedFontLabelId = value end,
    },
    FontPropertiesHeader = {
      order = 1,
      name = function()
        local EditedFontLabelName = "???"
        if (FontPropertyLabelNames[EditedFontLabelId]) then
          EditedFontLabelName = FontPropertyLabelNames[EditedFontLabelId]
        end
        return L["Properties of"].." "..EditedFontLabelName
      end,
      type = "header",
    },
    Face = {
      order = 2,
      name = L["Font Face"],
      type = "select",
      dialogControl = 'LSM30_Font',
      values = AceGUIWidgetLSMlists.font,
    },
    Height = {
      order = 3,
      name = L["Font Height"],
      type = "range",
      min = 4,
      max = 100,
      step = 1,
    },
    Outline = {
      order = 4,
      name = L["Outline Type"],
      type = "select",
      values = {
        [""] = L["None"],
        ["OUTLINE"] = L["Outline"],
        ["THICKOUTLINE"] = L["Thick Outline"],
      },
    },
    Monochrome = {
      order = 5,
      name = L["Monochrome"],
      type = "toggle",
    },
  },
}

--- Apply font properties table to a FontString.
-- @tparam table FontString - Target FontString to apply font properties.
-- @tparam table FontProperties - Properties of the font.
function SimpleOptions:ApplyFontProperties(FontString, FontProperties)
  assert(type(FontString) == "table", "FontString must be a table.")
  assert(type(FontProperties) == "table", "FontProperties must be a table.")
  assert(type(FontProperties.Face) == "string", "FontProperties.Face must be a string.")
  assert(type(FontProperties.Height) == "number", "FontProperties.Height must be a number.")
  assert(type(FontProperties.Outline) == "string", "FontProperties.Outline must be a string.")
  assert(type(FontProperties.Monochrome) == "boolean", "FontProperties.Monochrome must be a boolean.")

  local FontFace = LibStub("LibSharedMedia-3.0"):Fetch("font", FontProperties.Face)

  -- Create font flags string
  local FontFlagsList = {}

  if (FontProperties.Outline ~= "") then
    table.insert(FontFlagsList, FontProperties.Outline)
  end

  if (FontProperties.Monochrome) then
    table.insert(FontFlagsList, "MONOCHROME")
  end

  local FontFlags = table.concat(FontFlagsList, ", ")

  FontString:SetFont(FontFace, FontProperties.Height, FontFlags)
end

--- Whether we have already built the options or not.
local AreOptionsBuilt = false

--- Creates the Ace database and adds SimpleOptions to the Blizzard menu.
function SimpleOptions:Build(AddonName, SavedVariables, TranslatedName)
  assert(type(AddonName) == "string", "AddonName must be a string.")
  assert(type(SavedVariables) == "string", "SavedVariables must be a string.")
  assert(type(TranslatedName) == "string", "TranslatedName must be a string.")

  --- Throw an error if options already have been built.
  assert(not AreOptionsBuilt, "Database and options table have already been built.")
  AreOptionsBuilt = true

  --- Create Ace3 database defaults.
  local DatabaseDefaults = {
    Settings = self.DefaultSettings,
    Variables = {},
  }

  self.db = LibStub("AceDB-3.0"):New(SavedVariables, { profile = DatabaseDefaults }, true)
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

  --- Call for the initial modules update.
  self:RefreshConfig()

  --- Create table for modifying font properties if there are editable fonts.
  if (TableLength(self.DefaultSettings.LabelFontProperties) > 0) then
    for LabelId, FontProperties in pairs(self.DefaultSettings.LabelFontProperties) do
      if (EditedFontLabelId ~= nil) then break end

      EditedFontLabelId = LabelId
    end

    self:AddOptionsTable(FontPropertiesOptionsTable)
  end

  --- Add the settings tab if there are any registered.
  if (TableLength(OptionsTables) > 0) then
    self:AddTab({
      order = 0,
      name = L["Settings"],
      desc = L["Adjust the addon to your needs."],
      type = "group",
      childGroups = "tree",
      args = OptionsTables,
    })

    --- Profiles tab supplied by the Ace3 library.
    self:AddTab(LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))

    --- About tab supplied by the LibAboutPanel library.
    self:AddTab(LibStub("LibAboutPanel-2.0"):AboutOptionsTable(AddonName))

    --- Create Ace3 SimpleOptions table.
    local Ace3OptionsTable = {
      name = TranslatedName,
      type = "group",
      childGroups = "tab",
      get = function(info) return self:Get(info[#info]) end,
      set = function(info, value) self:Set(info[#info], value) end,
      args = OptionsTabs,
    }

    -- Register the SimpleOptions table
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, Ace3OptionsTable)

    -- Add SimpleOptions to Interface/AddOns
    self.OptionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, TranslatedName)
  end
end
