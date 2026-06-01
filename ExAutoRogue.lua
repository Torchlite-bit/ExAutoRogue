ExAutoRogue = {
    ver = "1.6",
    Loaded = false,
    RiposteExpiry = 0,
}

-- Register slash command globally
SLASH_EXAUTOROGUE1 = "/AutoRogue"
SlashCmdList["EXAUTOROGUE"] = function(msg) ExAutoRogue:EvalCommand(msg) end

-- Combat log listener for Riposte (stays inert while Riposte is not learned)
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
f:SetScript("OnEvent", function()
    if event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
        if arg1 and string.find(string.lower(arg1), "parry") then
            ExAutoRogue.RiposteExpiry = GetTime() + 5.5
        end
    end
end)

function ExAutoRogue:OnLoad()
    local _, class = UnitClass("player")
    if class ~= "ROGUE" then return end
    
    if not self.Loaded then
        DEFAULT_CHAT_FRAME:AddMessage("ExAutoRogue v" .. self.ver .. " loaded (Assassination, auto-spellbook).", 1, 0.8, 0.0)
        self.Loaded = true
    end
end

-- Checks whether a spell sits in the spellbook. Covers level and talent availability.
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

-- Only casts what the character actually knows
function ExAutoRogue:Cast(spellName)
    if self:KnowsSpell(spellName) then
        CastSpellByName(spellName)
        return true
    end
    return false
end

-- Buff detection via the texture path
function ExAutoRogue:HasBuff(texture)
    for i = 1, 16 do
        local b = UnitBuff("player", i)
        if b and string.find(string.lower(b), string.lower(texture)) then
            return true
        end
    end
    return false
end

-- Function to check for debuff stacks on the target by texture name
function ExAutoRogue:GetDebuffStacks(textureName)
    for i = 1, 16 do 
        local d, stacks = UnitDebuff("target", i)
        if d and string.find(string.lower(d), string.lower(textureName)) then 
            return stacks or 1 
        end 
    end
    return 0
end

-- Ensures auto-attack is on without toggling it off on spam.
-- Scans every action slot (1-172, all bars) for the Attack action.
function ExAutoRogue:EnsureAutoAttack()
    for z = 1, 172 do
        if IsAttackAction(z) then
            if not IsCurrentAction(z) then UseAction(z) end
            return
        end
    end
end

function ExAutoRogue:EvalCommand(msg)
    msg = string.lower(msg or "")

    -- Options from the macro text
    local cpEvis = 4
    if string.find(msg, "evis5") then cpEvis = 5 end
    if string.find(msg, "evis4") then cpEvis = 4 end
    local popCDs = false
    if string.find(msg, "cds") then popCDs = true end

    -- Builder follows the spec automatically
    local builder = "Sinister Strike"
    if self:KnowsSpell("Noxious Assault") then builder = "Noxious Assault" end

    -- Finisher availability
    local useSnd = self:KnowsSpell("Slice and Dice") and not string.find(msg, "nosnd")
    local useEnvenom = self:KnowsSpell("Envenom")

    -- Secure a target
    if not UnitExists("target") or UnitIsDead("target") then
        TargetNearestEnemy()
    end
    if not UnitCanAttack("player", "target") then return end

    -- Force auto-attack (skipped when SCRM handles it via /startattack)
    if not IsAddOnLoaded("SuperCleveRoidMacros") then
        self:EnsureAutoAttack()
    end

    -- Cooldowns
    local cls = UnitClassification("target")
    local isElite = (cls == "worldboss" or cls == "elite" or cls == "rareelite")
    if string.find(msg, "autocd") and isElite then popCDs = true end
    if popCDs then
        self:Cast("Adrenaline Rush")
        self:Cast("Blade Flurry")
    end

    local cp = GetComboPoints("player", "target")
    local now = GetTime()

    -- ============================================================
    -- PRIORITIES
    -- ============================================================

    -- P1 Riposte. Combo-point independent, only inside the parry window and only if learned.
    if now < self.RiposteExpiry and self:KnowsSpell("Riposte") then
        CastSpellByName("Riposte")
        UIErrorsFrame:Clear()
        return
    end

    -- P2 No combo points -> builder, prevents an empty finisher
    if cp == 0 then
        self:Cast(builder)
        UIErrorsFrame:Clear()
        return
    end

    -- P3 Slice and Dice gone -> refresh with current CP
    if useSnd and not self:HasBuff("SliceDice") then
        self:Cast("Slice and Dice")
        UIErrorsFrame:Clear()
        return
    end

    -- P4 Envenom gone -> refresh with current CP (Requires Deadly Poison active)
    local dpStacks = self:GetDebuffStacks("ability_rogue_dualweild")
    if useEnvenom and not self:HasBuff("Sword_31") and dpStacks > 0 then
        self:Cast("Envenom")
        UIErrorsFrame:Clear()
        return
    end

    -- P5 Buffs healthy, enough CP -> Eviscerate
    if cp >= cpEvis then
        self:Cast("Eviscerate")
        UIErrorsFrame:Clear()
        return
    end

    -- P6 Otherwise build
    self:Cast(builder)
    UIErrorsFrame:Clear()
end

-- Fire the loader
ExAutoRogue:OnLoad()
