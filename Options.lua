local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")
local L = LibStub("AceLocale-3.0"):GetLocale("CompactActionBar")

-- Localisation
BINDING_HEADER_COMPACTACTIONBAR = L["Compact Action Bar"]
BINDING_NAME_COMPACTACTIONBAR_TOGGLEBUTTONS = L["Toggle Action Bar / Options"]

function CompactActionBar:GetOptions()
    local Options = {
        name = L["Compact Action Bar"],
        handler = CompactActionBar,
        type = "group",
        childGroups = "tab",
        args = {
            CompactActionBarInfo = {
                order = 1,
                name = L["Reduce the amount of space occupied by your action bar while maintaining the original World of Warcraft look."],
                type = "description",
            },
            Layout = {
                order = 2,
                name = L["Layout"],
                type = "group",
                args = {
                    CompactBarMode = {
                        order = 1,
                        name = L["Compact Action Bar Mode"],
                        type = "select",
                        values = {
                            [0] = L["Disabled"],
                            [1] = L["Toggle"],
                            [2] = L["Stacked"],
                        },
                        get = function() return self:GetDB("CompactBarMode") end,
                        set = function(info, value) self:SetDB("CompactBarMode", value) end,
                    },
                    ShowToggleButton = {
                        order = 2,
                        name = L["Show Toggle Button"],
                        type = "toggle",
                        width = "full",
                        disabled = function() return self:GetDB("CompactBarMode") ~= 1 end,
                        get = function() return self:GetDB("ShowToggleButton") end,
                        set = function(info, value) self:SetDB("ShowToggleButton", value) end,
                    },
                    IncludeBarSwitcher = {
                        order = 3,
                        name = L["Show Action Bar Page Switch"],
                        type = "toggle",
                        width = "full",
                        disabled = function() return self:GetDB("CompactBarMode") ~= 1 end,
                        get = function() return self:GetDB("IncludeBarSwitcher") end,
                        set = function(info, value) self:SetDB("IncludeBarSwitcher", value) end,
                    },
                    ExperienceBarAtBottom = {
                        order = 4,
                        name = L["Experience & Reputation Bars Below Action Buttons"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("ExperienceBarAtBottom") end,
                        set = function(info, value) self:SetDB("ExperienceBarAtBottom", value) end,
                    },
                    StackMultiBarLeft = {
                        order = 5,
                        name = L["Stack Right Action Bar 1"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("StackMultiBarRight") end,
                        set = function(info, value) self:SetDB("StackMultiBarRight", value) end,
                    },
                    StackMultiBarRight = {
                        order = 6,
                        name = L["Stack Right Action Bar 2"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("StackMultiBarLeft") end,
                        set = function(info, value) self:SetDB("StackMultiBarLeft", value) end,
                    },
                    MainMenuBarScale = {
                        order = 7,
                        name = L["Action Bars Scale"],
                        type = "range",
                        width = "full",
                        min = 0.50,
                        max = 1.50,
                        step = 0.01,
                        get = function() return self:GetDB("MainMenuBarScale") end,
                        set = function(info, value) self:SetDB("MainMenuBarScale", value) end,
                    },
                    ExperienceBarScale = {
                        order = 8,
                        name = L["Experience Bar Height"],
                        type = "range",
                        width = "full",
                        min = 5,
                        max = 30,
                        step = 1,
                        get = function() return self:GetDB("ExperienceBarHeight") end,
                        set = function(info, value) self:SetDB("ExperienceBarHeight", value) end,
                    },
                    ReputationBarScale = {
                        order = 9,
                        name = L["Reputation Bar Height"],
                        type = "range",
                        width = "full",
                        min = 5,
                        max = 30,
                        step = 1,
                        get = function() return self:GetDB("ReputationBarHeight") end,
                        set = function(info, value) self:SetDB("ReputationBarHeight", value) end,
                    },
                    MainMenuBarStrata = {
                        order = 10,
                        name = L["Action Bar Strata"],
                        type = "select",
                        values = {
                            ["BACKGROUND"] = "BACKGROUND",
                            ["LOW"] = "LOW",
                            ["MEDIUM"] = "MEDIUM",
                            ["HIGH"] = "HIGH",
                            ["DIALOG"] = "DIALOG",
                            ["FULLSCREEN"] = "FULLSCREEN",
                            ["FULLSCREEN_DIALOG"] = "FULLSCREEN_DIALOG",
                            ["TOOLTIP"] = "TOOLTIP",
                        },
                        sorting = {
                            "TOOLTIP",
                            "FULLSCREEN_DIALOG",
                            "FULLSCREEN",
                            "DIALOG",
                            "HIGH",
                            "MEDIUM",
                            "LOW",
                            "BACKGROUND",
                        },
                        get = function() return self:GetDB("MainMenuBarStrata") end,
                        set = function(info, value) self:SetDB("MainMenuBarStrata", value) end,
                    },
                },
            },
            Appearance = {
                order = 3,
                name = L["Appearance"],
                type = "group",
                args = {
                    GryphonsTextureTheme = {
                        order = 1,
                        name = L["End Cap Style"],
                        type = "select",
                        values = {
                            ["Dwarf"] = L["Dwarf"],
                            ["Human"] = L["Human"],
                        },
                        get = function() return self:GetDB("GryphonsTextureTheme") end,
                        set = function(info, value) self:SetDB("GryphonsTextureTheme", value) end,
                    },
                    UseSmoothFonts = {
                        order = 2,
                        name = L["Enable Smooth Fonts"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("UseSmoothFonts") end,
                        set = function(info, value) self:SetDB("UseSmoothFonts", value) end,
                    },
                    HideMainBarEndCaps = {
                        order = 3,
                        name = L["Hide End Caps"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("HideMainBarEndCaps") end,
                        set = function(info, value) self:SetDB("HideMainBarEndCaps", value) end,
                    },
                    HideMainBarBackground = {
                        order = 4,
                        name = L["Hide Action Bar Background"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("HideMainBarBackground") end,
                        set = function(info, value) self:SetDB("HideMainBarBackground", value) end,
                    },
                    HideMainBarXPTexture = {
                        order = 5,
                        name = L["Hide Experience & Reputation Bars Textures"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("HideMainBarXPTexture") end,
                        set = function(info, value) self:SetDB("HideMainBarXPTexture", value) end,
                    },
                    ShowBagSlotsCount = {
                        order = 6,
                        name = L["Show Number of Free Bag Slots"],
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetDB("ShowBagSlotsCount") end,
                        set = function(info, value) self:SetDB("ShowBagSlotsCount", value) end,
                    },
                },
            },
            --[[
            ButtonColors = {
                order = 4,
                name = "Button Colors",
                type = "group",
                args = {
                    DesaturateOnCooldown = {
                        order = 3.1,
                        name = "Desaturate Spells When on Cooldown",
                        type = "toggle",
                        width = "full",
                    },
                    OutOfRangeEnabled = {
                        order = 3.2,
                        name = "Color When Out of Range",
                        type = "toggle",
                        width = 3,
                    },
                    OutOfRangeColor = {
                        order = 3.3,
                        name = "",
                        type = "color",
                        width = 0.1,
                    },
                    NotEnoughManaEnabled = {
                        order = 3.4,
                        name = "Color When Not Enough Mana",
                        type = "toggle",
                        width = 3,
                    },
                    NotEnoughManaColor = {
                        order = 3.5,
                        name = "",
                        type = "color",
                        width = 0.1,
                    },
                },
            },
            ]]
            Presets = {
                order = 5,
                name = L["Presets"],
                type = "group",
                args = {
                    PresetInfo = {
                        order = 4.1,
                        name = L["You can choose one of the presets available below that matches your preferences.\nNote: Choosing a preset will overwrite your current settings."],
                        type = "description",
                    },
                    SelectPreset = {
                        order = 4.2,
                        name = L["Select a Preset"],
                        type = "select",
                        values = {
                            ["Default"] = L["Default"],
                            ["Blizzard"] = L["Classic WoW"],
                            ["Retail"] = L["Retail WoW"],
                            ["Minimal"] = L["Minimalistic"],
                        },
                        sorting = {
                            "Default",
                            "Blizzard",
                            "Retail",
                            "Minimal",
                        },
                        set = function(info, value) self:UsePreset(value) end,
                    },
                },
            },
        },
    }

    return Options
end
