local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")
local L = LibStub("AceLocale-3.0"):GetLocale("CompactActionBar")
local Dialog = LibStub("AceConfigDialog-3.0")
local AboutPanel = LibStub("LibAboutPanel-2.0")

--- Options module
-- Handles display, reading and modifying the addon settings.
-- @module Options
-- @alias M
local Options, M = CompactActionBar:CreateModule("Options")

--- Table of names of the customizable text labels.
local FontLabelNames = {
  ActionButtonName      = L["Action Button: Name"],
  ActionButtonHotKey    = L["Action Button: Hotkey"],
  ActionButtonCount     = L["Action Button: Count"],
  ExperienceBarText     = L["Experience Bar Text"],
  ReputationBarText     = L["Reputation Bar Text"],
  ToggleButtonBagCount  = L["Toggle Button: Bag Slots"],
}

--- Table of the default settings of the addon.
local DefaultSettings = {
  -- Layout options
  CompactBarMode          = CompactActionBar.COMPACTBARMODE.TOGGLE,
  IncludeBarSwitcher      = false,
  -- Toggle button
  ToggleButtonPosition    = CompactActionBar.TOGGLEBUTTONPOS.RIGHT,
  AutoSwitchOnCombat      = true,
  ToggleButtonBagSlots    = true,
  -- Action bar properties
  MainMenuBarScale        = 0.9,
  MainMenuBarOpacity      = 1.0,
  MainMenuBarOffsetX      = 0.0,
  MainMenuBarOffsetY      = 0.0,
  MainMenuTextureOpacity  = 1.0,
  MainMenuBarStrata       = "MEDIUM",
  -- Experience bar
  ExperienceBarAtBottom   = false,
  ExperienceBarHeight     = 10.0,
  ReputationBarHeight     = 7.0,
  XPBarTextureOpacity     = 1.0,
  -- Multi bars stacking
  StackMultiBarLeft       = false,
  StackMultiBarRight      = false,
  -- End caps
  EndCapsTextureScale     = 1.0,
  EndCapsTextureOpacity   = 1.0,
  EndCapsTextureStyle     = "Dwarf",
  -- Font properties
  LabelFontProperties     = {
    ActionButtonName      = {
      Face                = "Friz Quadrata TT",
      Height              = 10,
      Outline             = "",
      Monochrome          = false,
    },
    ActionButtonHotKey    = {
      Face                = "Arial Narrow",
      Height              = 12,
      Outline             = "OUTLINE",
      Monochrome          = false,
    },
    ActionButtonCount     = {
      Face                = "Arial Narrow",
      Height              = 14,
      Outline             = "OUTLINE",
      Monochrome          = false,
    },
    ExperienceBarText     = {
      Face                = "Friz Quadrata TT",
      Height              = 10,
      Outline             = "OUTLINE",
      Monochrome          = false,
    },
    ReputationBarText     = {
      Face                = "Friz Quadrata TT",
      Height              = 10,
      Outline             = "OUTLINE",
      Monochrome          = false,
    },
    ToggleButtonBagCount  = {
      Face                = "Arial Narrow",
      Height              = 14,
      Outline             = "OUTLINE",
      Monochrome          = false,
    },
  },
  -- Button colors
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

--- Table of the available presets, inheriting settings from DefaultSettings.
local Presets = {
  --- Default preset, equivalent of resetting the current profile.
  Default = {
    Name = L["Default"],
    Image = CompactActionBar.MediaRoot.."Textures/Presets/Default.jpg",
    Settings = {},
  },
  --- Classic preset, imitating the original appearance of the WoW Classic action bar.
  Classic = {
    Name = L["Classic WoW"],
    Image = CompactActionBar.MediaRoot.."Textures/Presets/ClassicWoW.jpg",
    Settings = {
      MainMenuBarScale        = 1.0,
      CompactBarMode          = CompactActionBar.COMPACTBARMODE.DISABLED,
      LabelFontProperties     = {
        ActionButtonHotKey    = {
          Outline             = "THICKOUTLINE",
          Monochrome          = true,
        },
        ExperienceBarText     = {
          Face                = "Arial Narrow",
          Height              = 14,
        },
        ReputationBarText     = {
          Face                = "Arial Narrow",
          Height              = 14,
        },
      },
      DesaturateOnCooldown    = false,
      OutOfRangeEnabled       = false,
      NotEnoughManaColor      = {0.000, 0.375, 0.750},
    },
  },
  --- Classic preset, imitating the appearance of the retail WoW action bar.
  Retail = {
    Name = L["Retail WoW"],
    Image = CompactActionBar.MediaRoot.."Textures/Presets/RetailWoW.jpg",
    Settings = {
      MainMenuBarScale        = 1.0,
      ToggleButtonPosition    = CompactActionBar.TOGGLEBUTTONPOS.DISABLED,
      IncludeBarSwitcher      = true,
      ExperienceBarAtBottom   = true,
      ReputationBarHeight     = 10,
      LabelFontProperties     = {
        ActionButtonHotKey    = {
          Outline             = "THICKOUTLINE",
          Monochrome          = true,
        },
        ExperienceBarText     = {
          Face                = "Arial Narrow",
          Height              = 14,
        },
        ReputationBarText     = {
          Face                = "Arial Narrow",
          Height              = 14,
        },
      },
      DesaturateOnCooldown    = false,
      OutOfRangeEnabled       = false,
      NotEnoughManaColor      = {0.000, 0.375, 0.750},
    },
  },
  --- Minimalistic preset, reducing the occupied space to bare minimum.
  Minimalistic = {
    Name = L["Minimalistic"],
    Image = CompactActionBar.MediaRoot.."Textures/Presets/Minimalistic.jpg",
    Settings = {
      ToggleButtonPosition    = CompactActionBar.TOGGLEBUTTONPOS.DISABLED,
      MainMenuTextureOpacity  = 0.0,
      ExperienceBarAtBottom   = true,
      ExperienceBarHeight     = 12,
      ReputationBarHeight     = 12,
      XPBarTextureOpacity     = 0.0,
      StackMultiBarRight      = true,
      EndCapsTextureOpacity   = 0.0,
    },
  },
}

--- Merge two tables, copying the keys from Table2 to Table1.
-- Doesn't reference the keys in Table2, creates a copy instead.
-- @tparam table Target1 - Target table to copy the keys to.
-- @tparam table Target2 - Source table to copy the keys from.
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

--- Called whenever the configuration is updated.
-- Calls an update in the addon.
function Options:RefreshConfig()
  CompactActionBar:Update()
end

--- Get the current value of a setting.
-- @tparam string SettingName - Name of the setting.
-- @return - Current value of the setting.
function Options:Get(SettingName)
  assert(type(SettingName) == "string", "SettingName must be a string.")

  -- Return saved setting
  if (self.db.profile.Settings[SettingName] ~= nil) then
    return self.db.profile.Settings[SettingName]
  end

  assert(false, "Setting \""..SettingName.."\" does not exist in current profile, nor in default settings table.")
end

--- Set the new value of a setting.
-- @tparam string SettingName - Name of the setting.
-- @param SettingValue - New value of the setting, can be any type.
function Options:Set(SettingName, SettingValue)
  assert(type(SettingName) == "string", "SettingName must be a string.")

  self.db.profile.Settings[SettingName] = SettingValue
  self:RefreshConfig()
end

--- Get a property of a label's font.
-- @tparam string LabelId - Name of the label to get its property.
-- @tparam string PropertyName - Name of the property to get.
-- @return - Current value of given property.
local function GetFontProperty(LabelId, PropertyName)
  assert(type(LabelId) == "string", "LabelId must be a string.")
  assert(PropertyName ~= nil, "PropertyName is nil.")

  local LabelFontProperties = M:Get("LabelFontProperties")

  assert(LabelFontProperties[LabelId] ~= nil, "Label \""..LabelId.."\" does not exist in the fonts configuration.")
  assert(type(LabelFontProperties[LabelId]) == "table", "Label \""..LabelId.."\" exists in configuration under different type than table.")
  assert(LabelFontProperties[LabelId][PropertyName] ~= nil, "Label \""..LabelId.."\" has no property \""..PropertyName.."\" specified.")

  return LabelFontProperties[LabelId][PropertyName]
end

--- Set a property of a label's font.
-- @tparam string LabelId - Name of the label to set its property.
-- @tparam string PropertyName - Name of the property to set.
-- @param PropertyValue - Value of the property, must match the target type.
local function SetFontProperty(LabelId, PropertyName, PropertyValue)
  assert(type(LabelId) == "string", "LabelId must be a string.")
  assert(type(PropertyName) == "string", "PropertyName must be a string.")

  local LabelFontProperties = M:Get("LabelFontProperties")
  assert(LabelFontProperties[LabelId] ~= nil, "Label \""..LabelId.."\" does not exist in the fonts configuration.")

  local PropertyType = type(LabelFontProperties[LabelId][PropertyName])
  assert(type(PropertyValue) == PropertyType, "Property \""..PropertyName.."\" does not match the target type \""..PropertyType.."\".")
  LabelFontProperties[LabelId][PropertyName] = PropertyValue

  M:RefreshConfig()
end

--- Apply a settings preset.
-- Note: This method overwrites all current profile settings.
-- @tparam table Preset - The preset to apply.
local function ApplyPreset(Preset)
  assert(type(Preset) == "table", "Preset must be a table.")
  assert(type(Preset.Settings) == "table", "Preset.Settings must be a table.")

  M.db.profile.Settings = TableMerge(M.db.profile.Settings, DefaultSettings)
  M.db.profile.Settings = TableMerge(M.db.profile.Settings, Preset.Settings)

  M:RefreshConfig()
end

--- Initialize the module.
function Options:Init()
  --- Create Ace3 database defaults.
  local DatabaseDefaults = {
    Settings = DefaultSettings,
    Variables = {},
  }

  self.db = LibStub("AceDB-3.0"):New("CompactActionBarDB", { profile = DatabaseDefaults }, true)
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
  CompactActionBar:SetEnabledState(self.db.profile.enabled)

  -- Init settings
  self:RefreshConfig()

  -- Initialize presets
  local PresetsListInOptions = {}
  local PresetsSortingInOptions = {}
  local SelectedPresetId = "Default"

  for PresetId, Preset in pairs(Presets) do
    PresetsListInOptions[PresetId] = Preset.Name
    table.insert(PresetsSortingInOptions, PresetId)
  end

  -- Frame strata values
  local StrataValues = {}
  local StrataSorting = {
    "TOOLTIP",
    "FULLSCREEN_DIALOG",
    "FULLSCREEN",
    "DIALOG",
    "HIGH",
    "MEDIUM",
    "LOW",
    "BACKGROUND",
  }

  for i, Value in pairs(StrataSorting) do
    StrataValues[Value] = Value
  end

  -- Font modification
  local AvailableFontLabels = {}
  local EditedFontLabelId = "ActionButtonHotKey"

  for LabelId, FontProperties in pairs(DefaultSettings["LabelFontProperties"]) do
    AvailableFontLabels[LabelId] = FontLabelNames[LabelId]
  end

  --- Create Ace3 options table.
  local Ace3OptionsTable = {
    name = L["Compact Action Bar"],
    handler = CompactActionBar,
    type = "group",
    childGroups = "tab",
    get = function(info) return self:Get(info[#info]) end,
    set = function(info, value) self:Set(info[#info], value) end,
    args = {
      --- Main tab with all addon settings.
      SettingsTab = {
        order = 0,
        name = L["Settings"],
        desc = L["Control how Compact Action Bar behaves and looks."],
        type = "group",
        childGroups = "tree",
        args = {
          --- Active Compact Action Bar mode.
          CompactBarModeTab = {
            order = 0,
            name = L["Compact Bar Mode"],
            desc = L["Set the layout of Compact Action Bar."],
            type = "group",
            args = {
              CompactBarMode = {
                order = 0,
                name = L["Compact Action Bar Mode"],
                desc = L["Type of the Compact Action Bar layout. \"Disabled\" keeps the original look of WoW Classic, \"Toggle\" shows one side at a time, and \"Stacked\" shows both, left on top of the right."],
                type = "select",
                values = {
                  [CompactActionBar.COMPACTBARMODE.DISABLED]  = L["Disabled"],
                  [CompactActionBar.COMPACTBARMODE.TOGGLE]    = L["Toggle"],
                  [CompactActionBar.COMPACTBARMODE.STACKED]   = L["Stacked"],
                },
              },
              IncludeBarSwitcher = {
                order = 2,
                name = L["Show Action Bar Page Switch"],
                desc = L["If enabled, buttons to switch the Action Bar pages will display together with Action Buttons, similarly to where they are in Retail."],
                type = "toggle",
                width = "full",
                disabled = function() return self:Get("CompactBarMode") ~= CompactActionBar.COMPACTBARMODE.TOGGLE end,
              },
            },
          },
          --- Toggle button properties.
          ToggleButtonTab = {
            order = 1,
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
                  [CompactActionBar.TOGGLEBUTTONPOS.DISABLED] = L["Disabled"],
                  [CompactActionBar.TOGGLEBUTTONPOS.LEFT]     = L["Left"],
                  [CompactActionBar.TOGGLEBUTTONPOS.RIGHT]    = L["Right"],
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
          },
          --- Position, scale and opacity of the action bar.
          ActionBarPositionTab = {
            order = 2,
            name = L["Position & Scale"],
            desc = L["Rescale and offset the Action Bar."],
            type = "group",
            args = {
              MainMenuBarScale = {
                order = 0,
                name = L["Action Bar Scale"],
                desc = L["Controls the overall scale of the Action Bar."],
                type = "range",
                width = "full",
                min = 0.25,
                softMax = 1.75,
                max = 5,
              },
              MainMenuBarOffsetX = {
                order = 1,
                name = L["Action Bar Offset X"],
                desc = L["Move the Action Bar horizontally."],
                type = "range",
                width = "full",
                min = -2048,
                softMin = -1024,
                softMax = 1024,
                max = 2048,
                step = 0.01,
              },
              MainMenuBarOffsetY = {
                order = 2,
                name = "Action Bar Offset Y",
                desc = L["Move the Action Bar vertically."],
                type = "range",
                width = "full",
                min = -512,
                softMin = 0,
                max = 256,
              },
              MainMenuBarOpacity = {
                order = 3,
                name = L["Action Bar Opacity"],
                desc = L["Controls the overall opacity of the Action Bar."],
                type = "range",
                width = "full",
                min = 0,
                max = 1,
              },
              MainMenuTextureOpacity = {
                order = 4,
                name = L["Background Opacity"],
                desc = L["Opacity of the Action Bar background textures."],
                type = "range",
                width = "full",
                min = 0,
                max = 1,
              },
              MainMenuBarStrata = {
                order = 5,
                name = L["Action Bar Strata"],
                desc = L["Strata controls at which interface layer the Action Bar is rendered. Adjust this if you want the Action Bar to appear above or below other elements of the interface."],
                type = "select",
                values = StrataValues,
                sorting = StrataSorting,
              },
            },
          },
          --- Height, position and opacity of the experience and reputation bars.
          ExperienceBarTab = {
            order = 3,
            name = L["Experience Bar"],
            desc = L["Customize the Experience and Reputation bars."],
            type = "group",
            args = {
              ExperienceBarHeight = {
                order = 0,
                name = L["Experience Bar Height"],
                desc = L["Adjust the height of the Experience Bar. This also controls the height of Reputation Bar if the character is at the maximum level."],
                type = "range",
                width = "full",
                min = 5,
                max = 30,
              },
              ReputationBarHeight = {
                order = 1,
                name = L["Reputation Bar Height"],
                desc = L["Adjust the height of Reputation Bar."],
                type = "range",
                width = "full",
                min = 5,
                max = 30,
              },
              XPBarTextureOpacity = {
                order = 2,
                name = L["Overlay Textures Opacity"],
                desc = L["Sets the opacity of \"ticks\" overlay texture of the Experience and Reputation Bars."],
                type = "range",
                width = "full",
                min = 0,
                max = 1,
              },
              ExperienceBarAtBottom = {
                order = 3,
                name = L["Experience & Reputation Bars Below Action Buttons"],
                desc = L["Allows the bars to be relocated under the Action Buttons, similarly to where they normally are in Retail."],
                type = "toggle",
                width = "full",
              },
            },
          },
          --- Stacking of the multi action bars from the right side of the screen.
          MultiBarStackingTab = {
            order = 4,
            name = L["Right Bars Stacking"],
            desc = L["Stack the bars from the right side of your screen."],
            desc = "",
            type = "group",
            args = {
              StackingInfo = {
                order = 0,
                name = L["You can choose to move the Right Action Bars 1 & 2 off the right side of your screen and stack them above the Bottom Left and Bottom Right Action Bars instead."],
                type = "description",
              },
              StackMultiBarLeft = {
                order = 1,
                name = L["Stack Right Action Bar 1"],
                desc = L["Toggles stacking of Right Action Bar 1 above the Bottom Right Action Bar."],
                type = "toggle",
                width = "full",
              },
              StackMultiBarRight = {
                order = 2,
                name = L["Stack Right Action Bar 2"],
                desc = L["Toggles stacking of Right Action Bar 2 above the Bottom Left Action Bar."],
                type = "toggle",
                width = "full",
              },
            },
          },
          --- Customization options for the end caps.
          EndCapsTab = {
            order = 5,
            name = L["End Caps"],
            desc = L["Also known as Gryphons."],
            type = "group",
            args = {
              EndCapsTextureScale = {
                order = 0,
                name = L["End Caps Scale"],
                desc = L["Scale of the End Caps textures."],
                type = "range",
                width = "full",
                min = 0.25,
                softMax = 1.75,
                max = 5,
              },
              EndCapsTextureOpacity = {
                order = 1,
                name = L["End Caps Opacity"],
                desc = L["Opacity of the End Caps textures."],
                type = "range",
                width = "full",
                min = 0,
                max = 1,
              },
              EndCapsTextureStyle = {
                order = 2,
                name = L["End Caps Style"],
                desc = L["Did you know there's an unused texture for the End Caps resembling lions? Every playable race was supposed to use its own style of the End Caps, lions in case of humans and gryphons in case of dwarves. Gryphons stuck as the texture for every WoW race."],
                type = "select",
                values = {
                  ["Dwarf"] = L["Dwarf"],
                  ["Human"] = L["Human"],
                },
              },
            },
          },
          --- Customization of labels supported by the addon.
          FontsTab = {
            order = 6,
            name = L["Fonts Properties"],
            desc = L["Edit the fonts of text labels in the Action Bar."],
            type = "group",
            get = function(info) return GetFontProperty(EditedFontLabelId, info[#info]) end,
            set = function(info, value) SetFontProperty(EditedFontLabelId, info[#info], value) end,
            args = {
              SelectedFontElement = {
                order = 0,
                name = L["Edited Label"],
                desc = L["Choose the label to edit its font."],
                type = "select",
                values = AvailableFontLabels,
                get = function(info) return EditedFontLabelId end,
                set = function(info, value) EditedFontLabelId = value end,
              },
              FontPropertiesHeader = {
                order = 1,
                name = function() return L["Properties of "]..FontLabelNames[EditedFontLabelId] end,
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
          },
          --- Settings of the action buttons colors.
          ButtonColorsTab = {
            order = 7,
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
                get = function(info) local color = self:Get(info[#info]); return color[1], color[2], color[3] end,
                set = function(info, r, g, b, a) self:Set(info[#info], {r, g, b}) end,
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
                get = function(info) local color = self:Get(info[#info]); return color[1], color[2], color[3] end,
                set = function(info, r, g, b, a) self:Set(info[#info], {r, g, b}) end,
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
                get = function(info) local color = self:Get(info[#info]); return color[1], color[2], color[3] end,
                set = function(info, r, g, b, a) self:Set(info[#info], {r, g, b}) end,
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
                get = function(info) local color = self:Get(info[#info]); return color[1], color[2], color[3] end,
                set = function(info, r, g, b, a) self:Set(info[#info], {r, g, b}) end,
              },
              UnusableActionEnabled = {
                order = 13,
                name = L["Enabled"],
                desc = L["Colorize the button if the ability cannot be used."],
                type = "toggle",
                width = "half",
              },
            },
          },
        },
      },
      --- Tab with list of available presets to use.
      PresetsTab = {
        order = 1,
        name = L["Presets"],
        desc = L["Use one of the pre-existing configurations."],
        type = "group",
        args = {
          PresetInfo = {
            order = 0,
            name = L["You can choose one of the presets available below that matches your preferences.\nNote: Choosing a preset will overwrite ALL your current settings."],
            type = "description",
          },
          SelectPreset = {
            order = 1,
            name = L["Select a Preset"],
            desc = L["Pick a preset to preview."],
            type = "select",
            values = PresetsListInOptions,
            sorting = PresetsSortingInOptions,
            get = function(info) return SelectedPresetId end,
            set = function(info, value) SelectedPresetId = value end,
          },
          ApplyPreset = {
            order = 2,
            name = L["Apply Preset"],
            desc = L["Apply the selected preset."],
            type = "execute",
            confirm = function() return L["Apply selected preset? It will overwrite ALL your current settings."] end,
            func = function(info) ApplyPreset(Presets[SelectedPresetId]) end,
          },
          PreviewHeader = {
            name = L["Preview"],
            order = 3,
            type = "header",
          },
          PreviewImage = {
            name = "",
            order = 4,
            type = "description",
            width = "full",
            image = function() local Width = 576; return Presets[SelectedPresetId].Image, Width, Width / 4 end,
          },
        },
      },
      --- Profiles tab supplied by the Ace3 library.
      ProfilesTab = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
      --- About tab supplied by the LibAboutPanel library.
      AboutTab = AboutPanel:AboutOptionsTable("CompactActionBar"),
    },
  }

  -- Sort the imported tabs
  Ace3OptionsTable.args.ProfilesTab.order = 2
  Ace3OptionsTable.args.AboutTab.order = 3

  -- Register the options table
  LibStub("AceConfig-3.0"):RegisterOptionsTable("CompactActionBar", Ace3OptionsTable)

  -- Add options to Interface/AddOns
  self.OptionsFrame = Dialog:AddToBlizOptions("CompactActionBar", L["Compact Action Bar"])

  -- Key bindings localisation
  BINDING_HEADER_COMPACTACTIONBAR = L["Compact Action Bar"]
  BINDING_NAME_COMPACTACTIONBAR_TOGGLEBUTTONS = L["Toggle Action Bar / Options"]
end
