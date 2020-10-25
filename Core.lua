local CompactActionBar = LibStub("AceAddon-3.0"):NewAddon("CompactActionBar")
local Dialog = LibStub("AceConfigDialog-3.0")

-- Settings
local COMPACTBARMODE_DISABLED = 0
local COMPACTBARMODE_TOGGLE = 1
local COMPACTBARMODE_STACKED = 2

local ExperienceBarTextureFile = "Interface\\Addons\\CompactActionBar\\Textures\\ExperienceBar"

local db
local DefaultOptions = {
  MainMenuBarScale = 0.9,
  MainMenuBarStrata = "MEDIUM",
  CompactBarMode = COMPACTBARMODE_TOGGLE,
  ShowToggleButton = true,
  ExperienceBarAtBottom = false,
  ExperienceBarHeight = 10,
  ReputationBarHeight = 7,
  StackMultiBarLeft = false,
  StackMultiBarRight = false,
  GryphonsTextureTheme = "Dwarf",
  HideMainBarEndCaps = false,
  HideMainBarBackground = false,
  HideMainBarXPTexture = false,
  UseSmoothFonts = true,
}

local Presets = {
  ["Default"] = DefaultOptions,
  ["Blizzard"] = {
    MainMenuBarScale = 1.0,
    MainMenuBarStrata = "MEDIUM",
    CompactBarMode = COMPACTBARMODE_DISABLED,
    ShowToggleButton = true,
    ExperienceBarAtBottom = false,
    ExperienceBarHeight = 10,
    ReputationBarHeight = 7,
    StackMultiBarLeft = false,
    StackMultiBarRight = false,
    GryphonsTextureTheme = "Dwarf",
    HideMainBarEndCaps = false,
    HideMainBarBackground = false,
    HideMainBarXPTexture = false,
    UseSmoothFonts = false,
  },
  ["Retail"] = {
    MainMenuBarScale = 1.0,
    MainMenuBarStrata = "MEDIUM",
    CompactBarMode = COMPACTBARMODE_TOGGLE,
    ShowToggleButton = false,
    ExperienceBarAtBottom = true,
    ExperienceBarHeight = 10,
    ReputationBarHeight = 10,
    StackMultiBarLeft = false,
    StackMultiBarRight = false,
    GryphonsTextureTheme = "Dwarf",
    HideMainBarEndCaps = false,
    HideMainBarBackground = false,
    HideMainBarXPTexture = false,
    UseSmoothFonts = false,
  },
  ["Minimal"] = {
    MainMenuBarScale = 0.9,
    MainMenuBarStrata = "MEDIUM",
    CompactBarMode = COMPACTBARMODE_TOGGLE,
    ShowToggleButton = false,
    ExperienceBarAtBottom = true,
    ExperienceBarHeight = 12,
    ReputationBarHeight = 12,
    StackMultiBarLeft = false,
    StackMultiBarRight = true,
    GryphonsTextureTheme = "Dwarf",
    HideMainBarEndCaps = true,
    HideMainBarBackground = true,
    HideMainBarXPTexture = true,
    UseSmoothFonts = true,
  },
}

-- Global
local ShortMainMenuBarWidth = 512
local DisplayRightSideButtons = false

-- Containers
local CompactActionBarContainer = CreateFrame("Frame", "CompactActionBarContainer", MainMenuBar)
local CompactActionBarLeftBarFrame = CreateFrame("Frame", "CompactActionBarLeftBarFrame", CompactActionBarContainer)
local CompactActionBarRightBarFrame = CreateFrame("Frame", "CompactActionBarRightBarFrame", CompactActionBarContainer)

-- Container
CompactActionBarContainer:SetHeight(42)
CompactActionBarContainer:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, 0)
CompactActionBarContainer:SetPoint("TOPRIGHT", MainMenuBar, "TOPRIGHT", 0, 0)

-- Left frame
CompactActionBarLeftBarFrame:SetWidth(ShortMainMenuBarWidth)
CompactActionBarLeftBarFrame:SetHeight(43)
CompactActionBarLeftBarFrame:SetClipsChildren(true)
CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", CompactActionBarContainer, "BOTTOMLEFT", 0, 0)

-- Right frame
CompactActionBarRightBarFrame:SetWidth(ShortMainMenuBarWidth)
CompactActionBarRightBarFrame:SetHeight(43)
CompactActionBarRightBarFrame:SetClipsChildren(true)
CompactActionBarRightBarFrame:SetPoint("BOTTOMRIGHT", CompactActionBarContainer, "BOTTOMRIGHT", 0, 0)

-- Toggle button
local CompactActionBarToggleContainer = CreateFrame("Frame", "CompactActionBarToggleContainer", MainMenuBar)
CompactActionBarToggleContainer:SetPoint("CENTER", CompactActionBarContainer, "BOTTOMRIGHT", 21, 21)
CompactActionBarToggleContainer:SetWidth(42)
CompactActionBarToggleContainer:SetHeight(42)

local CompactActionBarToggle = CreateFrame("Button", "CompactActionBarToggle", CompactActionBarToggleContainer, "ItemButtonTemplate")
CompactActionBarToggle:SetScale(0.75)
CompactActionBarToggle:SetPoint("CENTER", CompactActionBarToggleContainer, "CENTER", 0, 0)
CompactActionBarToggle:SetFrameLevel(5)
CompactActionBarToggle:SetScript("OnClick", function() CompactActionBarToggleButtons() end)

local function InitContainerLayout()
  -- Left texture
  MainMenuBarTexture0:ClearAllPoints()
  MainMenuBarTexture0:SetPoint("BOTTOMLEFT", CompactActionBarLeftBarFrame, "BOTTOMLEFT", 0, 0)
  MainMenuBarTexture1:ClearAllPoints()
  MainMenuBarTexture1:SetPoint("BOTTOMLEFT", MainMenuBarTexture0, "BOTTOMRIGHT", 0, 0)

  -- Right texture
  MainMenuBarTexture3:ClearAllPoints()
  MainMenuBarTexture3:SetPoint("BOTTOMRIGHT", CompactActionBarRightBarFrame, "BOTTOMRIGHT", 0, 0)
  MainMenuBarTexture2:ClearAllPoints()
  MainMenuBarTexture2:SetPoint("BOTTOMRIGHT", MainMenuBarTexture3, "BOTTOMLEFT", 0, 0)

  -- Move the action buttons
  ActionButton1:ClearAllPoints()
  ActionButton1:SetPoint("BOTTOMLEFT", CompactActionBarLeftBarFrame, "BOTTOMLEFT", 8, 4)

  -- Move the backpack button
  MainMenuBarBackpackButton:ClearAllPoints()
  MainMenuBarBackpackButton:SetPoint("CENTER", CompactActionBarRightBarFrame, "BOTTOMRIGHT", -25, 21)

  -- Move the character buttons
  CharacterMicroButton:ClearAllPoints()
  CharacterMicroButton:SetPoint("BOTTOMLEFT", CompactActionBarRightBarFrame, "BOTTOMRIGHT", -472, 2)

  -- Move the bar switcher
  MainMenuBarPageNumber:ClearAllPoints()
  MainMenuBarPageNumber:SetPoint("CENTER", CompactActionBarRightBarFrame, "BOTTOMRIGHT", -482, 21)
  ActionBarUpButton:ClearAllPoints()
  ActionBarUpButton:SetPoint("CENTER", MainMenuBarPageNumber, "CENTER", -20, 10)
  ActionBarDownButton:ClearAllPoints()
  ActionBarDownButton:SetPoint("CENTER", MainMenuBarPageNumber, "CENTER", -20, -10)
end

local function InitExperienceBarsLayout()
  -- Experience bar
  MainMenuBarExpText:ClearAllPoints()
  MainMenuBarExpText:SetPoint("CENTER", MainMenuExpBar, "CENTER", 0, 0)

  local MainMenuXPBarTextureContainer = CreateFrame("Frame", "MainMenuXPBarTextureContainer", MainMenuExpBar)
  MainMenuXPBarTextureContainer:SetPoint("BOTTOMLEFT", MainMenuExpBar, "BOTTOMLEFT", 0, 0)
  MainMenuXPBarTextureContainer:SetPoint("TOPRIGHT", MainMenuExpBar, "TOPRIGHT", 0, 0)
  MainMenuXPBarTextureContainer:SetClipsChildren(true)
  MainMenuXPBarTextureContainer:SetFrameLevel(3)

  MainMenuXPBarTexture0:ClearAllPoints()
  MainMenuXPBarTexture0:SetParent(MainMenuXPBarTextureContainer)
  MainMenuXPBarTexture0:SetPoint("BOTTOMLEFT", MainMenuExpBar, "BOTTOMLEFT", 0, 0)
  MainMenuXPBarTexture0:SetPoint("TOPLEFT", MainMenuExpBar, "TOPLEFT", 0, 0)

  for i = 1, 3 do
    local Cur = _G["MainMenuXPBarTexture"..i]
    local Prev = _G["MainMenuXPBarTexture"..i-1]

    Cur:ClearAllPoints()
    Cur:SetParent(MainMenuXPBarTextureContainer)
    Cur:SetPoint("TOPLEFT", Prev, "TOPRIGHT", 0, 0)
    Cur:SetPoint("BOTTOMLEFT", Prev, "BOTTOMRIGHT", 0, 0)
  end

  ExhaustionLevelFillBar:ClearAllPoints()
  ExhaustionLevelFillBar:SetPoint("BOTTOMLEFT", MainMenuExpBar, "BOTTOMLEFT", 0, 0)
  ExhaustionLevelFillBar:SetPoint("TOPRIGHT", MainMenuExpBar, "TOPRIGHT", 0, 0)

  -- Reputation bar
  ReputationWatchBar.StatusBar:SetClipsChildren(true)

  ReputationWatchBar.StatusBar:ClearAllPoints()
  ReputationWatchBar.StatusBar:SetPoint("TOPLEFT", ReputationWatchBar, "TOPLEFT", 0, 0)
  ReputationWatchBar.StatusBar:SetPoint("BOTTOMLEFT", ReputationWatchBar, "BOTTOMLEFT", 0, 0)

  ReputationWatchBar.StatusBar.BarTexture:SetTexture(ExperienceBarTextureFile)

  ReputationWatchBar.StatusBar.XPBarTexture0:ClearAllPoints()
  ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar, "TOPLEFT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("BOTTOMLEFT", ReputationWatchBar.StatusBar, "BOTTOMLEFT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture1:ClearAllPoints()
  ReputationWatchBar.StatusBar.XPBarTexture1:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar.XPBarTexture0, "TOPRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture1:SetPoint("BOTTOMLEFT", ReputationWatchBar.StatusBar.XPBarTexture0, "BOTTOMRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture2:ClearAllPoints()
  ReputationWatchBar.StatusBar.XPBarTexture2:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar.XPBarTexture1, "TOPRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture2:SetPoint("BOTTOMLEFT", ReputationWatchBar.StatusBar.XPBarTexture1, "BOTTOMRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture3:ClearAllPoints()
  ReputationWatchBar.StatusBar.XPBarTexture3:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar.XPBarTexture2, "TOPRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture3:SetPoint("BOTTOMLEFT", ReputationWatchBar.StatusBar.XPBarTexture2, "BOTTOMRIGHT", 0, 0)

  --[[
  ReputationWatchBar.StatusBar.WatchBarTexture0:ClearAllPoints()
  ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar, "TOPLEFT", 0, 2)
  ReputationWatchBar.StatusBar.WatchBarTexture1:ClearAllPoints()
  ReputationWatchBar.StatusBar.WatchBarTexture1:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar.WatchBarTexture0, "TOPRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.WatchBarTexture2:ClearAllPoints()
  ReputationWatchBar.StatusBar.WatchBarTexture2:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar.WatchBarTexture1, "TOPRIGHT", 0, 0)
  ReputationWatchBar.StatusBar.WatchBarTexture3:ClearAllPoints()
  ReputationWatchBar.StatusBar.WatchBarTexture3:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar.WatchBarTexture2, "TOPRIGHT", 0, 0)
  ]]

  -- Max level bar
  MainMenuBarMaxLevelBar:SetClipsChildren(true)

  MainMenuMaxLevelBar0:ClearAllPoints()
  MainMenuMaxLevelBar0:SetPoint("BOTTOMLEFT", MainMenuBarMaxLevelBar, "BOTTOMLEFT", 0, 0)
  MainMenuMaxLevelBar0:SetPoint("TOPLEFT", MainMenuBarMaxLevelBar, "TOPLEFT", 0, 0)

  for i = 1, 3 do
    local Cur = _G["MainMenuMaxLevelBar"..i]
    local Prev = _G["MainMenuMaxLevelBar"..i-1]

    Cur:ClearAllPoints()
    Cur:SetPoint("TOPLEFT", Prev, "TOPRIGHT", 0, 0)
    Cur:SetPoint("BOTTOMLEFT", Prev, "BOTTOMRIGHT", 0, 0)
  end
end

-- Update bar fonts
local function SetUseSmoothFonts(SmoothFonts)
  -- Action bar buttons
  local HotkeyFontOptions = "OUTLINE, THICKOUTLINE, MONOCHROME"
  local ActionBarNames = {
    "ActionButton",
    "PetActionButton",
    "MultiBarLeftButton",
    "MultiBarRightButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton"
  }

  if SmoothFonts then HotkeyFontOptions = "OUTLINE" end

  for j, Type in pairs(ActionBarNames) do
    local Length = 12
    if Type == "PetActionButton" then Length = 10 end

    for i = 1, Length do
      _G[Type..i.."HotKey"]:SetFont("Fonts\\ARIALN.TTF", 12, HotkeyFontOptions)
    end
  end

  -- XP/reputation bar font
  local BarsFontFace = "ARIALN"
  local BarsFontSize = 14
  local ExperienceBarTexts = {
    MainMenuBarExpText,
    ReputationWatchBar.OverlayFrame.Text
  }

  if SmoothFonts then
    BarsFontFace = "FRIZQT__"
    BarsFontSize = 10
  end

  for i, Element in pairs(ExperienceBarTexts) do
    Element:SetFont("Fonts\\"..BarsFontFace..".TTF", BarsFontSize, "OUTLINE")
  end
end

local function UpdateMultiBarButtons(Side, IsStacked)
  local MultiBar = _G["MultiBar"..Side]
  local ButtonName = "MultiBar"..Side.."Button"

  local BarHeight = math.max(math.abs(MultiBar:GetHeight()), math.abs(MultiBar:GetWidth()))
  local BarWidth = math.min(math.abs(MultiBar:GetHeight()), math.abs(MultiBar:GetWidth()))

  -- WoW defaults
  MultiBar:SetParent(VerticalMultiBarsContainer)
  MultiBar:SetHeight(BarHeight)
  MultiBar:SetWidth(BarWidth)

  -- Align first button
  _G[ButtonName..1]:ClearAllPoints()
  _G[ButtonName..1]:SetPoint("TOPRIGHT", MultiBar, "TOPRIGHT", -2, -3)

  local AnchorPrevButton = "TOP"
  local AnchorNextButton = "BOTTOM"
  local DiffHorizontal = 0
  local DiffVertical = -6

  -- Bottom action bar alignment
  if IsStacked then
    MultiBar:SetParent(MainMenuBar)
    MultiBar:SetHeight(BarWidth)
    MultiBar:SetWidth(BarHeight)

    -- Align first button
    _G[ButtonName..1]:ClearAllPoints()
    _G[ButtonName..1]:SetPoint("BOTTOMLEFT", MultiBar, "BOTTOMLEFT", 0, 0)

    AnchorPrevButton = "LEFT"
    AnchorNextButton = "RIGHT"
    DiffHorizontal = 6
    DiffVertical = 0
  end

  -- Stack buttons
  for i = 2, 12 do
    _G[ButtonName..i]:ClearAllPoints()
    _G[ButtonName..i]:SetPoint(AnchorPrevButton, _G[ButtonName..i-1], AnchorNextButton, DiffHorizontal, DiffVertical)
  end
end

-- Update alignment and buttons of right action bars
local function UpdateMultiBars()
  -- Default right bar 1 alignment
  if not db.StackMultiBarRight then
    MultiBarRight:ClearAllPoints()
    MultiBarRight:SetPoint("TOPRIGHT", VerticalMultiBarsContainer, "TOPRIGHT", 0, 0)
  end

  -- Default right bar 1 alignment
  if not db.StackMultiBarLeft then
    if db.StackMultiBarRight then
      MultiBarLeft:ClearAllPoints()
      MultiBarLeft:SetPoint("TOPRIGHT", VerticalMultiBarsContainer, "TOPRIGHT", 0, 0)
    else
      MultiBarLeft:ClearAllPoints()
      MultiBarLeft:SetPoint("TOPRIGHT", MultiBarRight, "TOPLEFT", -2, 0)
    end
  end

  UpdateMultiBarButtons("Left", db.StackMultiBarLeft)
  UpdateMultiBarButtons("Right", db.StackMultiBarRight)
end

local function SetMainMenuBarWidth(FrameWidth)
  -- Set the new bar width
  CompactActionBarContainer:SetWidth(FrameWidth)
  MainMenuBar:SetWidth(FrameWidth)
  MainMenuExpBar:SetWidth(FrameWidth)
  ReputationWatchBar:SetWidth(FrameWidth)
  MainMenuBarMaxLevelBar:SetWidth(FrameWidth)
  ReputationWatchBar.StatusBar:SetWidth(FrameWidth)

  -- Move the end caps
  MainMenuBarArtFrame:SetFrameLevel(4)
  MainMenuBarLeftEndCap:SetPoint("RIGHT", MainMenuBar, "LEFT", 32, 0)
  MainMenuBarRightEndCap:SetPoint("LEFT", MainMenuBar, "RIGHT", -32, 0)
end

local function SetMainMenuBarScale(Scale)
  MainMenuBar:SetScale(Scale)
  UpdateMultiBars()
end

local function SetTexturesVisibility(Elements, Visible)
  local Alpha = 0
  if Visible then Alpha = 1 end

  for i, Element in pairs(Elements) do
    Element:SetAlpha(Alpha)
  end
end

local function SetXPBarTexturesVisibility(Visible)
  local e = {
    ReputationWatchBar.StatusBar.WatchBarTexture0,
    ReputationWatchBar.StatusBar.WatchBarTexture1,
    ReputationWatchBar.StatusBar.WatchBarTexture2,
    ReputationWatchBar.StatusBar.WatchBarTexture3,
    ReputationWatchBar.StatusBar.XPBarTexture0,
    ReputationWatchBar.StatusBar.XPBarTexture1,
    ReputationWatchBar.StatusBar.XPBarTexture2,
    ReputationWatchBar.StatusBar.XPBarTexture3,
    MainMenuXPBarTexture0,
    MainMenuXPBarTexture1,
    MainMenuXPBarTexture2,
    MainMenuXPBarTexture3,
  }

  SetTexturesVisibility(e, Visible)
end

local function SetMainMenuBarArtVisbility(Visible)
  local e = {
    MainMenuBarLeftEndCap,
    MainMenuBarRightEndCap,
  }

  SetTexturesVisibility(e, Visible)
end

local function SetMainMenuBarBackgroundVisbility(Visible)
  local e = {
    MainMenuBarTexture0,
    MainMenuBarTexture1,
    MainMenuBarTexture2,
    MainMenuBarTexture3,
  }

  SetTexturesVisibility(e, Visible)
end

local function SetMaxLevelTexturesVisibility(Visible)
  local e = {
    MainMenuMaxLevelBar0,
    MainMenuMaxLevelBar1,
    MainMenuMaxLevelBar2,
    MainMenuMaxLevelBar3,
  }

  SetTexturesVisibility(e, Visible)
end

-- Update stack offsets
local function UpdateMainMenuBarPositions()
  local GlobalAnchorOffsetY = 0
  local RightAnchorOffsetX = ShortMainMenuBarWidth - 2

  if db.CompactBarMode ~= COMPACTBARMODE_DISABLED then
    RightAnchorOffsetX = 0
  end

  -- Action buttons at the bottom
  if not db.ExperienceBarAtBottom then
    CompactActionBarContainer:ClearAllPoints()
    CompactActionBarContainer:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

    if CompactActionBarContainer:IsShown() then
      GlobalAnchorOffsetY = GlobalAnchorOffsetY + CompactActionBarContainer:GetHeight()
    end
  end

  -- Experience bar
  local Regions = { MainMenuExpBar:GetRegions() }
  Regions[3]:SetTexture(ExperienceBarTextureFile)

  MainMenuExpBar:SetHeight(db.ExperienceBarHeight)
  MainMenuExpBar:ClearAllPoints()
  MainMenuExpBar:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

  if MainMenuExpBar:IsShown() then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY + MainMenuExpBar:GetHeight()
  end

  -- Reputation bar
  local RepBarHeight = MainMenuExpBar:GetHeight()
  if MainMenuExpBar:IsShown() then RepBarHeight = db.ReputationBarHeight end

  ReputationWatchBar.OverlayFrame.Text:ClearAllPoints()
  ReputationWatchBar.OverlayFrame.Text:SetPoint("CENTER", ReputationWatchBar.OverlayFrame, "CENTER", 0, 0)

  ReputationWatchBar:SetHeight(RepBarHeight)
  ReputationWatchBar:ClearAllPoints()
  ReputationWatchBar:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

  if ReputationWatchBar:IsShown() then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY + ReputationWatchBar:GetHeight()
  end

  -- Action buttons above XP & reputation
  if db.ExperienceBarAtBottom then
    CompactActionBarContainer:ClearAllPoints()
    CompactActionBarContainer:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

    if CompactActionBarContainer:IsShown() then
      GlobalAnchorOffsetY = GlobalAnchorOffsetY + CompactActionBarContainer:GetHeight()
    end
  end

  -- Max level bar
  MainMenuBarMaxLevelBar:SetShown(not db.HideMainBarBackground and (db.ExperienceBarAtBottom or not(MainMenuExpBar:IsShown() or ReputationWatchBar:IsShown())))
  MainMenuBarMaxLevelBar:ClearAllPoints()
  MainMenuBarMaxLevelBar:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

  if MainMenuBarMaxLevelBar:IsShown() then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY + MainMenuBarMaxLevelBar:GetHeight()
  end

  if db.ExperienceBarAtBottom and db.HideMainBarBackground then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY - 1
  end

  -- Split anchors to left and right side
  local LeftAnchorOffsetY = GlobalAnchorOffsetY
  local RightAnchorOffsetY = GlobalAnchorOffsetY

  -- Bottom left action bar offset
  MultiBarBottomLeft:ClearAllPoints()
  MultiBarBottomLeft:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 8, LeftAnchorOffsetY + 4)

  if MultiBarBottomLeft:IsShown() then
    LeftAnchorOffsetY = LeftAnchorOffsetY + MultiBarBottomLeft:GetHeight() + 4
  end

  if db.CompactBarMode ~= COMPACTBARMODE_DISABLED then
    RightAnchorOffsetY = LeftAnchorOffsetY
  end

  -- Bottom right action bar offset
  MultiBarBottomRight:ClearAllPoints()
  MultiBarBottomRight:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", RightAnchorOffsetX + 8, RightAnchorOffsetY + 4)

  if MultiBarBottomRight:IsShown() then
    RightAnchorOffsetY = RightAnchorOffsetY + MultiBarBottomRight:GetHeight() + 4
  end

  UpdateMultiBars()

  -- Stack right action bar 1
  if db.StackMultiBarRight then
    MultiBarRight:ClearAllPoints()
    MultiBarRight:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", RightAnchorOffsetX + 8, RightAnchorOffsetY + 4)

    if MultiBarRight:IsShown() then
      RightAnchorOffsetY = RightAnchorOffsetY + MultiBarRight:GetHeight() + 1
    end
  end

  if db.CompactBarMode ~= COMPACTBARMODE_DISABLED then
    LeftAnchorOffsetY = RightAnchorOffsetY
  end

  -- Stack right action bar 2
  if db.StackMultiBarLeft then
    MultiBarLeft:ClearAllPoints()
    MultiBarLeft:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 8, LeftAnchorOffsetY + 4)

    if MultiBarLeft:IsShown() then
      LeftAnchorOffsetY = LeftAnchorOffsetY + MultiBarLeft:GetHeight() + 1
    end
  end

  if MultiBarBottomLeft:IsShown() then
    LeftAnchorOffsetY = LeftAnchorOffsetY + 1
  end

  -- Pet bar offset
  PetActionBarFrame:ClearAllPoints()
  PetActionBarFrame:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 36, LeftAnchorOffsetY)

  if PetActionBarFrame:IsShown() then
    LeftAnchorOffsetY = LeftAnchorOffsetY + 36
  end

  -- Stance / shapeshift
  StanceBarFrame:ClearAllPoints()
  StanceBarFrame:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 32, LeftAnchorOffsetY)

  if StanceBarFrame:IsShown() then
    LeftAnchorOffsetY = LeftAnchorOffsetY + 36
  end

  -- Latency button (for some reason moves back so updating regularly)
  MainMenuBarPerformanceBarFrame:ClearAllPoints()
  MainMenuBarPerformanceBarFrame:SetPoint("BOTTOMRIGHT", CompactActionBarRightBarFrame, "BOTTOMRIGHT", -235, -10)
end

local function SetContainersLayout(LayoutMode, IsToggled)
  local HideOffset = -10000

  CompactActionBarLeftBarFrame:ClearAllPoints()
  CompactActionBarRightBarFrame:ClearAllPoints()

  -- Full bar, stack horizontally
  if LayoutMode == COMPACTBARMODE_DISABLED then
    CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
    CompactActionBarRightBarFrame:SetPoint("BOTTOMRIGHT", CompactActionBarContainer, "BOTTOMRIGHT", 0, 0)
    CompactActionBarContainer:SetHeight(CompactActionBarLeftBarFrame:GetHeight())

  -- Compact bar in toggle mode
  elseif LayoutMode == COMPACTBARMODE_TOGGLE then
    if IsToggled then
      -- "Hide" the action buttons
      CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", CompactActionBarContainer, "BOTTOMLEFT", 0, HideOffset)
      CompactActionBarRightBarFrame:SetPoint("BOTTOMRIGHT", CompactActionBarContainer, "BOTTOMRIGHT", 0, 0)
    else
      -- "Hide" the option buttons
      CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
      CompactActionBarRightBarFrame:SetPoint("BOTTOMRIGHT", CompactActionBarContainer, "BOTTOMRIGHT", 0, HideOffset)
    end

    CompactActionBarContainer:SetHeight(CompactActionBarLeftBarFrame:GetHeight())

  -- Bars stacked vertically
  elseif LayoutMode == COMPACTBARMODE_STACKED then
    CompactActionBarRightBarFrame:SetPoint("BOTTOMLEFT", CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
    CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", CompactActionBarRightBarFrame, "TOPLEFT", 0, 0)
    CompactActionBarContainer:SetHeight(CompactActionBarLeftBarFrame:GetHeight() + CompactActionBarRightBarFrame:GetHeight())
  end
end

local function SetMainMenuBarTexture(Theme)
  local EndCapTexture = "Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-"..Theme
  MainMenuBarLeftEndCap:SetTexture(EndCapTexture)
  MainMenuBarRightEndCap:SetTexture(EndCapTexture)

  local MainMenuBarTexture = "Interface\\MainMenuBar\\UI-MainMenuBar-"..Theme
  MainMenuBarTexture0:SetTexture(MainMenuBarTexture)
  MainMenuBarTexture1:SetTexture(MainMenuBarTexture)
end

local function SetIsMainMenuBarShort(Enabled)
  local MainMenuBarWidth = ShortMainMenuBarWidth

  if not Enabled then
    MainMenuBarWidth = MainMenuBarWidth * 2
  end

  SetMainMenuBarWidth(MainMenuBarWidth)
end

function CompactActionBar:UpdateMainMenuBarLayout()
  SetContainersLayout(db.CompactBarMode, DisplayRightSideButtons)
  SetIsMainMenuBarShort(db.CompactBarMode ~= COMPACTBARMODE_DISABLED)
  CompactActionBarToggle:SetShown(db.CompactBarMode == COMPACTBARMODE_TOGGLE and db.ShowToggleButton)
  UpdateMainMenuBarPositions()
end

function CompactActionBar:UpdateMainMenuBarTextures()
  -- Texture theme
  SetMainMenuBarTexture(db.GryphonsTextureTheme)
  SetUseSmoothFonts(db.UseSmoothFonts)

  -- Texture visibility
  SetMainMenuBarArtVisbility(not db.HideMainBarEndCaps)
  SetMainMenuBarBackgroundVisbility(not db.HideMainBarBackground)
  SetMaxLevelTexturesVisibility(not db.HideMainBarBackground)
  SetXPBarTexturesVisibility(not db.HideMainBarXPTexture)

  -- Force other reputation bar texture
  ReputationWatchBar.StatusBar.WatchBarTexture0:Hide()
  ReputationWatchBar.StatusBar.WatchBarTexture1:Hide()
  ReputationWatchBar.StatusBar.WatchBarTexture2:Hide()
  ReputationWatchBar.StatusBar.WatchBarTexture3:Hide()
  ReputationWatchBar.StatusBar.XPBarTexture0:Show()
  ReputationWatchBar.StatusBar.XPBarTexture1:Show()
  ReputationWatchBar.StatusBar.XPBarTexture2:Show()
  ReputationWatchBar.StatusBar.XPBarTexture3:Show()
end

function CompactActionBar:Update()
  db = self.db.profile

  CompactActionBarToggle:SetEnabled(not InCombatLockdown())

  if InCombatLockdown() then return end

  -- Frame Strata
  MainMenuBar:SetFrameStrata(db.MainMenuBarStrata)

  InitContainerLayout()
  self:UpdateMainMenuBarLayout()
  self:UpdateMainMenuBarTextures()

  -- Layout update
  SetMainMenuBarScale(db.MainMenuBarScale)

  -- Toggle texture
  local ButtonTexture = "Interface/Buttons/Button-Backpack-Up"
  if DisplayRightSideButtons then
    ButtonTexture = ActionButton1Icon:GetTexture()
  end
  CompactActionBarToggleIconTexture:SetTexture(ButtonTexture)

  -- Bag slots
  local NumberOfFreeSlots =
    GetContainerNumFreeSlots(0) +
    GetContainerNumFreeSlots(1) +
    GetContainerNumFreeSlots(2) +
    GetContainerNumFreeSlots(3) +
    GetContainerNumFreeSlots(4)

end

-- Init
function CompactActionBar:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("CompactActionBarDB", { profile = DefaultOptions })
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
  self:SetEnabledState(self.db.profile.enabled)
  db = self.db.profile

  local Options = self:GetOptions()

  Options.args.Profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  LibStub("AceConfig-3.0"):RegisterOptionsTable("CompactActionBar", Options)

  -- Add options to Interface/AddOns
  self.optionsFrame = Dialog:AddToBlizOptions("CompactActionBar", "Compact Action Bar")

  hooksecurefunc("UIParent_ManageFramePositions", function() self:Update() end)
  MainMenuBar:HookScript("OnShow", function() self:Update() end)

  -- Watch these events and update layout
  local WatchedEvents = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_XP_UPDATE",
    "PLAYER_LEVEL_CHANGED",
    "PLAYER_LEVEL_UP",
    "PLAYER_ENTER_COMBAT",
    "PLAYER_LEAVE_COMBAT",
    "UPDATE_FACTION",
    "UPDATE_INSTANCE_INFO",
    "UPDATE_BONUS_ACTIONBAR",
    "ACTIONBAR_PAGE_CHANGED",
    "ACTIONBAR_SHOW_BOTTOMLEFT",
    "ACTIONBAR_SLOT_CHANGED",
    "ACTIONBAR_UPDATE_STATE",
    "ACTIONBAR_UPDATE_USABLE",
    "PET_BAR_UPDATE",
    "PET_BAR_UPDATE_USABLE",
    "PET_BAR_HIDEGRID",
    "PET_BAR_SHOWGRID",
    "PET_BAR_UPDATE_COOLDOWN",
  }

  for i, EventName in pairs(WatchedEvents) do
    CompactActionBarContainer:RegisterEvent(EventName)
  end

  CompactActionBarContainer:SetScript("OnEvent", function() self:Update() end)

  InitContainerLayout()
  InitExperienceBarsLayout()

  self:Update()
end

function CompactActionBar:RefreshConfig()
  self:Update()
end

function CompactActionBar:GetDB(Key)
  return self.db.profile[Key]
end

function CompactActionBar:SetDB(Key, Value)
  self.db.profile[Key] = Value
  self:Update()
end

function CompactActionBar:UsePreset(Name)
  for Key, Value in pairs(Presets[Name]) do
    self.db.profile[Key] = Value
  end

  self:Update()
end

function CompactActionBarToggleButtons()
  if db.CompactBarMode ~= COMPACTBARMODE_TOGGLE then return end

  DisplayRightSideButtons = not(DisplayRightSideButtons)
  PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
  CompactActionBar:Update()
end