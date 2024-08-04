local UI = nil

function showBossSlot()
    UI = g_ui.loadUI("boss_slots", contentContainer)
    UI:show()
    g_game.requestBossSlootInfo()
end



local CATEGORY = {
    BANE = 0,
    NEMESIS = 2,
    ARCHFOE = 1
}

local SLOT_STATE = {
    EMPTY = 1,
    LOCKED = 0,
    ACTIVE = 2
}

local ICONS = {
    [CATEGORY.BANE] = "/game_cyclopedia/images/boss/icon_bane",
    [CATEGORY.ARCHFOE] = "/game_cyclopedia/images/boss/icon_archfoe",
    [CATEGORY.NEMESIS] = "/game_cyclopedia/images/boss/icon_nemesis"
}

local SLOTS = {
    [1] = "LeftBase",
    [2] = "RightBase"
}

local CONFIG = {
    [0] = {
        EXPERTISE = 100,
        PROWESS = 25,
        MASTERY = 300
    },
    {
        EXPERTISE = 20,
        PROWESS = 5,
        MASTERY = 60
    },
    {
        EXPERTISE = 3,
        PROWESS = 1,
        MASTERY = 5
    }
}

Cyclopedia.BossSlots = {}

-- Cyclopedia.loadBossSlots(data, slots, unlockedBosses)

--[[ { 
    ["playerPoints"] = 0,
    ["totalPointsNextBonus"] = 10,
    ["currentBonus"] = 25,
    ["nextBonus"] = 26,
    ["isSlotOneUnlocked"] = false,
    ["bossIdSlotOne"] = 0,
    ["isSlotTwoUnlocked"] = false,
    ["bossIdSlotTwo"] = 1500,
    ["isTodaySlotUnlocked"] = true,
    ["boostedBossId"] = 1574,
    ["bossesUnlockedData"] = { 

    },
    ["todaySlotData"] = { 
        ["inactive"] = 0,
        ["bossRace"] = 1,
        ["killCount"] = 0,
        ["killBonus"] = 4,
        ["bossRaceRepeat"] = 1,
        ["removePrice"] = 0,
        ["lootBonus"] = 250
    },
    ["bossesUnlocked"] = false
}
 ]]

function Cyclopedia.loadBossSlots(data)
    if not UI then
        return
    end

    Cyclopedia.BossSlots.UnlockBosses = {}
    local raceData = RACE_Bosstiary[data.boostedBossId]

    UI.Sprite:setOutfit({
        type = safeOutfit(raceData.type)
    })

    UI.Sprite:getCreature():setStaticWalking(1000)
    UI.TopBase.InfoLabel:setText(string.format("Equipment Loot Bonus: %d%% Next: %d%%", data.currentBonus,
        data.nextBonus))

    local fullText = ""
    if data.playerPoints >= CONFIG[data.bossIdSlotOne].MASTERY then
        fullText = "(fully unlocked)"
    end

    local progress = UI.BoostedProgress
    progress.ProgressBorder1:setTooltip(string.format(" %d / %d %s", data.playerPoints,
        CONFIG[data.bossIdSlotOne].PROWESS, fullText))
    progress.ProgressBorder2:setTooltip(string.format(" %d / %d %s", data.playerPoints,
        CONFIG[data.bossIdSlotOne].EXPERTISE, fullText))
    progress.ProgressBorder3:setTooltip(string.format(" %d / %d %s", data.playerPoints,
        CONFIG[data.bossIdSlotOne].MASTERY, fullText))

    if data.playerPoints >= CONFIG[data.bossIdSlotOne].PROWESS then
        progress.bronzeStar:setImageSource("/game_cyclopedia/images/boss/icon_star_bronze")
    else
        progress.bronzeStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
    end

    if data.playerPoints >= CONFIG[data.bossIdSlotOne].EXPERTISE then
        progress.silverStar:setImageSource("/game_cyclopedia/images/boss/icon_star_silver")
    else
        progress.silverStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
    end

    if data.playerPoints >= CONFIG[data.bossIdSlotOne].MASTERY then
        progress.goldStar:setImageSource("/game_cyclopedia/images/boss/icon_star_gold")
    else
        progress.goldStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
    end

    for i = 0, #data.bossesUnlockedData do
        local unlockData = data.bossesUnlockedData[i]
        if not unlockData then
            return
        end

        local raceData = RACE_Bosstiary[unlockData.bossId]
        if raceData then
            local data_t = {
                visible = true,
                bossId = unlockData.bossId,
                category = unlockData.category,
                name = raceData.name
            }

            table.insert(Cyclopedia.BossSlots.UnlockBosses, data_t)
        end
    end

    table.sort(Cyclopedia.BossSlots.UnlockBosses, function(a, b)
        return a.name < b.name
    end)

    UI.MainLabel:setText(string.format("Equipment loot bonus: %d%%\nKill bonus: %dx", data.boostedBonusValue,
        data.boostedKillValue))
    Cyclopedia.setBosstiarySlotsProgress(data.bossPoints, data.nextBossPoints)

    local function format(string)
        if #string > 18 then
            return string:sub(1, 15) .. "..."
        else
            return string
        end
    end

    UI.MidTitle:setText(string.format("Boosted Boss: %s", format(RACE_Bosstiary[data.boostedBossId].name)))
    Cyclopedia.setBosstiarySlotsBossProgress(UI.BoostedProgress, data.boostedKills, CONFIG[data.boostedCategory].MASTERY)
    UI.TypeIcon:setImageSource(ICONS[data.boostedCategory])

    local tooltip =
        "Bane\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 5\nExpertise: 15\nMastery: 30"

    tooltip = data.boostedCategory == CATEGORY.ARCHFOE and
                  "Archfoe\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60" or
                  "Nemesis\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60"

    UI.TypeIcon:setTooltip(tooltip)
    -- UI.TypeIcon:setTooltipAlign(AlignTopLeft)
    local unlockedBosses = data.bossIdSlotTwo
    for slotId, slotData in ipairs(data.todaySlotData) do
        Cyclopedia.BossSlotChangeSlot(slotId, slotData, unlockedBosses)
    end
end

function Cyclopedia.BossSlotChangeSlot(slot, data, unlockedBosses)
    local widget = UI[SLOTS[slot]]
    if data.state == SLOT_STATE.LOCKED then
        widget.LockLabel:setVisible(true)
        widget.SelectBoss:setVisible(false)
        widget.ActivedBoss:setVisible(false)
        widget:setText(string.format("Slot %d: Locked", slot))
        widget.LockLabel:setText(string.format("Unlocks at %d Boss Points", data.bossIdSlotTwo))
    elseif data.state == SLOT_STATE.EMPTY then
        widget.LockLabel:setVisible(false)
        widget.SelectBoss:setVisible(true)
        widget.ActivedBoss:setVisible(false)
        widget:setText(string.format("Slot %d: Select Boss", slot))
        widget.SelectBoss.ListBase.List:destroyChildren()

        local function format(string)
            if #string > 12 then
                return string:sub(1, 9) .. "..."
            else
                return string
            end
        end

        for _, internalData in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
            local internalWidget = g_ui.createWidget("SelectBossBossSlots", widget.SelectBoss.ListBase.List)
            internalWidget:setId(internalData.bossId)
            internalWidget.Sprite:setOutfit(RACE_Bosstiary[internalData.bossId].outfit)
            internalWidget:setText(format(RACE_Bosstiary[internalData.bossId].name))
            internalWidget.Sprite:setAnimate(true)
            internalWidget.TypeIcon:setImageSource(ICONS[internalData.category])

            local tooltip =
                "Bane\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 5\nExpertise: 15\nMastery: 30"

            tooltip = internalData.category == CATEGORY.ARCHFOE and
                          "Archfoe\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60" or
                          "Nemesis\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60"

            internalWidget.TypeIcon:setTooltip(tooltip)
            -- internalWidget.TypeIcon:setTooltipAlign(AlignTopLeft)
        end

        widget.SelectBoss.SelectButton:setEnabled(false)

        function widget.SelectBoss.SelectButton.onClick()
            g_game.requestBossSlotAction(slot, Cyclopedia.BossSlots.lastSelected:getId())
        end
    elseif data.state == SLOT_STATE.ACTIVE then
        widget.LockLabel:setVisible(false)
        widget.SelectBoss:setVisible(false)
        widget.ActivedBoss:setVisible(true)
        widget:setText(string.format("Slot %d: %s", slot, RACE_Bosstiary[data.bossId].name))
        widget.ActivedBoss.TypeIcon:setImageSource(ICONS[data.category])
        Cyclopedia.setBosstiarySlotsBossProgress(widget.ActivedBoss.Progress, data.kills, CONFIG[data.category].MASTERY)

        local tooltip =
            "Bane\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 5\nExpertise: 15\nMastery: 30"

        tooltip = data.category == CATEGORY.ARCHFOE and
                      "Archfoe\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60" or
                      "Nemesis\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60"

        widget.ActivedBoss.TypeIcon:setTooltip(tooltip)
        -- widget.ActivedBoss.TypeIcon:setTooltipAlign(AlignTopLeft)
        widget.ActivedBoss.Progress.ProgressBorder1:setTooltip()

        local fullText = ""
        if data.kills >= CONFIG[data.category].MASTERY then
            fullText = "(fully unlocked)"
        end

        local progress = widget.ActivedBoss.Progress
        progress.ProgressBorder1:setTooltip(string.format(" %d / %d %s", data.kills, CONFIG[data.category].PROWESS,
            fullText))
        progress.ProgressBorder2:setTooltip(string.format(" %d / %d %s", data.kills, CONFIG[data.category].EXPERTISE,
            fullText))
        progress.ProgressBorder3:setTooltip(string.format(" %d / %d %s", data.kills, CONFIG[data.category].MASTERY,
            fullText))

        if data.kills >= CONFIG[data.category].PROWESS then
            progress.bronzeStar:setImageSource("/game_cyclopedia/images/boss/icon_star_bronze")
        else
            progress.bronzeStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
        end

        if data.kills >= CONFIG[data.category].EXPERTISE then
            progress.silverStar:setImageSource("/game_cyclopedia/images/boss/icon_star_silver")
        else
            progress.silverStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
        end

        if data.kills >= CONFIG[data.category].MASTERY then
            progress.goldStar:setImageSource("/game_cyclopedia/images/boss/icon_star_gold")
        else
            progress.goldStar:setImageSource("/game_cyclopedia/images/boss/icon_star_dark")
        end

        widget.ActivedBoss.Sprite:setOutfit(RACE_Bosstiary[data.bossId].outfit)
        widget.ActivedBoss.Sprite:setAnimate(true)
        widget.ActivedBoss.EquipmentLabel:setText(string.format("Equipment loot bonus: %d%%", data.lootBonus))
        widget.ActivedBoss.Value:setText(comma_value(data.goldToRemove))

        if Cyclopedia.UI.Balance ~= nil then
            if data.goldToRemove > Cyclopedia.UI.Balance then
                widget.ActivedBoss.Value:setColor("#D33C3C")
                widget.ActivedBoss.RemoveButton:setEnabled(false)
            else
                widget.ActivedBoss.Value:setColor("#C0C0C0")
                widget.ActivedBoss.RemoveButton:setEnabled(true)
            end
        end

        function widget.ActivedBoss.RemoveButton.onClick()
            g_game.requestBossSlotAction(slot, 0)
        end

        widget.ActivedBoss.RemoveButton:setTooltip(string.format(
            "It will cost you %s gold to remove the currently selected boss from this slot.",
            comma_value(data.goldToRemove)))
    end
end

function Cyclopedia.setBosstiarySlotsProgress(value, maxValue)
    local rect = {
        height = 18,
        x = 0,
        y = 0,
        width = (maxValue < value and maxValue or value) / maxValue * 278
    }

    if value >= 0 and rect.width < 1 then
        rect.width = 1
    end

    UI.TopBase.PointsBar.fill:setImageRect(rect)
    UI.TopBase.PointsBar.Value:setText(string.format("%d/%d", value, maxValue))
end

function Cyclopedia.setBosstiarySlotsBossProgress(object, value, maxValue)
    local rect = {
        height = 12,
        x = 0,
        y = 0,
        width = (maxValue < value and maxValue or value) / maxValue * 126
    }

    if value >= 0 and rect.width < 1 then
        object.fill:setVisible(false)
    else
        object.fill:setVisible(true)
    end

    object.fill:setImageRect(rect)
    object.ProgressValue:setText(value)

    if maxValue <= value then
        object.fill:setImageSource("/game_cyclopedia/images/bestiary/fill_completed")
    else
        object.fill:setImageSource("/game_cyclopedia/images/bestiary/fill")
    end
end

function Cyclopedia.bossSlotSelectBoss(widget)
    local button = widget:getParent():getParent():getParent().SelectButton

    for i = 1, widget:getParent():getChildCount() do
        local child = widget:getParent():getChildByIndex(i)

        child:setChecked(false)
    end

    widget:setChecked(true)
    Cyclopedia.BossSlots.lastSelected = widget
    button:setEnabled(true)
end

function Cyclopedia.readjustSelectBoss()
    local slot = 1
    if not UI.LeftBase.SelectBoss:isVisible() then
        slot = 2
    end

    local icons = {
        [CATEGORY.BANE] = "/game_cyclopedia/images/boss/icon_bane",
        [CATEGORY.ARCHFOE] = "/game_cyclopedia/images/boss/icon_archfoe",
        [CATEGORY.NEMESIS] = "/game_cyclopedia/images/boss/icon_nemesis"
    }

    local function format(string)
        if #string > 12 then
            return string:sub(1, 9) .. "..."
        else
            return string
        end
    end

    local widget = UI[SLOTS[slot]]
    widget.SelectBoss.ListBase.List:destroyChildren()

    for _, internalData in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
        if internalData.visible then
            local internalWidget = g_ui.createWidget("SelectBossBossSlots", widget.SelectBoss.ListBase.List)

            internalWidget.Sprite:setOutfit(RACE_Bosstiary[internalData.bossId].outfit)
            internalWidget:setText(format(RACE_Bosstiary[internalData.bossId].name))
            internalWidget.Sprite:setAnimate(true)
            internalWidget.TypeIcon:setImageSource(icons[internalData.category])

            local tooltip =
                "Bane\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 5\nExpertise: 15\nMastery: 30"

            tooltip = internalData.category == CATEGORY.ARCHFOE and
                          "Archfoe\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60" or
                          "Nemesis\n\nFor unlocking a level, you will receive the following boss points:\nProwess: 10\nExpertise: 30\nMastery: 60"

            internalWidget.TypeIcon.TypeIcon:setTooltip(tooltip)
            -- internalWidget.TypeIcon.TypeIcon:setTooltipAlign(AlignTopLeft)
        end
    end

    widget.SelectBoss.SelectButton:setEnabled(false)
end

function Cyclopedia.SelectBossSearchText(text, clear, widget)
    if clear then
        widget:getParent().SearchEdit:setText("")
    end

    if text ~= "" then
        for _, creature in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
            if string.find(creature.name:lower(), text:lower()) == nil then
                creature.visible = false
            else
                creature.visible = true
            end
        end
    else
        for _, creature in ipairs(Cyclopedia.BossSlots.UnlockBosses) do
            creature.visible = true
        end
    end

    Cyclopedia.readjustSelectBoss()
end
