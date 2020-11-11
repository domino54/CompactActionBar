local CompactActionBar = LibStub("AceAddon-3.0"):GetAddon("CompactActionBar")

--- Layout Manager: Classic module
-- Handles the positioning of the action bar elements on the screen.
-- @module LayoutManager
-- @alias M
local LayoutManager, M = CompactActionBar:CreateModule("LayoutManager/Classic")

--- Table of possible toggle states od the action bar.
local TOGGLESTATE = {
  NONE  = 0,    -- None of the sides visible
  LEFT  = 1,    -- Left side container visible
  RIGHT = 2,    -- Right side container visible
  BOTH  = 3,    -- Both sides visible
}

--- Path to the replacement experience bar texture file.
local ExperienceBarTextureFile = CompactActionBar.MediaRoot.."Textures\\ExperienceBar"

--- Create the containers for main menu bar contents.
local function CreateMainMenuBarContainers()
  local PageSwitchWidth = 40

  -- Main container for action bars
  M.CompactActionBarOffset = CreateFrame("Frame", "CompactActionBarOffset", UIParent)
  M.CompactActionBarOffset:SetWidth(1)
  M.CompactActionBarOffset:SetHeight(1)
  M.CompactActionBarOffset:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)

  -- Main container for action bars
  M.CompactActionBarContainer = CreateFrame("Frame", "CompactActionBarContainer", MainMenuBar)
  M.CompactActionBarContainer:SetWidth(1024)
  M.CompactActionBarContainer:SetHeight(43)
  M.CompactActionBarContainer:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, 0)

  -- Container for left side buttons
  M.CompactActionBarLeftBarFrame = CreateFrame("Frame", "CompactActionBarLeftBarFrame", M.CompactActionBarContainer)
  M.CompactActionBarLeftBarFrame:SetWidth(512)
  M.CompactActionBarLeftBarFrame:SetHeight(43)
  M.CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
  M.CompactActionBarLeftBarFrame:SetFrameLevel(2)

  -- Page switch background
  M.PageSwitchTexture = M.CompactActionBarLeftBarFrame:CreateTexture()
  M.PageSwitchTexture:SetTexture(MainMenuBarTexture0:GetTexture())
  M.PageSwitchTexture:SetPoint("BOTTOMLEFT", MainMenuBarTexture1, "BOTTOMRIGHT", 0, 0)
  M.PageSwitchTexture:SetWidth(PageSwitchWidth)
  M.PageSwitchTexture:SetHeight(MainMenuBarTexture0:GetHeight())
  M.PageSwitchTexture:SetTexCoord(0, M.PageSwitchTexture:GetWidth() / MainMenuBarTexture0:GetWidth(), 1/3, 0.5)
  M.PageSwitchTexture:Hide()

  -- Container for right side buttons
  M.CompactActionBarRightBarFrame = CreateFrame("Frame", "CompactActionBarRightBarFrame", M.CompactActionBarContainer)
  M.CompactActionBarRightBarFrame:SetWidth(512)
  M.CompactActionBarRightBarFrame:SetHeight(43)
  M.CompactActionBarRightBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarLeftBarFrame, "BOTTOMRIGHT", 0, 0)
  M.CompactActionBarRightBarFrame:SetFrameLevel(2)

  -- Additional background textures for micro buttons
  local ButtonsTextureWidth = (MainMenuBarTexture0:GetWidth() + M.PageSwitchTexture:GetWidth()) / 2
  local ButtonsTextureRatio = ButtonsTextureWidth / MainMenuBarTexture0:GetWidth()

  M.MiniButtonsExtendedTexture0 = M.CompactActionBarRightBarFrame:CreateTexture()
  M.MiniButtonsExtendedTexture0:SetTexture(MainMenuBarTexture0:GetTexture())
  M.MiniButtonsExtendedTexture0:SetPoint("BOTTOMRIGHT", MainMenuBarTexture3, "BOTTOMLEFT", 0, 0)
  M.MiniButtonsExtendedTexture0:SetTexCoord(1-ButtonsTextureRatio, 1, 1/3, 0.5)
  M.MiniButtonsExtendedTexture0:SetWidth(ButtonsTextureWidth)
  M.MiniButtonsExtendedTexture0:SetHeight(MainMenuBarTexture0:GetHeight())
  M.MiniButtonsExtendedTexture0:Hide()

  M.MiniButtonsExtendedTexture1 = M.CompactActionBarRightBarFrame:CreateTexture()
  M.MiniButtonsExtendedTexture1:SetTexture(MainMenuBarTexture0:GetTexture())
  M.MiniButtonsExtendedTexture1:SetPoint("BOTTOMRIGHT", M.MiniButtonsExtendedTexture0, "BOTTOMLEFT", 0, 0)
  M.MiniButtonsExtendedTexture1:SetTexCoord(1, ButtonsTextureRatio, 1/3, 0.5)
  M.MiniButtonsExtendedTexture1:SetWidth(ButtonsTextureWidth)
  M.MiniButtonsExtendedTexture1:SetHeight(MainMenuBarTexture0:GetHeight())
  M.MiniButtonsExtendedTexture1:Hide()

  -- Clipped container for experience bar textures
  M.MainMenuXPBarTextureContainer = CreateFrame("Frame", "MainMenuXPBarTextureContainer", MainMenuExpBar)
  M.MainMenuXPBarTextureContainer:SetPoint("BOTTOMLEFT", MainMenuExpBar, "BOTTOMLEFT", 0, 0)
  M.MainMenuXPBarTextureContainer:SetPoint("TOPRIGHT", MainMenuExpBar, "TOPRIGHT", 0, 0)
  M.MainMenuXPBarTextureContainer:SetClipsChildren(true)
  M.MainMenuXPBarTextureContainer:SetFrameLevel(3)
end

--- Initialize the new internal layout of experience and reputation bars.
local function InitExperienceAndReputationBarsLayout()
  -- Experience bar text
  MainMenuBarExpText:ClearAllPoints()
  MainMenuBarExpText:SetPoint("CENTER", MainMenuExpBar, "CENTER", 0, 0)

  -- Attach experience bar textures to new container
  MainMenuXPBarTexture0:ClearAllPoints()
  MainMenuXPBarTexture0:SetParent(M.MainMenuXPBarTextureContainer)
  MainMenuXPBarTexture0:SetPoint("BOTTOMLEFT", MainMenuExpBar, "BOTTOMLEFT", 0, 0)
  MainMenuXPBarTexture0:SetPoint("TOPLEFT", MainMenuExpBar, "TOPLEFT", 0, 0)

  for i = 1, 3 do
    local CurrentTexture = _G["MainMenuXPBarTexture"..i]
    local PreviousTexture = _G["MainMenuXPBarTexture"..(i-1)]

    CurrentTexture:ClearAllPoints()
    CurrentTexture:SetParent(M.MainMenuXPBarTextureContainer)
    CurrentTexture:SetPoint("TOPLEFT", PreviousTexture, "TOPRIGHT", 0, 0)
    CurrentTexture:SetPoint("BOTTOMLEFT", PreviousTexture, "BOTTOMRIGHT", 0, 0)
  end

  -- Resting bonus tick
  ExhaustionLevelFillBar:ClearAllPoints()
  ExhaustionLevelFillBar:SetPoint("BOTTOMLEFT", MainMenuExpBar, "BOTTOMLEFT", 0, 0)
  ExhaustionLevelFillBar:SetPoint("TOPRIGHT", MainMenuExpBar, "TOPRIGHT", 0, 0)

  -- Reputation bar
  ReputationWatchBar.StatusBar:SetClipsChildren(true)

  ReputationWatchBar.StatusBar:ClearAllPoints()
  ReputationWatchBar.StatusBar:SetPoint("TOPLEFT", ReputationWatchBar, "TOPLEFT", 0, 0)
  ReputationWatchBar.StatusBar:SetPoint("BOTTOMLEFT", ReputationWatchBar, "BOTTOMLEFT", 0, 0)

  ReputationWatchBar.StatusBar.XPBarTexture0:ClearAllPoints()
  ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar, "TOPLEFT", 0, 0)
  ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("BOTTOMLEFT", ReputationWatchBar.StatusBar, "BOTTOMLEFT", 0, 0)

  for i = 1, 3 do
    local CurrentTexture = ReputationWatchBar.StatusBar["XPBarTexture"..i]
    local PreviousTexture = ReputationWatchBar.StatusBar["XPBarTexture"..i-1]

    CurrentTexture:ClearAllPoints()
    CurrentTexture:SetPoint("TOPLEFT", PreviousTexture, "TOPRIGHT", 0, 0)
    CurrentTexture:SetPoint("BOTTOMLEFT", PreviousTexture, "BOTTOMRIGHT", 0, 0)
  end

  -- Max level bar (action bar top rail)
  MainMenuBarMaxLevelBar:SetClipsChildren(true)

  MainMenuMaxLevelBar0:ClearAllPoints()
  MainMenuMaxLevelBar0:SetPoint("BOTTOMLEFT", MainMenuBarMaxLevelBar, "BOTTOMLEFT", 0, 0)
  MainMenuMaxLevelBar0:SetPoint("TOPLEFT", MainMenuBarMaxLevelBar, "TOPLEFT", 0, 0)

  for i = 1, 3 do
    local CurrentTexture = _G["MainMenuMaxLevelBar"..i]
    local PreviousTexture = _G["MainMenuMaxLevelBar"..i-1]

    CurrentTexture:ClearAllPoints()
    CurrentTexture:SetPoint("TOPLEFT", PreviousTexture, "TOPRIGHT", 0, 0)
    CurrentTexture:SetPoint("BOTTOMLEFT", PreviousTexture, "BOTTOMRIGHT", 0, 0)
  end
end

--- Initialize the elements layout of Compact Action Bar containers.
-- This function may be called multiple times to fix some frames jumping back to their original locations.
-- @tparam boolean PageSwitchInLeft - If the action bar page switch should appear with action buttons, similarly to retail.
local function InitContainersLayout(PageSwitchInLeft)
  assert(type(PageSwitchInLeft) == "boolean", "PageSwitchInLeft must be a boolean.")

  -- Anchor main menu bar to the offsetter
  MainMenuBar:ClearAllPoints()
  MainMenuBar:SetPoint("BOTTOM", M.CompactActionBarOffset, "BOTTOM", 0, 0)

  -- Reset width
  M.CompactActionBarLeftBarFrame:SetWidth(MainMenuBarTexture0:GetWidth() + MainMenuBarTexture1:GetWidth())
  M.CompactActionBarRightBarFrame:SetWidth(MainMenuBarTexture2:GetWidth() + MainMenuBarTexture3:GetWidth())

  local TargetParentRelations = {
    -- Left frame children
    CompactActionBarLeftBarFrame = {
      MainMenuBarTexture0,
      MainMenuBarTexture1,
      ActionButton1,
      ActionButton2,
      ActionButton3,
      ActionButton4,
      ActionButton5,
      ActionButton6,
      ActionButton7,
      ActionButton8,
      ActionButton9,
      ActionButton10,
      ActionButton11,
      ActionButton12,
    },

    -- Right frame children
    CompactActionBarRightBarFrame = {
      MainMenuBarTexture2,
      MainMenuBarTexture3,
      CharacterMicroButton,
      SpellbookMicroButton,
      TalentMicroButton,
      QuestLogMicroButton,
      SocialsMicroButton,
      WorldMapMicroButton,
      MainMenuMicroButton,
      HelpMicroButton,
      MainMenuBarPerformanceBarFrame,
      KeyRingButton,
      CharacterBag3Slot,
      CharacterBag2Slot,
      CharacterBag1Slot,
      CharacterBag0Slot,
      MainMenuBarBackpackButton,
    },
  }

  -- Add page switch to correct parent
  local PageSwitchFrames = {
    ActionBarUpButton,
    ActionBarDownButton,
    MainMenuBarPageNumber,
  }

  for i, Frame in pairs(PageSwitchFrames) do
    if (PageSwitchInLeft) then
      table.insert(TargetParentRelations.CompactActionBarLeftBarFrame, Frame)
    else
      table.insert(TargetParentRelations.CompactActionBarRightBarFrame, Frame)
    end
  end

  -- Set parent frames
  for ContainerFrame, TargetChildren in pairs(TargetParentRelations) do
    for i, Frame in pairs(TargetChildren) do
      Frame:SetParent(ContainerFrame)
    end
  end

  -- Setup page switch controls
  local PageSwitchLeftOffset = 30
  local CharacterButtonLeftOffset = 40

  if (PageSwitchInLeft) then
    PageSwitchLeftOffset = PageSwitchLeftOffset + M.CompactActionBarLeftBarFrame:GetWidth()
    CharacterButtonLeftOffset = 6

    -- Elongate the frames
    M.CompactActionBarLeftBarFrame:SetWidth(M.CompactActionBarLeftBarFrame:GetWidth() + M.PageSwitchTexture:GetWidth())
    M.CompactActionBarRightBarFrame:SetWidth(M.CompactActionBarRightBarFrame:GetWidth() + M.PageSwitchTexture:GetWidth())
  end

  -- Move page switch controls
  MainMenuBarPageNumber:ClearAllPoints()
  MainMenuBarPageNumber:SetPoint("CENTER", MainMenuBarPageNumber:GetParent(), "BOTTOMLEFT", PageSwitchLeftOffset, 21)

  ActionBarUpButton:ClearAllPoints()
  ActionBarUpButton:SetPoint("CENTER", MainMenuBarPageNumber, "CENTER", -20, 10)

  ActionBarDownButton:ClearAllPoints()
  ActionBarDownButton:SetPoint("CENTER", MainMenuBarPageNumber, "CENTER", -20, -10)

  -- Custom texture visibility
  M.PageSwitchTexture:SetShown(PageSwitchInLeft)
  M.MiniButtonsExtendedTexture0:SetShown(PageSwitchInLeft)
  M.MiniButtonsExtendedTexture1:SetShown(PageSwitchInLeft)
  MainMenuBarTexture2:SetShown(not PageSwitchInLeft)

  -- Setup the left frame
  MainMenuBarTexture0:ClearAllPoints()
  MainMenuBarTexture0:SetParent(M.CompactActionBarLeftBarFrame)
  MainMenuBarTexture0:SetPoint("BOTTOMLEFT", M.CompactActionBarLeftBarFrame, "BOTTOMLEFT", 0, 0)
  MainMenuBarTexture1:ClearAllPoints()
  MainMenuBarTexture1:SetParent(M.CompactActionBarLeftBarFrame)
  MainMenuBarTexture1:SetPoint("BOTTOMLEFT", MainMenuBarTexture0, "BOTTOMRIGHT", 0, 0)

  -- Move the action buttons
  ActionButton1:ClearAllPoints()
  ActionButton1:SetPoint("BOTTOMLEFT", M.CompactActionBarLeftBarFrame, "BOTTOMLEFT", 8, 4)

  -- Setup the right frame
  MainMenuBarTexture3:ClearAllPoints()
  MainMenuBarTexture3:SetPoint("BOTTOMRIGHT", M.CompactActionBarRightBarFrame, "BOTTOMRIGHT", 0, 0)
  MainMenuBarTexture2:ClearAllPoints()
  MainMenuBarTexture2:SetPoint("BOTTOMRIGHT", MainMenuBarTexture3, "BOTTOMLEFT", 0, 0)

  -- Micro buttons
  CharacterMicroButton:ClearAllPoints()
  CharacterMicroButton:SetPoint("BOTTOMLEFT", M.CompactActionBarRightBarFrame, "BOTTOMLEFT", CharacterButtonLeftOffset, 2)

  -- Latency
  MainMenuBarPerformanceBarFrame:ClearAllPoints()
  MainMenuBarPerformanceBarFrame:SetPoint("BOTTOMRIGHT", M.CompactActionBarRightBarFrame, "BOTTOMRIGHT", -235, -10)
  MainMenuBarPerformanceBarFrame:SetFrameLevel(1)
  MainMenuBarPerformanceBarFrameButton:SetFrameLevel(3)

  -- Backpack button
  MainMenuBarBackpackButton:ClearAllPoints()
  MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", M.CompactActionBarRightBarFrame, "BOTTOMRIGHT", -6, 2)

  -- Dynamic end caps position
  MainMenuBarArtFrame:SetFrameLevel(4)
  MainMenuBarLeftEndCap:ClearAllPoints()
  MainMenuBarLeftEndCap:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOMLEFT", 32, 0)
  MainMenuBarRightEndCap:ClearAllPoints()
  MainMenuBarRightEndCap:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMRIGHT", -32, 0)

  -- Offset the reputation bar text
  ReputationWatchBar.OverlayFrame.Text:ClearAllPoints()
  ReputationWatchBar.OverlayFrame.Text:SetPoint("CENTER", ReputationWatchBar.OverlayFrame, "CENTER", 0, 0)

  -- Force XP-style reputation bar texture
  for i = 0, 3 do
    ReputationWatchBar.StatusBar["WatchBarTexture"..i]:Hide()
    ReputationWatchBar.StatusBar["XPBarTexture"..i]:Show()
  end

  -- Custom experience and reputation bars texture
  ReputationWatchBar.StatusBar.BarTexture:SetTexture(ExperienceBarTextureFile)
  local Regions = { MainMenuExpBar:GetRegions() }
  Regions[3]:SetTexture(ExperienceBarTextureFile)
end

--- Set the opacity of a set of textures.
-- @tparam table Textures - Table of game textures.
-- @tparam number Opacity - Opacity, 'number' between 0.0 and 1.0.
local function SetTexturesOpacity(Textures, Opacity)
  assert(type(Textures) == "table", "Textures must be a table.")
  assert(type(Opacity) == "number", "Opacity must be a number.")
  assert(Opacity >= 0 and Opacity <= 1, "Opacity must be a beteen 0 and 1, inclusive.")

  for i, Texture in pairs(Textures) do
    Texture:SetAlpha(Opacity)
  end
end

--- Set the width of the experience and reputation bars textures.
-- @tparam number XPBarWidth - Width of the textures.
local function SetXPBarTexturesWidth(XPBarWidth)
  assert(type(XPBarWidth) == "number", "XPBarWidth must be a number.")

  local Textures = {}

  for i = 0, 3 do
    table.insert(Textures, ReputationWatchBar.StatusBar["WatchBarTexture"..i])
    table.insert(Textures, ReputationWatchBar.StatusBar["XPBarTexture"..i])
    table.insert(Textures, _G["MainMenuXPBarTexture"..i])
  end

  for i, Texture in pairs(Textures) do
    Texture:SetWidth(XPBarWidth)
  end
end

--- Set the width of the main menu bar.
-- @tparam number MainMenuBarWidth - Width of the bar.
local function SetMainMenuBarWidth(MainMenuBarWidth)
  assert(type(MainMenuBarWidth) == "number", "MainMenuBarWidth must be a number.")

  MainMenuBar:SetWidth(MainMenuBarWidth)
  MainMenuExpBar:SetWidth(MainMenuBarWidth)
  ReputationWatchBar:SetWidth(MainMenuBarWidth)
  MainMenuBarMaxLevelBar:SetWidth(MainMenuBarWidth)
  ReputationWatchBar.StatusBar:SetWidth(MainMenuBarWidth)
end

--- Set the arrangement of the left and right Compact Action Bar containers.
-- @tparam number ActionBarMode - Current action bar mode.
local function SetContainersArrangement(ActionBarMode)
  assert(type(ActionBarMode) == "number", "ActionBarMode must be a number.")

  M.CompactActionBarLeftBarFrame:ClearAllPoints()
  M.CompactActionBarRightBarFrame:ClearAllPoints()

  -- Full bar, stack horizontally
  if (ActionBarMode == CompactActionBar.COMPACTBARMODE.DISABLED) then
    M.CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
    M.CompactActionBarRightBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarLeftBarFrame, "BOTTOMRIGHT", 0, 0)

    M.CompactActionBarContainer:SetWidth(M.CompactActionBarLeftBarFrame:GetWidth() + M.CompactActionBarRightBarFrame:GetWidth())
    M.CompactActionBarContainer:SetHeight(M.CompactActionBarLeftBarFrame:GetHeight())

  -- Compact bar in toggle mode
  elseif (ActionBarMode == CompactActionBar.COMPACTBARMODE.TOGGLE) then
    M.CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
    M.CompactActionBarRightBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarContainer, "BOTTOMLEFT", 0, 0)

    M.CompactActionBarContainer:SetWidth(M.CompactActionBarLeftBarFrame:GetWidth())
    M.CompactActionBarContainer:SetHeight(M.CompactActionBarLeftBarFrame:GetHeight())

  -- Bars stacked vertically
  elseif (ActionBarMode == CompactActionBar.COMPACTBARMODE.STACKED) then
    M.CompactActionBarRightBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarContainer, "BOTTOMLEFT", 0, 0)
    M.CompactActionBarLeftBarFrame:SetPoint("BOTTOMLEFT", M.CompactActionBarRightBarFrame, "TOPLEFT", 0, 0)

    M.CompactActionBarContainer:SetWidth(M.CompactActionBarLeftBarFrame:GetWidth())
    M.CompactActionBarContainer:SetHeight(M.CompactActionBarLeftBarFrame:GetHeight() + M.CompactActionBarRightBarFrame:GetHeight())
  end

  SetMainMenuBarWidth(M.CompactActionBarContainer:GetWidth())
end

--- Set the orientation of cuttons inside a multi action bar.
-- @tparam string Side - Multi bar to set, must be either 'Left' or 'Right'.
-- @tparam boolean IsHorizontal - Whether the layour should be vertical or horizontal.
local function SetMultiBarOrientation(Side, IsHorizontal)
  assert(type(Side) == "string", "Side must be a string.")
  assert(Side == "Left" or Side == "Right", "Side must be one of: \"Left\", \"Right\".")
  assert(type(IsHorizontal) == "boolean", "IsHorizontal must be a boolean.")

  local MultiBar = _G["MultiBar"..Side]
  local ButtonName = "MultiBar"..Side.."Button"

  -- Find original width and height of the multi bar
  local BarHeight = math.max(math.abs(MultiBar:GetHeight()), math.abs(MultiBar:GetWidth()))
  local BarWidth = math.min(math.abs(MultiBar:GetHeight()), math.abs(MultiBar:GetWidth()))

  local AnchorPrevButton = ""
  local AnchorNextButton = ""
  local DiffHorizontal = 0
  local DiffVertical = 0

  _G[ButtonName..1]:ClearAllPoints()

  -- Horizontal layout
  if IsHorizontal then
    MultiBar:SetHeight(BarWidth)
    MultiBar:SetWidth(BarHeight)

    -- Align first button
    _G[ButtonName..1]:SetPoint("BOTTOMLEFT", MultiBar, "BOTTOMLEFT", 0, 0)

    AnchorPrevButton = "LEFT"
    AnchorNextButton = "RIGHT"
    DiffHorizontal = 6
    DiffVertical = 0

  -- Vertical layout
  else
    MultiBar:SetHeight(BarHeight)
    MultiBar:SetWidth(BarWidth)

    -- Align first button
    _G[ButtonName..1]:SetPoint("TOPRIGHT", MultiBar, "TOPRIGHT", -2, -3)

    AnchorPrevButton = "TOP"
    AnchorNextButton = "BOTTOM"
    DiffHorizontal = 0
    DiffVertical = -6
  end

  -- Stack buttons
  for i = 2, 12 do
    _G[ButtonName..i]:ClearAllPoints()
    _G[ButtonName..i]:SetPoint(AnchorPrevButton, _G[ButtonName..i-1], AnchorNextButton, DiffHorizontal, DiffVertical)
  end
end

--- Update the arrangement of the main menu bar contents.
local function UpdateActionBarArrangement()
  local GlobalAnchorOffsetY = 0
  local RightAnchorOffsetX = 512

  if (M.CompactBarMode ~= CompactActionBar.COMPACTBARMODE.DISABLED) then
    RightAnchorOffsetX = 0
  end

  -- Action buttons at the bottom
  if (not M.ExperienceBarAtBottom) then
    M.CompactActionBarContainer:ClearAllPoints()
    M.CompactActionBarContainer:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

    if (M.CompactActionBarContainer:IsShown()) then
      GlobalAnchorOffsetY = GlobalAnchorOffsetY + M.CompactActionBarContainer:GetHeight()
    end
  end

  -- Experience bar
  MainMenuExpBar:SetHeight(M.ExperienceBarHeight)
  MainMenuExpBar:ClearAllPoints()
  MainMenuExpBar:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

  if MainMenuExpBar:IsShown() then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY + MainMenuExpBar:GetHeight()
  end

  -- Reputation bar
  local ReputationBarHeight = MainMenuExpBar:GetHeight()

  if (MainMenuExpBar:IsShown()) then
    ReputationBarHeight = M.ReputationBarHeight
  end

  ReputationWatchBar:SetHeight(ReputationBarHeight)
  ReputationWatchBar:ClearAllPoints()
  ReputationWatchBar:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

  if (ReputationWatchBar:IsShown()) then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY + ReputationWatchBar:GetHeight()
  end

  -- Action buttons above XP & reputation
  if (M.ExperienceBarAtBottom) then
    CompactActionBarContainer:ClearAllPoints()
    CompactActionBarContainer:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

    if CompactActionBarContainer:IsShown() then
      GlobalAnchorOffsetY = GlobalAnchorOffsetY + CompactActionBarContainer:GetHeight()
    end
  end

  -- Max level bar
  MainMenuBarMaxLevelBar:SetShown(MainMenuMaxLevelBar0:GetAlpha() > 0 and (M.ExperienceBarAtBottom or not(MainMenuExpBar:IsShown() or ReputationWatchBar:IsShown())))
  MainMenuBarMaxLevelBar:ClearAllPoints()
  MainMenuBarMaxLevelBar:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, GlobalAnchorOffsetY)

  if (MainMenuBarMaxLevelBar:IsShown()) then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY + MainMenuBarMaxLevelBar:GetHeight()
  end

  -- Fixes small gap in Minimalistic preset
  if (M.ExperienceBarAtBottom and not MainMenuBarMaxLevelBar:IsShown()) then
    GlobalAnchorOffsetY = GlobalAnchorOffsetY - 1
  end

  -- Split anchors to left and right side
  local LeftAnchorOffsetY   = GlobalAnchorOffsetY
  local RightAnchorOffsetY  = GlobalAnchorOffsetY

  -- Bottom left action bar offset
  MultiBarBottomLeft:ClearAllPoints()
  MultiBarBottomLeft:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 8, LeftAnchorOffsetY + 4)

  if (MultiBarBottomLeft:IsShown()) then
    LeftAnchorOffsetY = LeftAnchorOffsetY + MultiBarBottomLeft:GetHeight() + 4
  end

  if (M.CompactBarMode ~= CompactActionBar.COMPACTBARMODE.DISABLED) then
    RightAnchorOffsetY = LeftAnchorOffsetY
  end

  -- Bottom right action bar offset
  MultiBarBottomRight:ClearAllPoints()
  MultiBarBottomRight:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", RightAnchorOffsetX + 8, RightAnchorOffsetY + 4)

  if (MultiBarBottomRight:IsShown()) then
    RightAnchorOffsetY = RightAnchorOffsetY + MultiBarBottomRight:GetHeight() + 4
  end

  -- Stack right action bar 1
  MultiBarRight:ClearAllPoints()
  MultiBarRight:SetScale(1.0)
  SetMultiBarOrientation("Right", M.StackMultiBarRight)

  if (M.StackMultiBarRight) then
    MultiBarRight:SetParent(MainMenuBar)
    MultiBarRight:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", RightAnchorOffsetX + 8, RightAnchorOffsetY + 4)

    if (MultiBarRight:IsShown()) then
      RightAnchorOffsetY = RightAnchorOffsetY + MultiBarRight:GetHeight() + 1
    end
  else
    MultiBarRight:SetParent(VerticalMultiBarsContainer)
    MultiBarRight:SetPoint("TOPRIGHT", VerticalMultiBarsContainer, "TOPRIGHT", 0, 0)
  end

  if (M.CompactBarMode ~= CompactActionBar.COMPACTBARMODE.DISABLED) then
    LeftAnchorOffsetY = RightAnchorOffsetY
  end

  -- Stack right action bar 2
  MultiBarLeft:ClearAllPoints()
  MultiBarLeft:SetScale(1.0)
  SetMultiBarOrientation("Left", M.StackMultiBarLeft)

  if (M.StackMultiBarLeft) then
    MultiBarLeft:SetParent(MainMenuBar)
    MultiBarLeft:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 8, LeftAnchorOffsetY + 4)

    if (MultiBarLeft:IsShown()) then
      LeftAnchorOffsetY = LeftAnchorOffsetY + MultiBarLeft:GetHeight() + 1
    end
  else
    MultiBarLeft:SetParent(VerticalMultiBarsContainer)

    if (M.StackMultiBarRight) then
      MultiBarLeft:SetPoint("TOPRIGHT", VerticalMultiBarsContainer, "TOPRIGHT", 0, 0)
    else
      MultiBarLeft:SetPoint("TOPRIGHT", MultiBarRight, "TOPLEFT", -2, 0)
    end
  end

  -- Fix pet bar offset
  if (MultiBarBottomLeft:IsShown()) then
    LeftAnchorOffsetY = LeftAnchorOffsetY + 1
  end

  -- Pet bar offset
  PetActionBarFrame:ClearAllPoints()
  PetActionBarFrame:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 36, LeftAnchorOffsetY)

  if (PetActionBarFrame:IsShown()) then
    LeftAnchorOffsetY = LeftAnchorOffsetY + 36
  end

  -- Stance / shapeshift
  StanceBarFrame:ClearAllPoints()
  StanceBarFrame:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 32, LeftAnchorOffsetY)

  if (StanceBarFrame:IsShown()) then
    LeftAnchorOffsetY = LeftAnchorOffsetY + 36
  end
end

--- Set the current toggle state of the bars.
-- @tparam number ToggleState - Current toggle state.
local function SetToggleState(ToggleState)
  assert(type(ToggleState) == "number", "ToggleState must be a number.")

  M.CompactActionBarLeftBarFrame:SetShown(ToggleState == TOGGLESTATE.BOTH or ToggleState == TOGGLESTATE.LEFT)
  M.CompactActionBarRightBarFrame:SetShown(ToggleState == TOGGLESTATE.BOTH or ToggleState == TOGGLESTATE.RIGHT)
end

--- Set the properties of an action button label.
-- @tparam string LabelType - Name of the label to set its properties, bust be either 'HotKey', 'Name' or 'Count'.
-- @tparam table FontProperties - Properties of the font.
local function SetActionButtonFont(LabelType, FontProperties)
  assert(type(LabelType) == "string", "LabelType must be a string.")
  assert(type(FontProperties) == "table", "FontProperties must be a table.")

  local ButtonTypeNames = {
    "ActionButton",
    "PetActionButton",
    "MultiBarLeftButton",
    "MultiBarRightButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
  }

  for j, ButtonType in pairs(ButtonTypeNames) do
    local ButtonCount = 12

    if (ButtonType == "PetActionButton") then
      ButtonCount = 10
    end

    for i = 1, ButtonCount do
      local ActionButtonHotKey = _G[ButtonType..i..LabelType]

      CompactActionBar:ApplyFontProperties(ActionButtonHotKey, FontProperties)
    end
  end
end

--- Catch a WoW interface event.
-- @tparam table self - Event handling frame.
-- @tparam string Event - Name of the caught event.
function OnEvent(self, Event)
  M:Update()
end

--- Initialize the module.
function LayoutManager:Init()
  -- Init layout
  CreateMainMenuBarContainers()
  InitExperienceAndReputationBarsLayout()

  -- Default settings
  self:SetCompactBarMode(CompactActionBar.COMPACTBARMODE.DISABLED)
  self:SetPageSwitchInLeft(false)
  self:SetIsActionBarToggled(false)

  self:SetMainMenuBarScale(1.0)
  self:SetMainMenuBarOpacity(1.0)
  self:SetMainMenuBarOffset(0.0, 0.0)
  self:SetMainMenuBarStrata("MEDIUM")
  self:SetMainMenuTextureOpacity(1.0)

  self:SetExperienceBarHeight(10.0)
  self:SetReputationBarHeight(7.0)
  self:SetExperienceBarAtBottom(false)
  self:SetXPBarTextureOpacity(1.0)

  self:SetStackMultiBarLeft(false)
  self:SetStackMultiBarRight(false)

  self:SetMainMenuBarTextureStyle("Dwarf")
  self:SetEndCapsTextureOpacity(1.0)
  self:SetEndCapsTextureScale(1.0)

  -- Call self update if any of these events are fired
  local WatchedEvents = {
    "PLAYER_REGEN_DISABLED",  -- Enter combat
    "PLAYER_REGEN_ENABLED",   -- Leave combat
    "PLAYER_ENTERING_WORLD",
    "PLAYER_XP_UPDATE",
    "PLAYER_LEVEL_CHANGED",
    "PLAYER_LEVEL_UP",
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
    "BAG_UPDATE",
  }

  CompactActionBar:ModuleSubscribeToEvents(self.CompactActionBarContainer, WatchedEvents, OnEvent)

  -- Hook to functions
  hooksecurefunc("UIParent_ManageFramePositions", function() self:Update() end)
  MainMenuBar:HookScript("OnShow", function() self:Update() end)

  -- Call the first update
  self:Update()
end

--- Module global update.
function LayoutManager:Update()
  if (InCombatLockdown()) then return end

  local ToggleState = TOGGLESTATE.BOTH
  local IsToggleMode = self.CompactBarMode == CompactActionBar.COMPACTBARMODE.TOGGLE

  if (IsToggleMode) then
    if (self.IsActionBarToggled) then
      ToggleState = TOGGLESTATE.RIGHT
    else
      ToggleState = TOGGLESTATE.LEFT
    end
  end

  InitContainersLayout(IsToggleMode and self.PageSwitchInLeft)
  SetContainersArrangement(self.CompactBarMode)
  SetToggleState(ToggleState)
  SetXPBarTexturesWidth(self.CompactActionBarLeftBarFrame:GetWidth() / 2)
  UpdateActionBarArrangement()
end

--- Set the scale of the main menu bar.
-- @tparam number Scale - Scale of the bar, 'number' greater than 0.
function LayoutManager:SetMainMenuBarScale(Scale)
  assert(type(Scale) == "number", "Scale must be a number.")
  assert(Scale > 0, "Scale must be greater than 0.")

  MainMenuBar:SetScale(Scale)
end

--- Set the opacity of the main menu bar.
-- @tparam number Opacity - Opacity, 'number' between 0.0 and 1.0.
function LayoutManager:SetMainMenuBarOpacity(Opacity)
  assert(type(Opacity) == "number", "Opacity must be a number.")
  assert(Opacity >= 0 and Opacity <= 1, "Opacity must be a beteen 0 and 1, inclusive.")

  MainMenuBar:SetAlpha(Opacity)
end

--- Set the offset of the main menu bar.
-- @tparam number OffsetX - Horizontal offset.
-- @tparam number OffsetY - Vertical offset.
function LayoutManager:SetMainMenuBarOffset(OffsetX, OffsetY)
  assert(type(OffsetX) == "number", "OffsetX must be a number.")
  assert(type(OffsetY) == "number", "OffsetY must be a number.")

  self.CompactActionBarOffset:SetPoint("BOTTOM", UIParent, "BOTTOM", OffsetX, OffsetY)
end

--- Set the strata of the main menu bar frame.
-- @tparam string Strata - A strata value.
function LayoutManager:SetMainMenuBarStrata(Strata)
  assert(type(Strata) == "string", "Strata must be a string.")

  MainMenuBar:SetFrameStrata(Strata)
end

--- Set the opacity of the main menu bar background textures.
-- @tparam number Opacity - Opacity, 'number' between 0.0 and 1.0.
function LayoutManager:SetMainMenuTextureOpacity(Opacity)
  assert(type(Opacity) == "number", "Opacity must be a number.")
  assert(Opacity >= 0 and Opacity <= 1, "Opacity must be a beteen 0 and 1, inclusive.")

  local Textures = {
    self.PageSwitchTexture,
    self.MiniButtonsExtendedTexture0,
    self.MiniButtonsExtendedTexture1,
  }

  for i = 0, 3 do
    table.insert(Textures, _G["MainMenuBarTexture"..i])
    table.insert(Textures, _G["MainMenuMaxLevelBar"..i])
  end

  SetTexturesOpacity(Textures, Opacity)
end

--- Set the current compact bar mode.
-- @tparam number CompactBarMode - Active Compact Action Bar mode.
function LayoutManager:SetCompactBarMode(CompactBarMode)
  assert(type(CompactBarMode) == "number", "CompactBarMode must be a number.")

  self.CompactBarMode = CompactBarMode
end

--- Set if the action bar page switch should appear with action buttons or not.
-- @tparam boolean PageSwitchInLeft - If the action bar page switch should appear with action buttons, similarly to retail.
function LayoutManager:SetPageSwitchInLeft(PageSwitchInLeft)
  assert(type(PageSwitchInLeft) == "boolean", "PageSwitchInLeft must be a boolean.")

  self.PageSwitchInLeft = PageSwitchInLeft
end

--- Set if the action bar is toggled to the micro buttons and bags view or not.
-- @tparam boolean IsActionBarToggled - Whether the bar is toggled or not.
function LayoutManager:SetIsActionBarToggled(IsActionBarToggled)
  assert(type(IsActionBarToggled) == "boolean", "IsActionBarToggled must be a boolean.")

  self.IsActionBarToggled = IsActionBarToggled
end

--- Set the height of the experience bar.
-- @tparam number ExperienceBarHeight - New height of the bar, must be greater than 0.
function LayoutManager:SetExperienceBarHeight(ExperienceBarHeight)
  assert(type(ExperienceBarHeight) == "number", "ExperienceBarHeight must be a number.")
  assert(ExperienceBarHeight > 0, "ExperienceBarHeight must be greater than 0.")

  self.ExperienceBarHeight = ExperienceBarHeight
end

--- Set the height of the reputation bar.
-- @tparam number ReputationBarHeight - New height of the bar, must be greater than 0.
function LayoutManager:SetReputationBarHeight(ReputationBarHeight)
  assert(type(ReputationBarHeight) == "number", "ReputationBarHeight must be a number.")
  assert(ReputationBarHeight > 0, "ReputationBarHeight must be greater than 0.")

  self.ReputationBarHeight = ReputationBarHeight
end

--- Set whether the experience and reputation bars should appear below the action buttons or not.
-- @tparam boolean ExperienceBarAtBottom - If 'true', bars will be at the bottom.
function LayoutManager:SetExperienceBarAtBottom(ExperienceBarAtBottom)
  assert(type(ExperienceBarAtBottom) == "boolean", "ExperienceBarAtBottom must be a boolean.")

  self.ExperienceBarAtBottom = ExperienceBarAtBottom
end

--- Set the opacity of the experience and reputation bars overlay texture.
-- @tparam number Opacity - Opacity, 'number' between 0.0 and 1.0.
function LayoutManager:SetXPBarTextureOpacity(Opacity)
  assert(type(Opacity) == "number", "Opacity must be a number.")
  assert(Opacity >= 0 and Opacity <= 1, "Opacity must be a beteen 0 and 1, inclusive.")

  local Textures = {}

  for i = 0, 3 do
    table.insert(Textures, ReputationWatchBar.StatusBar["WatchBarTexture"..i])
    table.insert(Textures, ReputationWatchBar.StatusBar["XPBarTexture"..i])
    table.insert(Textures, _G["MainMenuXPBarTexture"..i])
  end

  SetTexturesOpacity(Textures, Opacity)
end

--- Set whether the left multi action bar should be stacked or not.
-- @tparam boolean StackMultiBarLeft - If 'true', the bar will stacked in the main menu bar.
function LayoutManager:SetStackMultiBarLeft(StackMultiBarLeft)
  assert(type(StackMultiBarLeft) == "boolean", "StackMultiBarLeft must be a boolean.")

  self.StackMultiBarLeft = StackMultiBarLeft
end

--- Set whether the right multi action bar should be stacked or not.
-- @tparam boolean StackMultiBarRight - If 'true', the bar will stacked in the main menu bar.
function LayoutManager:SetStackMultiBarRight(StackMultiBarRight)
  assert(type(StackMultiBarRight) == "boolean", "StackMultiBarRight must be a boolean.")

  self.StackMultiBarRight = StackMultiBarRight
end

--- Set the style of the main menu bar end caps.
-- @tparam string TextureStyle - Style of the end caps, must be either 'Dwarf' or 'Human'.
function LayoutManager:SetMainMenuBarTextureStyle(TextureStyle)
  assert(type(TextureStyle) == "string", "TextureStyle must be a string.")
  assert(TextureStyle == "Dwarf" or TextureStyle == "Human", "TextureStyle must be one of: \"Dwarf\", \"Human\".")

  local EndCapTexture = "Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-"..TextureStyle
  MainMenuBarLeftEndCap:SetTexture(EndCapTexture)
  MainMenuBarRightEndCap:SetTexture(EndCapTexture)

  local MainMenuBarTexture = "Interface\\MainMenuBar\\UI-MainMenuBar-"..TextureStyle
  MainMenuBarTexture0:SetTexture(MainMenuBarTexture)
  MainMenuBarTexture1:SetTexture(MainMenuBarTexture)
end

--- Set the opacity of the main menu bar end caps.
-- @tparam number Opacity - Opacity, 'number' between 0.0 and 1.0.
function LayoutManager:SetEndCapsTextureOpacity(Opacity)
  assert(type(Opacity) == "number", "Opacity must be a number.")
  assert(Opacity >= 0 and Opacity <= 1, "Opacity must be a beteen 0 and 1, inclusive.")

  local Textures = {
    MainMenuBarLeftEndCap,
    MainMenuBarRightEndCap,
  }

  SetTexturesOpacity(Textures, Opacity)
end

--- Set the scale of the main menu bar end caps.
-- @tparam number Scale - Scale of the bar, 'number' greater than 0.
function LayoutManager:SetEndCapsTextureScale(Scale)
  assert(type(Scale) == "number", "Scale must be a number.")
  assert(Scale > 0, "Scale must be greater than 0.")

  MainMenuBarLeftEndCap:SetScale(Scale)
  MainMenuBarRightEndCap:SetScale(Scale)
end

--- Set the properties of the action button count label font.
-- @tparam table FontProperties - Properties of the font.
function LayoutManager:SetActionButtonCountFont(FontProperties)
  SetActionButtonFont("Count", FontProperties)
end

--- Set the properties of the action button hotkey label font.
-- @tparam table FontProperties - Properties of the font.
function LayoutManager:SetActionButtonHotKeyFont(FontProperties)
  SetActionButtonFont("HotKey", FontProperties)
end

--- Set the properties of the action button name label font.
-- @tparam table FontProperties - Properties of the font.
function LayoutManager:SetActionButtonNameFont(FontProperties)
  SetActionButtonFont("Name", FontProperties)
end

--- Set the properties of the experience bar text label font.
-- @tparam table FontProperties - Properties of the font.
function LayoutManager:SetExperienceBarTextFont(FontProperties)
  CompactActionBar:ApplyFontProperties(MainMenuBarExpText, FontProperties)
end

--- Set the properties of the reputation bar text label font.
-- @tparam table FontProperties - Properties of the font.
function LayoutManager:SetReputationBarTextFont(FontProperties)
  CompactActionBar:ApplyFontProperties(ReputationWatchBar.OverlayFrame.Text, FontProperties)
end
