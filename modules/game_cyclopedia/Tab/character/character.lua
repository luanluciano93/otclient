---------//-- LuaFormatter on
--[[ SEND 
https://github.com/otland/forgottenserver/pull/4540/files
https://github.com/otland/forgottenserver/pull/4461
https://github.com/otland/forgottenserver/pull/4460
https://github.com/otland/forgottenserver/pull/4456/files
GET ]] 

local characterPanel = nil
local UI = nil
local function close(parent)
    if table.empty(parent.subCategories) then
        return
    end

    for subId, _ in ipairs(parent.subCategories) do
        local subWidget = parent:getChildById(subId)

        if subWidget then
            subWidget:setVisible(false)
        end
    end

    parent:setHeight(parent.closedSize)

    parent.opened = false

    parent.Button.Arrow:setVisible(true)
end

local function reset()
    characterPanel.InfoBase.inventoryPanel:setVisible(true)
    characterPanel.InfoBase.outfitPanel:setVisible(false)

    if characterPanel.InfoBase.CharacterButton.state ~= 1 then
        Cyclopedia.characterButton(characterPanel.InfoBase.CharacterButton)
    end

    Cyclopedia.selectCharacterPage()

    characterPanel.openedCategory = nil
end

local function open(parent)
    local oldOpen = UI.openedCategory

    for subId, _ in ipairs(parent.subCategories) do
        local subWidget = parent:getChildById(subId)

        if subWidget then
            if tonumber(subWidget:getId()) == 1 then
                subWidget.Button.onClick(subWidget)
            end

            subWidget:setVisible(true)
        end
    end

    if oldOpen ~= nil and oldOpen ~= parent then
        close(oldOpen)
    end

    parent:setHeight(parent.openedSize)

    parent.opened = true

    parent.Button.Arrow:setVisible(false)

    UI.openedCategory = parent
end

characterControllerCyclopedia = Controller:new()

function characterControllerCyclopedia:onInit()
    characterControllerCyclopedia:registerEvents(g_game, {
        onParseCyclopediaCharacterGeneralStats = Cyclopedia.loadCharacterGeneralStats,
        onParseCyclopediaCharacterCombatStats = Cyclopedia.loadCharacterCombatStats,
        onParseCyclopediaCharacterBadges = Cyclopedia.loadCharacterBadges,
        onCyclopediaCharacterRecentDeaths = Cyclopedia.onCyclopediaCharacterRecentDeaths,
        onCyclopediaCharacterRecentKills = Cyclopedia.onCyclopediaCharacterRecentKills,
        onCyclopediaCharacterItems = Cyclopedia.onCyclopediaCharacterItems,
        onCyclopediaCharacterAppearances = Cyclopedia.onCyclopediaCharacterAppearances
    })
end

function characterControllerCyclopedia:onGameStart()

end

function characterControllerCyclopedia:onGameEnd()

end

function characterControllerCyclopedia:onTerminate()

end

function showCharacter()
    characterPanel = g_ui.loadUI("character", contentContainer)
    UI = characterPanel
    characterPanel:show()
    UI.selectedOption = "InfoBase"
    if g_game.isOnline() then
        local player = g_game.getLocalPlayer()
        UI.CharacterBase:setText(player:getName())
        UI.CharacterBase.InfoLabel:setText(string.format("Level: %d\n%s", player:getLevel(), player:getVocation()))
        UI.CharacterBase.Outfit:setOutfit(player:getOutfit())
        UI.CharacterBase.Outfit:getCreature():setStaticWalking(1000)
        UI.InfoBase.outfitPanel.Sprite:setOutfit(player:getOutfit())
        UI.InfoBase.outfitPanel.Sprite:getCreature():setStaticWalking(1000)
        UI.InfoBase.InspectLabel:setText(tr("You are inspecting") .. ": " .. player:getName())

        for i = InventorySlotFirst, InventorySlotPurse do
            local item = player:getInventoryItem(i)
            local itemWidget = UI.InfoBase.inventoryPanel["slot" .. i]

            if itemWidget then
                if item then
                    itemWidget:setStyle("InventoryItem")
                    itemWidget:setItem(item)
                    itemWidget:setIcon("")
                else
                    itemWidget:setStyle(Cyclopedia.InventorySlotStyles[i].name)
                    itemWidget:setIcon(Cyclopedia.InventorySlotStyles[i].icon)
                    itemWidget:setItem(nil)
                end
            end
        end

        if g_game.isOnline() then
            Cyclopedia.createCharacterDescription()
            Cyclopedia.configureCharacterCategories()
        end
    end

    reset()
end

--[[ 
Send = 	
   
Get:

]]

Cyclopedia.Character = {}
Cyclopedia.Character.Achievements = {}
Cyclopedia.InventorySlotStyles = {
    [InventorySlotHead] = {
        icon = "/images/game/slots/inventory-head",
        name = "HeadSlot"
    },
    [InventorySlotNeck] = {
        icon = "/images/game/slots/inventory-neck",
        name = "NeckSlot"
    },
    [InventorySlotBack] = {
        icon = "/images/game/slots/inventory-back",
        name = "BackSlot"
    },
    [InventorySlotBody] = {
        icon = "/images/game/slots/inventory-torso",
        name = "BodySlot"
    },
    [InventorySlotRight] = {
        icon = "/images/game/slots/inventory-right-hand",
        name = "RightSlot"
    },
    [InventorySlotLeft] = {
        icon = "/images/game/slots/inventory-left-hand",
        name = "LeftSlot"
    },
    [InventorySlotLeg] = {
        icon = "/images/game/slots/inventory-legs",
        name = "LegSlot"
    },
    [InventorySlotFeet] = {
        icon = "/images/game/slots/inventory-feet",
        name = "FeetSlot"
    },
    [InventorySlotFinger] = {
        icon = "/images/game/slots/inventory-finger",
        name = "FingerSlot"
    },
    [InventorySlotAmmo] = {
        icon = "/images/game/slots/inventory-hip",
        name = "AmmoSlot"
    }
}

function Cyclopedia.characterAppearancesFilter(widget)
    local parent = widget:getParent()
    for i = 1, parent:getChildCount() do
        local child = parent:getChildByIndex(i)
        if child:getId() ~= "show" then
            child:setChecked(false)
        end
    end

    widget:setChecked(true)

    for _, data in ipairs(Cyclopedia.Character.Appearances) do
        if data.type == widget:getId() then
            data.visible = true
        else
            data.visible = false
        end
    end

    Cyclopedia.reloadCharacterAppearances()
end

function Cyclopedia.reloadCharacterAppearances()
    UI.CharacterAppearances.ListBase.list:destroyChildren()

    for _, data in ipairs(Cyclopedia.Character.Appearances) do
        if data.visible then
            local widget = g_ui.createWidget("CharacterAppearance", UI.CharacterAppearances.ListBase.list)
            widget.name:setText(data.name)
            widget.creature:setOutfit(data.outfit)
            widget.creature:getCreature():setStaticWalking(1000)
        end
    end
end

function Cyclopedia.loadCharacterAppearances(color, outfits, mounts)
    local data = {}

    local function insert(value, type)
        local look = value.lookType

        if type == "mounts" then
            look = value.mountId
        end

        local data_t = {
            visible = false,
            name = value.name,
            type = type,
            outfit = {
                auxType = 0,
                type = look,
                head = color.head,
                body = color.body,
                legs = color.legs,
                feet = color.feet,
                addon = outfits.addons and outfits.addons or 0
            }
        }

        table.insert(data, data_t)
    end

    local function process(container, containerType)
        for i = 0, #container do
            local value = container[i]
            if value then
                insert(value, containerType)
            end
        end
    end

    process(outfits, "outfits")
    process(mounts, "mounts")

    Cyclopedia.Character.Appearances = data

    Cyclopedia.characterAppearancesFilter(UI.CharacterAppearances.listFilter.outfits)
end

function Cyclopedia.characterItemsSearch(text)
    local filter = UI.CharacterItems.filters
    local activeFilters = {}

    for i = 1, filter:getChildCount() do
        local child = filter:getChildByIndex(i)
        if child:isChecked() then
            table.insert(activeFilters, child:getId())
        end
    end

    for _, item in ipairs(Cyclopedia.Character.Items) do
        local data = item.data
        local name = data.name:lower()
        local meetsSearchCriteria = text == "" or string.find(name, text:lower()) ~= nil
        local meetsFilterCriteria = #activeFilters == 0 or table.contains(activeFilters, data.type)
        data.visible = meetsSearchCriteria and meetsFilterCriteria
    end

    Cyclopedia.reloadCharacterItems()
end

function Cyclopedia.characterItemsFilter(widget, force)
    if force then
        widget:setChecked(true)
    end

    local id = widget:getId()

    for _, item in ipairs(Cyclopedia.Character.Items) do
        local data = item.data
        if data.type == id then
            data.visible = widget:isChecked()
        end
    end

    Cyclopedia.reloadCharacterItems()
end

function Cyclopedia.reloadCharacterItems()
    UI.CharacterItems.ListBase.list:destroyChildren()
    UI.CharacterItems.gridBase.grid:destroyChildren()

    local colors = {"#484848", "#414141"}
    local colorIndex = 1

    for _, item in ipairs(Cyclopedia.Character.Items) do
        local itemId, data = item.itemId, item.data

        if data.visible then
            local listItem = g_ui.createWidget("CharacterListItem", UI.CharacterItems.ListBase.list)
            local frame = g_game.getItemFrame(data.value)

            listItem.item:setItemId(itemId)
            listItem.name:setText(data.name)
            listItem.amount:setText(data.amount)
            listItem:setBackgroundColor(colors[colorIndex])

            local gridItem = g_ui.createWidget("CharacterGridItem", UI.CharacterItems.gridBase.grid)

            gridItem.item:setItemId(itemId)
            gridItem.amount:setText(data.amount)

            if frame > 0 then
                listItem.rarity:setImageSource("/images/ui/frames")
                listItem.rarity:setImageClip(torect(g_game.getRectFrame(frame)))
                gridItem.rarity:setImageSource("/images/ui/frames")
                gridItem.rarity:setImageClip(torect(g_game.getRectFrame(frame)))
            else
                listItem.rarity:setImageSource("")
                gridItem.rarity:setImageSource("")
            end

            colorIndex = 3 - colorIndex
        end
    end
end

function Cyclopedia.loadCharacterItems(inventory, store, stash, depot, inbox)
    Cyclopedia.Character.Items = {}

    local function insert(data, type)
        if not data then
            return
        end

        local thing = g_things.getThingType(data.itemId, ThingCategoryItem)
        local name = thing:getMarketData().name:lower()

        name = name ~= "" and name or "?"

        local data_t = {
            visible = false,
            name = name,
            amount = data.amount,
            type = type,
            value = thing:getResultingValue()
        }

        local insertedItem = Cyclopedia.Character.Items[data.itemId]
        if insertedItem then
            insertedItem.amount = insertedItem.amount + data.amount
        else
            Cyclopedia.Character.Items[data.itemId] = data_t
        end
    end

    local function processContainer(container, containerType)
        for i = 0, #container do
            local data = container[i]
            if data then
                insert(data, containerType)
            end
        end
    end

    processContainer(inventory, "inventory")
    processContainer(store, "store")
    processContainer(stash, "stash")
    processContainer(depot, "depot")
    processContainer(inbox, "inbox")

    local sortedItems = {}

    for itemId, data in pairs(Cyclopedia.Character.Items) do
        table.insert(sortedItems, {
            itemId = itemId,
            data = data
        })
    end

    local function compareByName(a, b)
        local nameA = a.data.name:lower()
        local nameB = b.data.name:lower()

        if nameA ~= "?" and nameB == "?" then
            return true
        elseif nameA == "?" and nameB ~= "?" then
            return false
        else
            return nameA < nameB
        end
    end

    table.sort(sortedItems, compareByName)
    Cyclopedia.Character.Items = sortedItems
    Cyclopedia.characterItemsFilter(UI.CharacterItems.filters.inventory, true)
end

function Cyclopedia.loadCharacterAchievements()
    if not Cyclopedia.Character.Achievements.Loaded then
        UI.CharacterAchievements.sort:addOption("Alphabetically", 1, true)
        UI.CharacterAchievements.sort:addOption("By Grade", 2, true)
        UI.CharacterAchievements.sort:addOption("By Unlock Date", 3, true)
        Cyclopedia.achievementFilter(UI.CharacterAchievements.filters.accomplished)
        Cyclopedia.Character.Achievements.Loaded = true
    end
end

function Cyclopedia.characterItemListFilter(widget)
    local parent = widget:getParent()
    for i = 1, parent:getChildCount() do
        local child = parent:getChildByIndex(i)
        if child then
            child:setChecked(false)
        end
    end

    widget:setChecked(true)

    if widget:getId() == "list" then
        UI.CharacterItems.ListBase:setVisible(true)
        UI.CharacterItems.gridBase:setVisible(false)
    else
        UI.CharacterItems.ListBase:setVisible(false)
        UI.CharacterItems.gridBase:setVisible(true)
    end
end

function Cyclopedia.achievementFilter(widget)
    if widget:isChecked() then
        return
    end

    local parent = widget:getParent()
    for i = 1, parent:getChildCount() do
        local child = parent:getChildByIndex(i)
        if child then
            child:setChecked(false)
        end
    end

    if widget:getId() ~= "accomplished" then
        local last = Cyclopedia.Character.Achievements.lastSort
        last = last or 1
        Cyclopedia.achievementSort(last)
    else
        UI.CharacterAchievements.ListBase.List:destroyChildren()
    end

    widget:setChecked(not widget:isChecked())
end

function Cyclopedia.achievementSort(option)
    local tempTable = {}

    for id, data in pairs(ACHIEVEMENT) do
        local tempData = {
            id = id,
            name = data.name,
            description = data.description,
            grade = data.grade
        }

        table.insert(tempTable, tempData)
    end

    if option == 1 then
        table.sort(tempTable, function(a, b)
            return a.name < b.name
        end)
    elseif option == 2 then
        table.sort(tempTable, function(a, b)
            return a.grade > b.grade
        end)
    end

    UI.CharacterAchievements.ListBase.List:destroyChildren()

    for _, data in pairs(tempTable) do
        local widget = g_ui.createWidget("Achievement", UI.CharacterAchievements.ListBase.List)
        widget:setId(data.id)
        widget.title:setText(data.name)
        widget.title = data.name
        widget:setText(data.description)
        widget.icon:setWidth(11 * data.grade)
        widget.grade = data.grade
    end

    Cyclopedia.Character.Achievements.lastSort = option
end

function Cyclopedia.loadCharacterRecentKills(timeData, descriptionData, statusData)
    UI.RecentKills.ListBase.List:destroyChildren()

    if not table.empty(timeData) then
        local color = "#484848"

        for i = 0, #timeData do
            local time = timeData[i]
            local description = descriptionData[i]
            local status = statusData[i]
            local widget = g_ui.createWidget("CharacterKill", UI.RecentKills.ListBase.List)

            widget:setId(i)
            widget.date:setText(os.date("%Y-%m-%d, %H:%M:%S", time))
            widget.description:setText(description)
            widget.status:setText(status)

            widget.color = color

            widget:setBackgroundColor(color)

            color = color == "#484848" and "#414141" or "#484848"

            function widget:onClick()
                local parent = widget:getParent()
                for y = 1, parent:getChildCount() do
                    local child = parent:getChildByIndex(y)
                    child:setChecked(false)
                    child.date:setOn(false)
                    child.description:setOn(false)
                    child.status:setOn(false)
                end

                self:setChecked(not self:isChecked())
            end

            function widget:onCheckChange()
                if self:isChecked() then
                    self:setBackgroundColor("#585858")
                else
                    self:setBackgroundColor(self.color)
                end

                self.date:setOn(not self:isOn())
                self.description:setOn(not self:isOn())
                self.status:setOn(not self:isOn())
            end

            if i == 0 then
                widget:setChecked(true)
            end
        end
    end
end

function Cyclopedia.loadCharacterRecentDeaths(timeData, reasonData)
    UI.RecentDeaths.ListBase.List:destroyChildren()

    if not table.empty(timeData) then
        local color = "#484848"

        for i = 0, #timeData do
            local time = timeData[i]
            local reason = reasonData[i]
            local widget = g_ui.createWidget("CharacterDeath", UI.RecentDeaths.ListBase.List)

            widget:setId(i)
            widget.date:setText(os.date("%Y-%m-%d, %H:%M:%S", time))
            widget.cause:setText(reason)
            widget.color = color
            widget:setBackgroundColor(color)
            color = color == "#484848" and "#414141" or "#484848"

            function widget:onClick()
                local parent = widget:getParent()
                for y = 1, parent:getChildCount() do
                    local child = parent:getChildByIndex(y)

                    child:setChecked(false)
                    child.cause:setOn(false)
                    child.date:setOn(false)
                end

                self:setChecked(not self:isChecked())
            end

            function widget:onCheckChange()
                if self:isChecked() then
                    self:setBackgroundColor("#585858")
                else
                    self:setBackgroundColor(self.color)
                end

                self.cause:setOn(not self:isOn())
                self.date:setOn(not self:isOn())
            end

            if i == 0 then
                widget:setChecked(true)
            end
        end
    end
end

function Cyclopedia.loadCharacterCombatStats(data, mitigation, additionalSkillsArray, forgeSkillsArray, perfectShotDamageRanges, combatsArray, concoctionsArray)
    UI.CombatStats.attack.icon:setImageSource(Icons[data.weaponElement].icon)
    UI.CombatStats.attack.icon:setImageClip(Icons[data.weaponElement].clip)
    UI.CombatStats.attack.value:setText(data.weaponMaxHitChance)

    if data.weaponElementDamage > 0 then
        UI.CombatStats.converted.none:setVisible(false)
        UI.CombatStats.converted.value:setVisible(true)
        UI.CombatStats.converted.icon:setVisible(true)
        UI.CombatStats.converted.icon:setImageSource(Icons[data.weaponElementType].icon)
        UI.CombatStats.converted.icon:setImageClip(Icons[data.weaponElementType].clip)
        UI.CombatStats.converted.value:setText(data.weaponElementDamage .. "%")
    else
        UI.CombatStats.converted.none:setVisible(true)
        UI.CombatStats.converted.value:setVisible(false)
        UI.CombatStats.converted.icon:setVisible(false)
    end

    UI.CombatStats.defence.value:setText(data.defense)
    UI.CombatStats.armor.value:setText(data.armor)
    UI.CombatStats.mitigation.value:setText(string.format("%.2f%%", mitigation))
    UI.CombatStats.blessings.value:setText(string.format("%d/8", data.blessings))

    for i = 0, 6 do
        local id = "reduction_" .. i
        if UI.CombatStats[id] then
            UI.CombatStats[id]:destroy()
        end
    end

    if table.empty(combatsArray) then
        UI.CombatStats.reductionNone:setVisible(true)
    else
        UI.CombatStats.reductionNone:setVisible(false)

        for i = 0, #combatsArray do
            local widget = g_ui.createWidget("CharacterElementReduction", UI.CombatStats)

            widget:setId("reduction_" .. i)

            local element = Icons[combatsArray[i].type]
            widget.icon:setImageSource(element.icon)
            widget.icon:setImageClip(element.clip)
            widget.value:setText(string.format("+%d%%", combatsArray[i].value))
            widget.name:setText(element.name)

            if i == 0 then
                widget:addAnchor(AnchorTop, "reduction", AnchorBottom)
                widget:addAnchor(AnchorLeft, "parent", AnchorLeft)
                widget:addAnchor(AnchorRight, "separator", AnchorRight)
            else
                widget:addAnchor(AnchorTop, "prev", AnchorBottom)
                widget:addAnchor(AnchorLeft, "parent", AnchorLeft)
                widget:addAnchor(AnchorRight, "separator", AnchorRight)
            end

            widget:setMarginLeft(13)
        end
    end

    local skill = additionalSkillsArray[Skill.CriticalChance].level
    UI.CombatStats.criticalChance.value:setText(skill .. "%")
    if skill > 0 then
        UI.CombatStats.criticalChance.value:setColor("#44AD25")
    else
        UI.CombatStats.criticalChance.value:setColor("#C0C0C0")
    end

    skill = additionalSkillsArray[Skill.CriticalDamage].level
    UI.CombatStats.criticalDamage.value:setText(skill .. "%")
    if skill > 0 then
        UI.CombatStats.criticalDamage.value:setColor("#44AD25")
    else
        UI.CombatStats.criticalDamage.value:setColor("#C0C0C0")
    end

    skill = additionalSkillsArray[Skill.LifeLeechAmount].level
    if skill > 0 then
        UI.CombatStats.lifeLeech.value:setColor("#44AD25")
        UI.CombatStats.lifeLeech.value:setText(string.format("%.2f%%", skill / 100))
    else
        UI.CombatStats.lifeLeech.value:setColor("#C0C0C0")
        UI.CombatStats.lifeLeech.value:setText(string.format("%d%%", skill))
    end

    skill = additionalSkillsArray[Skill.ManaLeechAmount].level
    if skill > 0 then
        UI.CombatStats.manaLeech.value:setColor("#44AD25")
        UI.CombatStats.manaLeech.value:setText(string.format("%.2f%%", skill / 100))
    else
        UI.CombatStats.manaLeech.value:setColor("#C0C0C0")
        UI.CombatStats.manaLeech.value:setText(string.format("%d%%", skill))
    end

    for i = 0, #forgeSkillsArray do
        local id = "special_" .. i
        if UI.CombatStats[id] then
            UI.CombatStats[id]:destroy()
        end
    end

    local firstSpecial = true

    for i = 0, #forgeSkillsArray do
        local percent = forgeSkillsArray[i].value
        if percent > 0 then
            local widget = g_ui.createWidget("CharacterSkillBase", UI.CombatStats)

            widget:setId("special_" .. i)

            local specialName = {
                [0] = "Onslaught",
                "Ruse",
                "Momentum",
                "Transcendence"
            }

            if firstSpecial then
                widget:addAnchor(AnchorTop, "manaLeech", AnchorBottom)
                widget:addAnchor(AnchorLeft, "criticalHit", AnchorLeft)
                widget:addAnchor(AnchorRight, "parent", AnchorRight)
                widget:setMarginTop(5)
            else
                widget:addAnchor(AnchorTop, "prev", AnchorBottom)
                widget:addAnchor(AnchorLeft, "criticalHit", AnchorLeft)
                widget:addAnchor(AnchorRight, "parent", AnchorRight)
                widget:setMarginTop(0)
            end

            widget:setMarginLeft(0)

            local name = g_ui.createWidget("SkillNameLabel", widget)
            name:setText(specialName[i])
            name:setColor("#C0C0C0")

            local value = g_ui.createWidget("SkillValueLabel", widget)
            value:setText(string.format("%.2f%%", percent / 100))
            value:setColor("#C0C0C0")
            value:setMarginRight(2)

            if percent > 0 then
                value:setColor("#44AD25")
            else
                value:setColor("#C0C0C0")
            end

            firstSpecial = firstSpecial and false
        end
    end
end

function Cyclopedia.loadCharacterGeneralStats(data, skills)
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    local function format(value)
        local totalMinutes = value / 60
        local hours = math.floor(totalMinutes / 60)
        local minutes = math.floor(totalMinutes % 60)

        if hours < 10 then
            hours = "0" .. hours
        end

        if minutes < 10 then
            minutes = "0" .. minutes
        end

        return hours .. ":" .. minutes
    end

    Cyclopedia.setCharacterSkillValue("level", comma_value(data.level))

    local text = tr("You have %s percent to go ", 100 - data.levelPercent)
    Cyclopedia.setCharacterSkillPercent("level", data.levelPercent, text)
    Cyclopedia.setCharacterSkillValue("experience", comma_value(player:getExperience()))

    local expGainRate = data.baseExpGain + data.XpBoostPercent
    local hasStoreExpBonus = data.XpBoostPercent > 0
    local hasStaminaBonus = data.staminaMinutes / 60 >= 3

    expGainRate = hasStaminaBonus and expGainRate * 1.5 or expGainRate

    local staminaBonusTime = string.format("%02d:%02d", math.floor(math.min(data.staminaMinutes, 180) / 60),
        math.min(data.staminaMinutes, 180) % 60)
    local storeExpBonusTime = format(data.XpBoostBonusRemainingTime)
    local expGainRateTooltip = string.format(
        "Your current XP gain rate amounts to %d%%.\nYour XP gain rate is calculated as follows:\n- Base XP gain rate: %d%%",
        expGainRate, data.baseExpGain)

    expGainRateTooltip = hasStoreExpBonus and expGainRateTooltip ..
                             string.format("\n- XP boost: %d%% (%s h remaining).", data.storeXpBoost, storeExpBonusTime) or
                             expGainRateTooltip
    expGainRateTooltip = hasStaminaBonus and expGainRateTooltip ..
                             string.format("\n- Stamina bonus: x1.5 (%s h remaining).", staminaBonusTime) or
                             expGainRateTooltip

    UI.CharacterStats.expGainRate:setTooltip(expGainRateTooltip)
    -- UI.CharacterStats.expGainRate:setTooltipAlign(AlignTopLeft)
    Cyclopedia.setCharacterSkillValue("expGainRate", comma_value(expGainRate) .. "%")
    Cyclopedia.setCharacterSkillValue("health", comma_value(data.maxHealth))
    Cyclopedia.setCharacterSkillValue("mana", comma_value(data.mana))
    Cyclopedia.setCharacterSkillValue("soul", data.soul)
    Cyclopedia.setCharacterSkillValue("capacity", comma_value(math.floor(player:getFreeCapacity())))

    if data.speed > 0 then
        UI.CharacterStats.speed.value:setColor("#44AD25")
    else
        UI.CharacterStats.speed.value:setColor("#C0C0C0")
    end

    Cyclopedia.setCharacterSkillValue("speed", comma_value(math.floor(data.speed)))
    Cyclopedia.setCharacterSkillValue("food", format(data.regenerationCondition))

    local function formatTime(time)
        local hours = math.floor(time / 60)
        local minutes = time % 60
        if minutes < 10 then
            minutes = "0" .. minutes
        end

        return hours, minutes
    end

    local staminaPercent = math.floor(100 * data.staminaMinutes / 2520)
    local staminaHours, staminaMinutes = formatTime(data.staminaMinutes)

    Cyclopedia.setCharacterSkillValue("stamina", staminaHours .. ":" .. staminaMinutes)

    if data.staminaMinutes > 2400 and g_game.getClientVersion() >= 1038 and player:isPremium() then
        local text = tr("You have %s hours and %s minutes left", staminaHours, staminaMinutes) .. "\n" ..
                         tr("Now you will gain 50%% more experience")

        Cyclopedia.setCharacterSkillPercent("stamina", staminaPercent, text, "green")
    elseif data.staminaMinutes > 2400 and g_game.getClientVersion() >= 1038 and not player:isPremium() then
        local text = tr("You have %s hours and %s minutes left", staminaHours, staminaMinutes) .. "\n" ..
                         tr(
                "You will not gain 50%% more experience because you aren't premium player, now you receive only 1x experience points")

        Cyclopedia.setCharacterSkillPercent("stamina", staminaPercent, text, "#89F013")
    elseif data.staminaMinutes <= 840 and data.staminaMinutes > 0 then
        local text = tr("You have %s hours and %s minutes left", staminaHours, staminaMinutes) .. "\n" ..
                         tr("You gain only 50%% experience and you don't may gain loot from monsters")

        Cyclopedia.setCharacterSkillPercent("stamina", staminaPercent, text, "red")
    elseif data.staminaMinutes == 0 then
        local text = tr("You have %s hours and %s minutes left", staminaHours, staminaMinutes) .. "\n" ..
                         tr("You don't may receive experience and loot from monsters")

        Cyclopedia.setCharacterSkillPercent("stamina", staminaPercent, text, "black")
    end

    local trainerHours, trainerMinutes = formatTime(data.offlineTrainingTime)
    local trainerPercent = 100 * data.offlineTrainingTime / 720

    Cyclopedia.setCharacterSkillValue("trainer", trainerHours .. ":" .. trainerMinutes)
    Cyclopedia.setCharacterSkillPercent("trainer", trainerPercent, tr("You have %s percent", trainerPercent))
    Cyclopedia.setCharacterSkillValue("magiclevel", data.magicLevel)
    Cyclopedia.setCharacterSkillPercent("magiclevel", data.magicLevelPercent / 100,
        tr("You have %s percent to go", 100 - data.magicLevelPercent / 100))
    Cyclopedia.setCharacterSkillBase("magiclevel", data.magicLevel, data.baseMagicLevel)

    for i = Skill.Fist + 1, Skill.Fishing + 1 do
        local skillLevel = skills[i][1]
        local baseSkill = skills[i][2]
        local skillPercent = skills[i][3]

        Cyclopedia.onSkillChange(player, i - 1, skillLevel, skillPercent)
        Cyclopedia.onBaseCharacterSkillChange(player, i - 1, baseSkill)
    end
end

function Cyclopedia.setCharacterSkillValue(id, value)
    local skill = UI.CharacterStats:recursiveGetChildById(id)
    local widget = skill:getChildById("value")
    widget:setText(value)
end

function Cyclopedia.setCharacterSkillPercent(id, percent, tooltip, color)
    local skill = UI.CharacterStats:recursiveGetChildById(id)
    local widget = skill:getChildById("percent")
    if widget then
        widget:setPercent(math.floor(percent))

        if tooltip then
            widget:setTooltip(tooltip)
        end

        if color then
            widget:setBackgroundColor(color)
        end
    end
end

function Cyclopedia.setCharacterSkillBase(id, value, baseValue)
    if baseValue <= 0 or value < 0 then
        return
    end

    local skill = UI.CharacterStats:recursiveGetChildById(id)
    local widget = skill:getChildById("value")

    if baseValue < value then
        widget:setColor("#44AD25")
        skill:setTooltip(baseValue .. " +" .. value - baseValue)
    elseif value < baseValue then
        widget:setColor("#b22222")
        skill:setTooltip(baseValue .. " " .. value - baseValue)
    else
        widget:setColor("#bbbbbb")
        skill:removeTooltip()
    end
end

function Cyclopedia.onBaseCharacterSkillChange(localPlayer, id, baseLevel)
    Cyclopedia.setCharacterSkillBase("skillId" .. id, localPlayer:getSkillLevel(id), baseLevel)
end

function Cyclopedia.onSkillChange(localPlayer, id, level, percent)
    Cyclopedia.setCharacterSkillValue("skillId" .. id, level)
    Cyclopedia.setCharacterSkillPercent("skillId" .. id, percent, tr("You have %s percent to go", 100 - percent))
    Cyclopedia.onBaseCharacterSkillChange(localPlayer, id, localPlayer:getSkillBaseLevel(id))
end

function Cyclopedia.selectCharacterPage()
    local selectedOption = UI.selectedOption
    UI[selectedOption]:setVisible(false)
    UI.InfoBase:setVisible(true)
    Cyclopedia.closeCharacterButtons()

    local oldOpen = UI.openedCategory
    if oldOpen ~= nil then
        close(oldOpen)
    end

    UI.selectedOption = "InfoBase"
end

function Cyclopedia.closeCharacterButtons()
    local size = UI.OptionsBase:getChildCount()
    for i = 1, size do
        local widget = UI.OptionsBase:getChildByIndex(i)
        if widget then
            if widget.subCategories ~= nil then
                for subId, _ in ipairs(widget.subCategories) do
                    local subWidget = widget:getChildById(subId)

                    if subWidget then
                        subWidget.Button:setChecked(false)
                        subWidget.Button.Arrow:setVisible(false)
                        subWidget.Button.Icon:setChecked(false)
                    end
                end
            else
                widget.Button:setChecked(false)
                widget.Button.Arrow:setVisible(false)
                widget.Button.Icon:setChecked(false)
            end
        end
    end
end

function Cyclopedia.configureCharacterCategories()
    UI.OptionsBase:destroyChildren()

    local buttons = {{
        text = "General Stats",
        icon = "/game_cyclopedia/images/character_icons/icon_generalstats",
        subCategories = {{
            text = "Character Stats",
            icon = "/game_cyclopedia/images/character_icons/icon-character-generalstats-overview",
            open = "CharacterStats"
        }, {
            text = "Combat Stats",
            icon = "/game_cyclopedia/images/character_icons/icon-character-generalstats-combatstats",
            open = "CombatStats"
        }}
    }, {
        text = "Battle Results",
        icon = "/game_cyclopedia/images/character_icons/icon_battleresults",
        subCategories = {{
            text = "Recent Deaths",
            icon = "/game_cyclopedia/images/character_icons/icon-character-battleresults-recentdeaths",
            open = "RecentDeaths"
        }, {
            text = "Recent PvP Kills",
            icon = "/game_cyclopedia/images/character_icons/icon-character-battleresults-recentpvpkills",
            open = "RecentKills"
        }}
    }, {
        text = "Achievements",
        icon = "/game_cyclopedia/images/character_icons/icon_achievement",
        open = "CharacterAchievements"
    }, {
        text = "Item Summary",
        icon = "/game_cyclopedia/images/character_icons/icon_items",
        open = "CharacterItems"
    }, {
        text = "Appearances",
        icon = "/game_cyclopedia/images/character_icons/icon_outfitsmounts",
        open = "CharacterAppearances"
    }}

    for id, button in ipairs(buttons) do
        local widget = g_ui.createWidget("CharacterCategoryItem", UI.OptionsBase)
        widget:setId(id)
        widget.Button.Icon:setIcon(button.icon)
        widget.Button.Title:setText(button.text)

        if button.open ~= nil then
            widget.open = button.open
        end

        if button.subCategories ~= nil then
            widget.subCategories = button.subCategories
            widget.subCategoriesSize = #button.subCategories

            widget.Button.Arrow:setVisible(true)

            for subId, subButton in ipairs(button.subCategories) do
                local subWidget = g_ui.createWidget("CharacterCategoryItem", widget)

                subWidget:setId(subId)
                subWidget.Button.Icon:setIcon(subButton.icon)
                subWidget.Button.Title:setText(subButton.text)
                subWidget:setVisible(false)

                subWidget.open = subButton.open

                function subWidget.Button:onClick(test)
                    local selectedOption = UI.selectedOption

                    Cyclopedia.closeCharacterButtons()
                    subWidget.Button:setChecked(true)
                    subWidget.Button.Arrow:setVisible(true)
                    subWidget.Button.Arrow:setImageSource("/game_cyclopedia/images/icon-arrow7x7-right")
                    subWidget.Button.Icon:setChecked(true)
                    UI[selectedOption]:setVisible(false)
                    UI[subWidget.open]:setVisible(true)

                    if subWidget.open == "CharacterStats" then
                        g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.GeneralStats)
                        g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.)
                    elseif subWidget.open == "CombatStats" then
                        g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.CombatStats)
                    elseif subWidget.open == "RecentDeaths" then
                        g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.RecentDeaths, 23, 1)
                    elseif subWidget.open == "RecentKills" then
                        g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.RecentPVPKills, 23, 1)
                    end

                    UI.selectedOption = subWidget.open
                end

                if subId == 1 then
                    subWidget:addAnchor(AnchorTop, "parent", AnchorTop)
                    subWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
                    subWidget:setMarginTop(20)
                else
                    subWidget:addAnchor(AnchorTop, "prev", AnchorBottom)
                    subWidget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
                    subWidget:setMarginTop(-1)
                end
            end
        end

        if id == 1 then
            widget:addAnchor(AnchorTop, "parent", AnchorTop)
            widget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
            widget:setMarginTop(10)
        else
            widget:addAnchor(AnchorTop, "prev", AnchorBottom)
            widget:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
            widget:setMarginTop(10)
        end

        function widget.Button.onClick(this)
            if widget.open == "CharacterAchievements" then
                Cyclopedia.loadCharacterAchievements()
            elseif widget.open == "CharacterItems" then
                g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.ItemSummary)
                Cyclopedia.characterItemListFilter(UI.CharacterItems.listFilter.list)
            elseif widget.open == "CharacterAppearances" then
                g_game.requestCharacterInfo(0, CyclopediaCharacterInfoTypes.OutfitsAndMounts)
            end

            local parent = this:getParent()
            if parent.subCategoriesSize ~= nil then
                if parent.closedSize == nil then
                    parent.closedSize = parent:getHeight() / (parent.subCategoriesSize + 1) + 15
                end

                if parent.openedSize == nil then
                    parent.openedSize = parent:getHeight() * (parent.subCategoriesSize + 1) - 6
                end

                open(parent)
            else
                local oldOpen = UI.openedCategory
                local selectedOption = UI.selectedOption

                Cyclopedia.closeCharacterButtons()
                this.Arrow:setImageSource("/game_cyclopedia/images/icon-arrow7x7-right")
                this.Arrow:setVisible(true)

                if oldOpen ~= nil and oldOpen ~= parent then
                    close(oldOpen)
                end

                this:setChecked(true)
                this.Icon:setChecked(true)
                UI[selectedOption]:setVisible(false)
                UI[parent.open]:setVisible(true)

                UI.selectedOption = parent.open
            end
        end
    end
end

function Cyclopedia.createCharacterDescription()
    local player = g_game.getLocalPlayer()

    UI.InfoBase.DetailsBase.List:destroyChildren()

    local descriptions = {{
        Level = player:getLevel()
    }, {
        Vocation = player:getVocation()
    }, {
        Outfit = "?"
    }}

    for _, description in ipairs(descriptions) do
        local widget = g_ui.createWidget("UIWidget", UI.InfoBase.DetailsBase.List)

        for key, value in pairs(description) do
            widget:setText(key .. ": " .. value)
            widget:setColor("#C0C0C0")
        end

        widget:setTextWrap(true)
    end
end

function Cyclopedia.characterButton(widget)
    if widget.state == 1 then
        widget.state = 2

        widget:setIcon("/game_cyclopedia/images/icon-equipmentdetails")
        UI.InfoBase.inventoryPanel:setVisible(false)
        UI.InfoBase.outfitPanel:setVisible(true)
    else
        widget.state = 1

        widget:setIcon("/game_cyclopedia/images/icon-playerdetails")
        UI.InfoBase.inventoryPanel:setVisible(true)
        UI.InfoBase.outfitPanel:setVisible(false)
    end
end

function Cyclopedia.loadCharacterBadges(showAccountInformation, playerOnline, playerPremium, loyaltyTitle, badgesVector)
    UI.CharacterStats.ListBadge:destroyChildren()
    for _, badge in ipairs(badgesVector) do
        local cell = g_ui.createWidget("CharacterBadge", UI.CharacterStats.ListBadge)
        if cell then
            cell:setImageClip(getImageClip(badge[1]))
            cell:setTooltip(badge[2])
        end
    end
end

function getImageClip(elementIndex)
    local elementSize = 64
    local elementsPerRow = 21
    local y = 0 
    local x = (elementIndex - 1) * elementSize
    local imageClip = string.format("%d %d %d %d", x, y, elementSize, elementSize)
    return imageClip
end
