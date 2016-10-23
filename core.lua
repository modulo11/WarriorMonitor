local _, _, classIndex = UnitClass("player");

-- Exit if player is no warrior
if classIndex ~= 1 then
  return
end

local LibSharedMedia = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)

local defaults = {
  font = LibSharedMedia:Fetch(LibSharedMedia.MediaType.FONT, "Calibri"),
  background = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Solid"),
  fontSizeLarge = 23,
  fontSizeSmall = 15,
  positionX = -220,
  positionY = -180,
}

-- Base frame holding the additional buttons
local baseFrame = CreateFrame("Frame", nil, UIParent)
baseFrame:SetFrameStrata("BACKGROUND")
baseFrame:SetWidth(96)
baseFrame:SetHeight(48)
baseFrame:SetMovable(true)
baseFrame:EnableMouse(true)
baseFrame:RegisterForDrag("LeftButton")
baseFrame:SetScript("OnDragStart", baseFrame.StartMoving)
baseFrame:SetScript("OnDragStop", baseFrame.StopMovingOrSizing)

-- Frame for Ignore Pain
local ignorePainFrame = CreateFrame("Frame", "IgnorePainFrame", baseFrame)
ignorePainFrame:SetFrameStrata("BACKGROUND")
ignorePainFrame:SetWidth(48)
ignorePainFrame:SetHeight(48)
ignorePainFrame:SetPoint("LEFT")
ignorePainFrame:SetBackdrop({
    edgeFile = defaults.background,
    edgeSize = 3,
  })
ignorePainFrame:SetBackdropBorderColor(1, 0, 0)
ignorePainFrame.texture = ignorePainFrame:CreateTexture(nil, "BACKGROUND")
ignorePainFrame.texture:SetAllPoints()
ignorePainFrame.texture:SetTexture("Interface\\ICONS\\Ability_Warrior_RenewedVigor.blp")
ignorePainFrame.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

-- Timer for Ignore Pain
local ignorePainTime = ignorePainFrame:CreateFontString(nil, "OVERLAY")
ignorePainTime:SetPoint("TOP", 0, -6)
ignorePainTime:SetTextColor(1, 1, 1)
ignorePainTime:SetFont(defaults.font, defaults.fontSizeLarge, "OUTLINE")
ignorePainFrame.text = ignorePainTime

-- Absorb for Ignore Pain
local ignorePainAmount = ignorePainFrame:CreateFontString(nil, "OVERLAY")
ignorePainAmount:SetPoint("BOTTOM", 0, 6)
ignorePainAmount:SetTextColor(1, 1, 1)
ignorePainAmount:SetFont(defaults.font, defaults.fontSizeSmall, "OUTLINE")
ignorePainFrame.text = ignorePainAmount

-- Dragon Scales
local dragonScalesFrame = CreateFrame("Frame", "IgnorePainVengeance", ignorePainFrame)
dragonScalesFrame:SetFrameStrata("BACKGROUND")
dragonScalesFrame:SetWidth(15)
dragonScalesFrame:SetHeight(15)
dragonScalesFrame:SetPoint("TOP", 0, 15)
dragonScalesFrame:SetBackdrop({
    edgeFile = defaults.background,
    edgeSize = 3,
  })
dragonScalesFrame:SetBackdropBorderColor(0, 1, 0)
dragonScalesFrame.texture = dragonScalesFrame:CreateTexture(nil, "BACKGROUND")
dragonScalesFrame.texture:SetAllPoints()
dragonScalesFrame:Hide()

-- Vengeance: Ignore Pain
local vengeanceIgnorePainFrame = CreateFrame("Frame", "IgnorePainVengeance", ignorePainFrame)
vengeanceIgnorePainFrame:SetFrameStrata("BACKGROUND")
vengeanceIgnorePainFrame:SetWidth(15)
vengeanceIgnorePainFrame:SetHeight(15)
vengeanceIgnorePainFrame:SetPoint("TOP")
vengeanceIgnorePainFrame:SetPoint("LEFT", -15, 0)
vengeanceIgnorePainFrame:SetBackdrop({
    edgeFile = defaults.background,
    edgeSize = 3,
  })
vengeanceIgnorePainFrame:SetBackdropBorderColor(1, 0, 0)
vengeanceIgnorePainFrame.texture = vengeanceIgnorePainFrame:CreateTexture(nil, "BACKGROUND")
vengeanceIgnorePainFrame.texture:SetAllPoints()
vengeanceIgnorePainFrame:Hide()

-- Vengeance: Focused Rage
local vengeanceFocusedRageFrame = CreateFrame("Frame", "IgnorePainVengeance", ignorePainFrame)
vengeanceFocusedRageFrame:SetFrameStrata("BACKGROUND")
vengeanceFocusedRageFrame:SetWidth(15)
vengeanceFocusedRageFrame:SetHeight(15)
vengeanceFocusedRageFrame:SetPoint("BOTTOM")
vengeanceFocusedRageFrame:SetPoint("LEFT", -15, 0)
vengeanceFocusedRageFrame:SetBackdrop({
    edgeFile = defaults.background,
    edgeSize = 3,
  })
vengeanceFocusedRageFrame:SetBackdropBorderColor(1, 1, 0)
vengeanceFocusedRageFrame.texture = vengeanceFocusedRageFrame:CreateTexture(nil, "BACKGROUND")
vengeanceFocusedRageFrame.texture:SetAllPoints()
vengeanceFocusedRageFrame:Hide()

-- Frame for Shield Block
local shieldBlockFrame = CreateFrame("Frame", nil, baseFrame)
shieldBlockFrame:SetFrameStrata("BACKGROUND")
shieldBlockFrame:SetWidth(48)
shieldBlockFrame:SetHeight(48)
shieldBlockFrame:SetPoint("RIGHT")
shieldBlockFrame:SetBackdrop({
    edgeFile = defaults.background,
    edgeSize = 3,
  })
shieldBlockFrame:SetBackdropBorderColor(1, 0, 0)
shieldBlockFrame.texture = shieldBlockFrame:CreateTexture(nil, "BACKGROUND")
shieldBlockFrame.texture:SetTexture("Interface\\ICONS\\Ability_Defend.blp")
shieldBlockFrame.texture:SetAllPoints()

-- Timer for Shield Block
local shieldBlockTime = shieldBlockFrame:CreateFontString(nil, "OVERLAY")
shieldBlockTime:SetPoint("CENTER", 0, 0)
shieldBlockTime:SetTextColor(1, 1, 1)
shieldBlockTime:SetFont(defaults.font, defaults.fontSizeLarge, "OUTLINE")
shieldBlockFrame.text = shieldBlockTime

local function format(time)
  local result
  if time >= 1000000 then
    result = string.format("%.1f m", time / 1000000)
  elseif time >= 1000 then
    result = string.format("%d k", math.floor(time / 1000))
  else result = time
  end
  return result
end

local function updateColor(frame, time, upper, lower)
  if time > upper then
    frame:SetBackdropBorderColor(0, 1, 0)
  elseif time <= upper and time >= lower then
    frame:SetBackdropBorderColor(1, 0.5, 0)
  else
    frame:SetBackdropBorderColor(1, 0, 0)
  end
end

local function resetFrame(frame, ...)
  frame:SetBackdropBorderColor(1, 0, 0)
  local arg = {...}
  for k, v in ipairs(arg) do
    v:SetText("")
  end
end

local expires, absorb = 0, 0
local name = nil
local ignorePainActive, shieldBlockActive = false, false
local timeLeftIgnorePain, timeLeftShieldBlock = 0, 0
local ignorePain = 0

local showVengeanceIgnorePain = function()
  vengeanceFocusedRageFrame:Show()
end

local hideVengeanceIgnorePain = function()
  vengeanceFocusedRageFrame:Hide()
end

local showVengeanceFocusedRage = function()
  vengeanceIgnorePainFrame:Show()
end

local hideVengeanceFocusedRage = function()
  vengeanceIgnorePainFrame:Hide()
end

local showDragonScales = function()
  dragonScalesFrame:Show()
end

local hideDragonScales = function()
  dragonScalesFrame:Hide()
end

local showShieldBlock = function()
  timeLeft = math.floor(expires - GetTime())
  if timeLeft > timeLeftShieldBlock then
    timeLeftShieldBlock = timeLeft
  end
end

local hideShieldBlock = function()
  resetFrame(shieldBlockFrame, shieldBlockTime)
  timeLeftShieldBlock = 0
end

local showIgnorePain = function()
  ignorePain = absorb
  timeLeft = math.floor(expires - GetTime())
  if timeLeft > timeLeftIgnorePain then
    timeLeftIgnorePain = timeLeft
  end
end

local hideIgnorePain = function()
  resetFrame(ignorePainFrame, ignorePainTime, ignorePainAmount)
  timeLeftIgnorePain = 0
end

local spells = {
  ["Vengeance: Ignore Pain"] = {
    show = showVengeanceIgnorePain,
    hide = hideVengeanceIgnorePain,
    active = false
  },
  ["Vengeance: Focused Rage"] = {
    show = showVengeanceFocusedRage,
    hide = hideVengeanceFocusedRage,
    active = false
  },
  ["Dragon Scales"] = {
    show = showDragonScales,
    hide = hideDragonScales,
    active = false
  },
  ["Ignore Pain"] = {
    show = showIgnorePain,
    hide = hideIgnorePain,
    active = false
  },
  ["Shield Block"] = {
    show = showShieldBlock,
    hide = hideShieldBlock,
    active = false
  },
}

local function eventHandler(self, event, ...)
  for spell, action in pairs(spells) do
    name, _, _, _, _, _, expires, _, _, _, _, _, _, _, _, _, absorb, _, _ = UnitAura("player", spell)
    if name then
      action.active = true
      action.show()
    end

    if not name and action.active then
      action.active = false
      action.hide()
    end
  end
end

-- TODO: Refactor, use AceTimer?
function baseFrame:onUpdate(elapsed)
  -- Ignore Pain
  if timeLeftIgnorePain > 0 then
    self.elapsedIgnorePain = (self.elapsedIgnorePain or 0) + elapsed;
    if (self.elapsedIgnorePain >= 0.1) then
      updateColor(ignorePainFrame, timeLeftIgnorePain, 10, 5)
      ignorePainAmount:SetText(format(ignorePain))
      ignorePainTime:SetText(string.format("%.1f", timeLeftIgnorePain))
      timeLeftIgnorePain = timeLeftIgnorePain - 0.1
      self.elapsedIgnorePain = 0
    end
  end

  -- Shield Block
  if timeLeftShieldBlock > 0 then
    self.elapsedShieldBlock = (self.elapsedShieldBlock or 0) + elapsed;
    if (self.elapsedShieldBlock >= 0.1) then
      updateColor(shieldBlockFrame, timeLeftShieldBlock, 4, 2)
      shieldBlockTime:SetText(string.format("%.1f", timeLeftShieldBlock))
      timeLeftShieldBlock = timeLeftShieldBlock - 0.1
      self.elapsedShieldBlock = 0
    end
  end
end

baseFrame:RegisterEvent("UNIT_AURA")
baseFrame:SetScript("OnEvent", eventHandler)
baseFrame:SetScript("OnUpdate", baseFrame.onUpdate)
RegisterStateDriver(baseFrame, "visibility", "[petbattle] [vehicleui] hide; show")

baseFrame:SetPoint("CENTER", defaults.positionX, defaults.positionY)
baseFrame:Show()
