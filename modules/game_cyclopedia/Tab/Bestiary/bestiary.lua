local UI = nil
local STAGES = {
    CREATURES = 2,
    SEARCH = 4,
    CATEGORY = 1,
    CREATURE = 3
}

function Cyclopedia.onParseBestiaryOverview(name, creatures)
    if name == "Result" then
        Cyclopedia.loadBestiarySearchCreatures(creatures)
    else
        Cyclopedia.loadBestiaryCreatures(creatures)
    end
end
bestiaryControllerCyclopedia = Controller:new()

function bestiaryControllerCyclopedia:onInit()
    bestiaryControllerCyclopedia:registerEvents(g_game, {
        onParseBestiaryRaces = Cyclopedia.LoadBestiaryCategories,
        onParseBestiaryOverview = Cyclopedia.onParseBestiaryOverview,
        onParseBestiaryMonster = Cyclopedia.loadBestiarySelectedCreature,
        onUpdateBestiaryMonsterData = Cyclopedia.loadBestiarySelectedCreature
    })

end

function bestiaryControllerCyclopedia:onGameStart()

end

function bestiaryControllerCyclopedia:onGameEnd()

end

function bestiaryControllerCyclopedia:onTerminate()

end

function showBestiary()
    UI = g_ui.loadUI("bestiary", contentContainer)
    UI:show()

    UI.ListBase.CategoryList:setVisible(true)
    UI.ListBase.CreatureList:setVisible(false)
    UI.ListBase.CreatureInfo:setVisible(false)

    Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

    g_game.requestBestiary()
end

Cyclopedia.Bestiary = {}

Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

function Cyclopedia.SetBestiaryProgress(currentValue, maxValue)
    local percent = currentValue / maxValue * 100
    local rect = {
        height = 20,
        x = 0,
        y = 0,
        width = percent / 100 * 193
    }

    if rect.width < 1 then
        rect.width = 1
    end

    UI.ListBase.CreatureInfo.ProgressFill:setImageClip(rect)
    UI.ListBase.CreatureInfo.ProgressFill:setImageRect(rect)
    UI.ListBase.CreatureInfo.ProgressValue:setText(comma_value(tonumber(currentValue)))
end

function Cyclopedia.SetBestiaryStars(Value)
    UI.ListBase.CreatureInfo.StarFill:setWidth(Value * 9)
end

function Cyclopedia.SetBestiaryDiamonds(Value)
    UI.ListBase.CreatureInfo.DiamondFill:setWidth(Value * 9)
end

function Cyclopedia.CreateCreatureItems(data)
    UI.ListBase.CreatureInfo.ItemsBase.Itemlist:destroyChildren()

    for index, _ in pairs(data) do
        local widget = g_ui.createWidget("BestiaryItemGroup", UI.ListBase.CreatureInfo.ItemsBase.Itemlist)

        widget:setId(index)

        if index == 0 then
            widget.Title:setText(tr("Common") .. ":")
        elseif index == 1 then
            widget.Title:setText(tr("Uncommon") .. ":")
        elseif index == 2 then
            widget.Title:setText(tr("Semi-Rare") .. ":")
        elseif index == 3 then
            widget.Title:setText(tr("Rare") .. ":")
        else
            widget.Title:setText(tr("Very Rare") .. ":")
        end

        for i = 1, 15 do
            local item = g_ui.createWidget("BestiaryItem", widget.Items)

            item:setId(i)
        end

        for itemIndex, itemData in ipairs(data[index]) do
            local thing = g_things.getThingType(itemData.id, ThingCategoryItem)
            local itemWidget = UI.ListBase.CreatureInfo.ItemsBase.Itemlist[index].Items[itemIndex]

            itemWidget:setItemId(itemData.id)

            itemWidget.id = itemData.id
            itemWidget.classification = thing:getClassification()

            if itemData.id == 0 then
                itemWidget.undefinedItem:setVisible(true)
            end

            if itemData.id > 0 then
                if itemData.stackable then
                    itemWidget.Stackable:setText("1+")
                else
                    itemWidget.Stackable:setText("1")
                end
            end
            --[[ 
            local frame = g_game.getItemFrame(thing:getResultingValue())

            if frame > 0 then
                itemWidget.Rarity:setImageSource("/images/ui/frames")
                itemWidget.Rarity:setImageClip(torect(g_game.getRectFrame(frame)))
            end ]]
        end
    end
end

function Cyclopedia.loadBestiarySelectedCreature(data)
    local occurence = {
        [0] = 1,
        2,
        3,
        4
    }
    local formattedName = "BUSCAR__" .. data.id
    local outfit = 22
    if RACE[data.id] then
        formattedName = RACE[data.id].name:gsub("(%l)(%w*)", function(first, rest)
            return first:upper() .. rest
        end)
        outfit = RACE[data.id].type
    end
    UI.ListBase.CreatureInfo:setText(formattedName)
    Cyclopedia.SetBestiaryDiamonds(occurence[data.ocorrence])
    Cyclopedia.SetBestiaryStars(data.difficulty)
    UI.ListBase.CreatureInfo.LeftBase.Sprite:setOutfit({
        type = outfit
    })
    UI.ListBase.CreatureInfo.LeftBase.Sprite:getCreature():setStaticWalking(1000)

    Cyclopedia.SetBestiaryProgress(data.killCounter, data.lastProgressKillCount)

    if data.killCounter >= data.thirdDifficulty then
        --  UI.ListBase.CreatureInfo.ProgressFill:setImageSource("/game_cyclopedia/images/bestiary/fill")
        UI.ListBase.CreatureInfo.ProgressValue:setText(data.killCounter) -- thirdDifficulty
        UI.ListBase.CreatureInfo.ProgressValue:setMarginBottom(10)
    else
        --  UI.ListBase.CreatureInfo.ProgressFill:setImageSource("/game_cyclopedia/images/bestiary/durability_fill")
        UI.ListBase.CreatureInfo.ProgressValue:setText(comma_value(data.killCounter))
        UI.ListBase.CreatureInfo.ProgressValue:setMarginBottom(10)
    end

    if data.currentLevel > 1 then
        UI.ListBase.CreatureInfo.Value1:setText(data.maxHealth)
        UI.ListBase.CreatureInfo.Value2:setText(data.experience)
        UI.ListBase.CreatureInfo.Value3:setText(data.speed)
        UI.ListBase.CreatureInfo.Value4:setText(data.armor)
        UI.ListBase.CreatureInfo.Value5:setText(data.mitigation .. "%")
        UI.ListBase.CreatureInfo.BonusValue:setText(data.charmValue)
    end

    local resists = {"PhysicalProgress", "FireProgress", "EarthProgress", "EnergyProgress", "IceProgress",
                     "HolyProgress", "DeathProgress", "HealingProgress"}

    if not table.empty(data.combat) then
        for i = 1, 8 do
            local combat = calculateCombatValues(data.combat[i])

            UI.ListBase.CreatureInfo[resists[i]].Fill:setMarginRight(combat.margin)
            UI.ListBase.CreatureInfo[resists[i]].Fill:setBackgroundColor(combat.color)
            UI.ListBase.CreatureInfo[resists[i]]:setTooltip(string.format("Sensitive to %s : %s", string.gsub(
                resists[i], "Progress", ""):lower(), combat.tooltip))
        end
    else
        for i = 1, 8 do
            UI.ListBase.CreatureInfo[resists[i]].Fill:setMarginRight(65)
        end
    end

    local lootData = {}

    for _, value in ipairs(data.loot) do
        local loot = {
            name = value.name,
            id = value.itemId,
            type = value.type,
            difficulty = value.diffculty,
            stackable = value.stackable == 1 and true or false
        }

        if not lootData[value.diffculty] then
            lootData[value.diffculty] = {}
        end

        table.insert(lootData[value.diffculty], loot)
    end

    Cyclopedia.CreateCreatureItems(lootData)
    UI.ListBase.CreatureInfo.LocationField.Textlist.Text:setText(data.location)
end

function Cyclopedia.ShowBestiaryCreature()
    Cyclopedia.Bestiary.Stage = STAGES.CREATURE

    Cyclopedia.onStageChange()
end

function Cyclopedia.ShowBestiaryCreatures(Category)
    UI.ListBase.CreatureList:destroyChildren()
    UI.ListBase.CategoryList:setVisible(false)
    UI.ListBase.CreatureInfo:setVisible(false)
    UI.ListBase.CreatureList:setVisible(true)
    g_game.requestBestiaryOverview(Category)
end

function Cyclopedia.CreateBestiaryCategoryItem(Data)

    UI.BackPageButton:setEnabled(false)

    local widget = g_ui.createWidget("BestiaryCategory", UI.ListBase.CategoryList)

    widget:setText(Data.name)
    widget.ClassIcon:setImageSource("/game_cyclopedia/images/bestiary/creatures/" .. Data.name:lower():gsub(" ", "_"))

    widget.Category = Data.name

    widget:setColor("#C0C0C0")
    widget.TotalValue:setText(string.format("Total: %d", Data.amount))
    widget.KnownValue:setText(string.format("Known: %d", Data.know))

    function widget.ClassBase:onClick()
        UI.BackPageButton:setEnabled(true)
        Cyclopedia.ShowBestiaryCreatures(self:getParent().Category)

        Cyclopedia.Bestiary.Stage = STAGES.CREATURES

        Cyclopedia.onStageChange()
    end
end

function Cyclopedia.loadBestiarySearchCreatures(data)
    UI.ListBase.CategoryList:setVisible(false)
    UI.ListBase.CreatureInfo:setVisible(false)
    UI.ListBase.CreatureList:setVisible(true)
    UI.BackPageButton:setEnabled(true)

    Cyclopedia.Bestiary.Stage = STAGES.SEARCH

    Cyclopedia.onStageChange()

    local maxCategoriesPerPage = 15

    Cyclopedia.Bestiary.Search = {}
    Cyclopedia.Bestiary.Page = 1
    Cyclopedia.Bestiary.TotalSearchPages = math.ceil(#data / maxCategoriesPerPage)

    UI.PageValue:setText(string.format("%d / %d", Cyclopedia.Bestiary.Page, Cyclopedia.Bestiary.TotalSearchPages))

    local page = 1

    Cyclopedia.Bestiary.Search[page] = {}

    for i = 0, #data do
        if i % maxCategoriesPerPage == 0 and i > 0 then
            page = page + 1
            Cyclopedia.Bestiary.Search[page] = {}
        end

        local creature = {
            id = data[i].id,
            currentLevel = data[i].currentLevel
        }

        table.insert(Cyclopedia.Bestiary.Search[page], creature)
    end

    Cyclopedia.Bestiary.Stage = STAGES.SEARCH

    Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, true)
    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.loadBestiaryCreatures(data)
    local maxCategoriesPerPage = 15

    Cyclopedia.Bestiary.Creatures = {}
    Cyclopedia.Bestiary.Page = 1
    Cyclopedia.Bestiary.TotalCreaturesPages = math.ceil(#data / maxCategoriesPerPage)

    UI.PageValue:setText(string.format("%d / %d", Cyclopedia.Bestiary.Page, Cyclopedia.Bestiary.TotalCreaturesPages))

    local page = 1

    Cyclopedia.Bestiary.Creatures[page] = {}

    for i = 1, #data do
        if (i - 1) % maxCategoriesPerPage == 0 and i > 1 then
            page = page + 1
            Cyclopedia.Bestiary.Creatures[page] = {}
        end

        local creature = {
            id = data[i].id,
            currentLevel = data[i].currentLevel
        }

        table.insert(Cyclopedia.Bestiary.Creatures[page], creature)
    end

    Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, false)
    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.BestiarySearch()
    local text = UI.SearchEdit:getText()
    local creatures = {}

    for id, data in pairs(RACE) do
        if string.find(data.name, text) then
            table.insert(creatures, id)
        end
    end

    g_game.requestBestiarySearch(creatures)
    UI.SearchEdit:setText("")
end

function Cyclopedia.BestiarySearchText(text)
    if text ~= "" then
        UI.SearchButton:enable(true)
    else
        UI.SearchButton:disable(false)
    end
end

function Cyclopedia.CreateBestiaryCreaturesItem(data)
    if not RACE[data.id] then
        --  error(string.format("Race id: %d not found.", data.id))
    end

    local function verify(name)
        if #name > 18 then
            return name:sub(1, 15) .. "..."
        else
            return name
        end
    end

    local widget = g_ui.createWidget("BestiaryCreature", UI.ListBase.CreatureList)

    widget:setId(data.id)
    local formattedName = "BUSCAR__" .. data.id

    if RACE[data.id] then
        formattedName = RACE[data.id].name:gsub("(%l)(%w*)", function(first, rest)
            return first:upper() .. rest
        end)
    end
    widget.Name:setText(verify(formattedName))
    widget.Sprite:setOutfit({
        type = safeOutfit(RACE[data.id].type)
    })
    widget.Sprite:getCreature():setStaticWalking(1000)

    local level = {0, 1, 2}

    if data.currentLevel > 3 then
        widget.Finalized:setVisible(true)
        widget.KillsLabel:setVisible(false)
        widget.Sprite:getCreature():setShader("")
    else
        widget.KillsLabel:setText(string.format("%d / 3", data.currentLevel))
        widget.Sprite:getCreature():setShader("Outfit - cyclopedia-black")
        widget.Name:setText("uknown")
    end

    function widget.ClassBase:onClick()
        UI.BackPageButton:setEnabled(true)
        g_game.requestBestiarySearch(widget:getId())
        Cyclopedia.ShowBestiaryCreature()
    end
end

function Cyclopedia.loadBestiaryCreature(page, search)
    local state = "Creatures"

    if search then
        state = "Search"
    end

    if not Cyclopedia.Bestiary[state][page] then
        return
    end

    UI.ListBase.CreatureList:destroyChildren()

    for _, data in ipairs(Cyclopedia.Bestiary[state][page]) do
        Cyclopedia.CreateBestiaryCreaturesItem(data)
    end
end

function Cyclopedia.LoadBestiaryCategories(data)
    local maxCategoriesPerPage = 15

    Cyclopedia.Bestiary.Categories = {}
    Cyclopedia.Bestiary.Page = 1
    Cyclopedia.Bestiary.TotalCategoriesPages = math.ceil(#data / maxCategoriesPerPage)
    if UI == nil or UI.PageValue == nil then -- I know, don't change it
        return
    end
    UI.PageValue:setText(string.format("%d / %d", Cyclopedia.Bestiary.Page, Cyclopedia.Bestiary.TotalCategoriesPages))

    local page = 1

    Cyclopedia.Bestiary.Categories[page] = {}

    for i = 1, #data do
        if (i - 1) % maxCategoriesPerPage == 0 and i > 1 then
            page = page + 1
            Cyclopedia.Bestiary.Categories[page] = {}
        end

        local category = {
            name = data[i].bestClass,
            amount = data[i].unlockedCount,
            know = data[i].count
        }

        table.insert(Cyclopedia.Bestiary.Categories[page], category)
    end

    Cyclopedia.loadBestiaryCategory(Cyclopedia.Bestiary.Page)
    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.loadBestiaryCategory(page)
    if not Cyclopedia.Bestiary.Categories[page] then
        return
    end

    UI.ListBase.CategoryList:destroyChildren()

    for _, data in ipairs(Cyclopedia.Bestiary.Categories[page]) do
        Cyclopedia.CreateBestiaryCategoryItem(data)
    end
end

function Cyclopedia.onStageChange()
    Cyclopedia.Bestiary.Page = 1

    if Cyclopedia.Bestiary.Stage == STAGES.CATEGORY then
        UI.BackPageButton:setEnabled(false)
        UI.ListBase.CategoryList:setVisible(true)
        UI.ListBase.CreatureList:setVisible(false)
        UI.ListBase.CreatureInfo:setVisible(false)
    end

    if Cyclopedia.Bestiary.Stage == STAGES.CREATURES then
        UI.BackPageButton:setEnabled(true)
        UI.ListBase.CategoryList:setVisible(false)
        UI.ListBase.CreatureList:setVisible(true)
        UI.ListBase.CreatureInfo:setVisible(false)

        function UI.BackPageButton.onClick()
            Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

            Cyclopedia.onStageChange()
        end
    end

    if Cyclopedia.Bestiary.Stage == STAGES.SEARCH then
        UI.BackPageButton:setEnabled(true)
        UI.ListBase.CategoryList:setVisible(false)
        UI.ListBase.CreatureList:setVisible(true)
        UI.ListBase.CreatureInfo:setVisible(false)

        function UI.BackPageButton.onClick()
            Cyclopedia.Bestiary.Stage = STAGES.CATEGORY

            Cyclopedia.onStageChange()
        end
    end

    if Cyclopedia.Bestiary.Stage == STAGES.CREATURE then
        UI.BackPageButton:setEnabled(true)
        UI.ListBase.CategoryList:setVisible(false)
        UI.ListBase.CreatureList:setVisible(false)
        UI.ListBase.CreatureInfo:setVisible(true)

        function UI.BackPageButton.onClick()
            Cyclopedia.Bestiary.Stage = STAGES.CREATURES

            Cyclopedia.onStageChange()
        end
    end

    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.changeBestiaryPage(prev, next)
    local stage = Cyclopedia.Bestiary.Stage

    if next then
        Cyclopedia.Bestiary.Page = Cyclopedia.Bestiary.Page + 1
    end

    if prev then
        Cyclopedia.Bestiary.Page = Cyclopedia.Bestiary.Page - 1
    end

    if stage == STAGES.CATEGORY then
        Cyclopedia.loadBestiaryCategory(Cyclopedia.Bestiary.Page)
    elseif stage == STAGES.CREATURES then
        Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, false)
    elseif stage == STAGES.SEARCH then
        Cyclopedia.loadBestiaryCreature(Cyclopedia.Bestiary.Page, true)
    end

    Cyclopedia.verifyBestiaryButtons()
end

function Cyclopedia.verifyBestiaryButtons()
    local page = Cyclopedia.Bestiary.Page
    local totalCategoriesPages = Cyclopedia.Bestiary.TotalCategoriesPages
    local totalCreaturesPages = Cyclopedia.Bestiary.TotalCreaturesPages
    local totalSearchPages = Cyclopedia.Bestiary.TotalSearchPages
    local stage = Cyclopedia.Bestiary.Stage

    local function updateButtonState(button, condition)
        if condition then
            button:enable()
        else
            button:disable()
        end
    end

    local function updatePageValue(currentPage, totalPages)
        UI.PageValue:setText(string.format("%d / %d", currentPage, totalPages))
    end

    updateButtonState(UI.SearchButton, UI.SearchEdit:getText() ~= "")

    if stage == STAGES.SEARCH and totalSearchPages then
        local totalPages = totalSearchPages

        updateButtonState(UI.PrevPageButton, page > 1)
        updateButtonState(UI.NextPageButton, page < totalPages)
        updatePageValue(page, totalPages)

        return
    end

    if stage == STAGES.CREATURE then
        UI.PrevPageButton:disable()
        UI.NextPageButton:disable()
        updatePageValue(1, 1)

        return
    end

    if stage == STAGES.CATEGORY and totalCategoriesPages or stage == STAGES.CREATURES and totalCreaturesPages then
        local totalPages = stage == STAGES.CATEGORY and totalCategoriesPages or totalCreaturesPages

        updateButtonState(UI.PrevPageButton, page > 1)
        updateButtonState(UI.NextPageButton, page < totalPages)
        updatePageValue(page, totalPages)
    end
end

