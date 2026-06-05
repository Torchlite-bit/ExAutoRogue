ExAutoRogue = {
    ver = "1.7 UI",
    Loaded = false,
    RiposteExpiry = 0,
}

-- ============================================================
-- Database Initialization (SavedVariables)
-- ============================================================
local dbFrame = CreateFrame("Frame")
dbFrame:RegisterEvent("ADDON_LOADED")
dbFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "ExAutoRogue" then
        -- Create default database if it's the user's first time loading
        if not ExAutoRogueDB then
            ExAutoRogueDB = {
                useSnd = true,
                useCDs = false,
                smartCDs = false,
                evisCP = 4,
            }
        end
        
        -- Update the GUI visual states to match the saved database
        if ExAutoRogueSndCheck then
            ExAutoRogueSndCheck:SetChecked(ExAutoRogueDB.useSnd)
            ExAutoRogueCDCheck:SetChecked(ExAutoRogueDB.useCDs)
            ExAutoRogueSmartCDCheck:SetChecked(ExAutoRogueDB.smartCDs)
            ExAutoRogueEvisSlider:SetValue(ExAutoRogueDB.evisCP)
        end
        
        if not ExAutoRogue.Loaded then
            DEFAULT_CHAT_FRAME:AddMessage("ExAutoRogue v" .. ExAutoRogue.ver .. " loaded. Type /autorogue ui for options.", 1, 0.8, 0.0)
            ExAutoRogue.Loaded = true
        end
    end
end)

-- ============================================================
-- Combat Log Listener (Riposte)
-- ============================================================
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
f:SetScript("OnEvent", function()
    if event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
        if arg1 and string.find(string.lower(arg1), "parry") then
            ExAutoRogue.RiposteExpiry = GetTime() + 5.5
        end
    end
end)

-- ============================================================
-- Core Helper Functions
-- ============================================================
function ExAutoRogue:KnowsSpell(spellName)
    local i = 1
    while true do
        local name = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name == spellName then return true end
        i = i + 1
    end
    return false
end

function ExAutoRogue:Cast(spellName)
    if self:KnowsSpell(spellName) then
        CastSpellByName(spellName)
        return true
    end
    return false
end

function ExAutoRogue:HasBuff(texture)
    for i = 1, 16 do
        local b = UnitBuff("player", i)
        if b and string.find(string.lower(b), string.lower(texture)) then
            return true
        end
    end
    return false
end

function ExAutoRogue:GetDebuffStacks(textureName)
    for i = 1, 16 do 
        local d, stacks = UnitDebuff("target", i)
        if d and string.find(string.lower(d), string.lower(textureName)) then 
            return stacks or 1 
        end 
    end
    return 0
end

function ExAutoRogue:EnsureAutoAttack()
    for z = 1, 172 do
        if IsAttackAction(z) then
            if not IsCurrentAction(z) then UseAction(z) end
            return
        end
    end
end

-- ============================================================
-- Rotation Logic Engine
-- ============================================================
function ExAutoRogue:EvalCommand()
    -- Secure a target
    if not UnitExists("target") or UnitIsDead("target") then
        TargetNearestEnemy()
    end
    if not UnitCanAttack("player", "target") then return end

    -- Force auto-attack (skipped when SCRM handles it via /startattack)
    if not IsAddOnLoaded("SuperCleveRoidMacros") then
        self:EnsureAutoAttack()
    end

    -- Pull preferences directly from the GUI Database
    local cpEvis = ExAutoRogueDB.evisCP or 4
    local popCDs = ExAutoRogueDB.useCDs
    local useSnd = self:KnowsSpell("Slice and Dice") and ExAutoRogueDB.useSnd
    local useEnvenom = self:KnowsSpell("Envenom")

    -- Builder follows the spec automatically
    local builder = "Sinister Strike"
    if self:KnowsSpell("Noxious Assault") then builder = "Noxious Assault" end

    -- Cooldown Management (Smart Boss Checking)
    if ExAutoRogueDB.smartCDs then
        local cls = UnitClassification("target")
        if (cls == "worldboss" or cls == "elite" or cls == "rareelite") then
            popCDs = true
        else
            popCDs = false -- Override manual CD pop if Smart CDs is checked but target is normal
        end
    end
    
    if popCDs then
        self:Cast("Adrenaline Rush")
        self:Cast("Blade Flurry")
    end

    local cp = GetComboPoints("player", "target")
    local now = GetTime()

    -- PRIORITIES
    -- P1: Riposte
    if now < self.RiposteExpiry and self:KnowsSpell("Riposte") then
        CastSpellByName("Riposte")
        UIErrorsFrame:Clear()
        return
    end

    -- P2: No combo points -> Builder
    if cp == 0 then
        self:Cast(builder)
        UIErrorsFrame:Clear()
        return
    end

    -- P3: Slice and Dice gone -> refresh
    if useSnd and not self:HasBuff("SliceDice") then
        self:Cast("Slice and Dice")
        UIErrorsFrame:Clear()
        return
    end

    -- P4: Envenom gone -> refresh (Requires Deadly Poison)
    local dpStacks = self:GetDebuffStacks("ability_rogue_dualweild")
    if useEnvenom and not self:HasBuff("Sword_31") and dpStacks > 0 then
        self:Cast("Envenom")
        UIErrorsFrame:Clear()
        return
    end

    -- P5: Buffs healthy, enough CP -> Eviscerate
    if cp >= cpEvis then
        self:Cast("Eviscerate")
        UIErrorsFrame:Clear()
        return
    end

    -- P6: Otherwise build
    self:Cast(builder)
    UIErrorsFrame:Clear()
end

-- ============================================================
-- GUI Panel Construction (Pure Lua)
-- ============================================================
local UIFrame = CreateFrame("Frame", "ExAutoRogueUI", UIParent)
UIFrame:SetWidth(300)
UIFrame:SetHeight(350)
UIFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
UIFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
UIFrame:SetMovable(true)
UIFrame:EnableMouse(true)
UIFrame:RegisterForDrag("LeftButton")
UIFrame:SetScript("OnDragStart", function() UIFrame:StartMoving() end)
UIFrame:SetScript("OnDragStop", function() UIFrame:StopMovingOrSizing() end)
UIFrame:Hide()

-- Title
local titleStr = UIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleStr:SetPoint("TOP", UIFrame, "TOP", 0, -15)
titleStr:SetText("ExAutoRogue Setup")

-- Close Button
local closeBtn = CreateFrame("Button", nil, UIFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", UIFrame, "TOPRIGHT", -5, -5)

-- Category Header
local spellsHeader = UIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
spellsHeader:SetPoint("TOPLEFT", UIFrame, "TOPLEFT", 20, -50)
spellsHeader:SetText("Spells & Tactics")

-- Checkbox: Slice and Dice
local sndCheck = CreateFrame("CheckButton", "ExAutoRogueSndCheck", UIFrame, "UICheckButtonTemplate")
sndCheck:SetPoint("TOPLEFT", spellsHeader, "BOTTOMLEFT", 0, -10)
_G[sndCheck:GetName().."Text"]:SetText("Maintain Slice and Dice")
sndCheck:SetScript("OnClick", function() ExAutoRogueDB.useSnd = (sndCheck:GetChecked() ~= nil) end)

-- Checkbox: Pop CDs
local cdCheck = CreateFrame("CheckButton", "ExAutoRogueCDCheck", UIFrame, "UICheckButtonTemplate")
cdCheck:SetPoint("TOPLEFT", sndCheck, "BOTTOMLEFT", 0, -5)
_G[cdCheck:GetName().."Text"]:SetText("Use Major Cooldowns")
cdCheck:SetScript("OnClick", function() ExAutoRogueDB.useCDs = (cdCheck:GetChecked() ~= nil) end)

-- Checkbox: Smart CDs
local smartCdCheck = CreateFrame("CheckButton", "ExAutoRogueSmartCDCheck", UIFrame, "UICheckButtonTemplate")
smartCdCheck:SetPoint("TOPLEFT", cdCheck, "BOTTOMLEFT", 20, 0) -- Indented slightly
_G[smartCdCheck:GetName().."Text"]:SetText("Smart CDs (Elites/Bosses Only)")
smartCdCheck:SetScript("OnClick", function() ExAutoRogueDB.smartCDs = (smartCdCheck:GetChecked() ~= nil) end)

-- Category Header: Combo Points
local cpHeader = UIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cpHeader:SetPoint("TOPLEFT", smartCdCheck, "BOTTOMLEFT", -20, -20)
cpHeader:SetText("Combo Point Management")

-- Slider: Eviscerate Threshold
local evisSlider = CreateFrame("Slider", "ExAutoRogueEvisSlider", UIFrame, "OptionsSliderTemplate")
evisSlider:SetPoint("TOPLEFT", cpHeader, "BOTTOMLEFT", 10, -20)
evisSlider:SetMinMaxValues(1, 5)
evisSlider:SetValueStep(1)
_G[evisSlider:GetName().."Text"]:SetText("Eviscerate CP Threshold")
_G[evisSlider:GetName().."Low"]:SetText("1")
_G[evisSlider:GetName().."High"]:SetText("5")

local evisValText = evisSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
evisValText:SetPoint("TOP", evisSlider, "BOTTOM", 0, 3)

evisSlider:SetScript("OnValueChanged", function()
    local val = math.floor(evisSlider:GetValue())
    evisValText:SetText(val .. " CP")
    ExAutoRogueDB.evisCP = val
end)

-- ============================================================
-- Slash Command Handler
-- ============================================================
SLASH_EXAUTOROGUE1 = "/AutoRogue"
SlashCmdList["EXAUTOROGUE"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "ui" then
        if UIFrame:IsVisible() then UIFrame:Hide() else UIFrame:Show() end
    else
        ExAutoRogue:EvalCommand()
    end
end
