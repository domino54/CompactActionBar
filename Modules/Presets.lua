local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")
local Options = LibStub("LibSimpleOptions-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CompactActionBar")

--- Presets module
-- Handles preview and application of presets.
-- Loaded after Options, but doesn't have to be after other modules.
-- DefaultSettings are read from Options at the moment of applying a preset.
-- @module Options
-- @alias M
local Presets, M = CompactActionBar:CreateModule("Presets")

--- Table of the available presets, inheriting settings from DefaultSettings in Options module.
local AvailablePresetsList = {
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
      ToggleButtonPosition    = 0,
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
      ToggleButtonPosition    = 0,
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

--- Apply a settings preset.
-- Note: This method overwrites all current profile settings.
-- @tparam table Preset - The preset to apply.
local function ApplyPreset(Preset)
  assert(type(Preset) == "table", "Preset must be a table.")
  assert(type(Preset.Settings) == "table", "Preset.Settings must be a table.")

  Options:MergeSettings(Options.DefaultSettings)
  Options:MergeSettings(Preset.Settings)
end

--- Presets list in options tab.
local PresetsListInOptions = {}
--- Sorting of the presets in options tab.
local PresetsSortingInOptions = {}
--- Currently previewed preset.
local SelectedPresetId = "Default"

for PresetId, Preset in pairs(AvailablePresetsList) do
  PresetsListInOptions[PresetId] = Preset.Name
  table.insert(PresetsSortingInOptions, PresetId)
end

--- The presets options tab.
local PresetsOptionsTab = {
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
      func = function(info) ApplyPreset(AvailablePresetsList[SelectedPresetId]) end,
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
      image = function() local Width = 576; return AvailablePresetsList[SelectedPresetId].Image, Width, Width / 4 end,
    },
  },
}

--- Initialize the module.
function Presets:Init()
  Options:AddTab(PresetsOptionsTab)
end
