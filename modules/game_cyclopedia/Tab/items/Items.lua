-- wtf is this
-- LuaFormatter off
ArrayCiclopedia = {
    Items = {
        VocFilter = false,
        LevelFilter = false,
        h1Filter = false,
        h2Filter = false,
        ClassificationFilter = 0,
        SelectedCategory = nil
    }

}

local itemPanel
local CategoryColor = "#484848"
local ItemList = {}
local AllItemList = {}
local CategoryItems = {
    { id = 1, name = "Armors" },
    { id = 2, name = "Amulets" },
    { id = 3, name = "Boots" },
    { id = 4, name = "Containers" },
    { id = 24, name = "Creature Products" },
    { id = 5, name = "Decoration" },
    { id = 6, name = "Food" },
    { id = 30, name = "Gold" },
    { id = 7, name = "Helmets and Hats" },
    { id = 8, name = "Legs" },
    { id = 9, name = "Others" },
    { id = 10, name = "Potions" },
    { id = 254, name = "Quivers" },
    { id = 11, name = "Rings" },
    { id = 12, name = "Runes" },
    { id = 13, name = "Shields" },
    { id = 14, name = "Tools" },
    { id = 31, name = "Unsorted" },
    { id = 15, name = "Valuables" },
    { id = 16, name = "Weapons: Ammo" },
    { id = 17, name = "Weapons: Axe" },
    { id = 18, name = "Weapons: Clubs" },
    { id = 19, name = "Weapons: Distance" },
    { id = 20, name = "Weapons: Swords" },
    { id = 21, name = "Weapons: Wands" },
    { id = 1000, name = "Weapons: All" }
}
-- LuaFormatter on

itemsControllerCyclopedia = Controller:new()

function itemsControllerCyclopedia:onInit()
    itemsControllerCyclopedia:registerEvents(g_game, {
        onParseItemDetail = onParseItemDetail

    })
end

function itemsControllerCyclopedia:onGameStart()

end

function itemsControllerCyclopedia:onGameEnd()

end

function itemsControllerCyclopedia:onTerminate()

end

function showItems()

    itemPanel = g_ui.loadUI("items", contentContainer)
    exportWidgetDataToJson(itemPanel, "itemPanel.json")
    loadItemsCategories()
    itemPanel:show()

    itemPanel.ManageButton.onClick = function()
        hide()
        -- modules.game_quickloot.QuickLoot.toggle(true)
        print("not yet game_quickloot")
    end

    for _, data in ipairs(CategoryItems) do
        local ItemCat = g_ui.createWidget("ItemCategory", itemPanel.CategoryList)

        ItemCat:setId(data.id)
        ItemCat:setText(data.name)
        ItemCat:setBackgroundColor(CategoryColor)

        ItemCat.BaseColor = CategoryColor

        function ItemCat:onClick()
            ResetItemCategorySelection(itemPanel.CategoryList)
            self:setChecked(true)
            self:setBackgroundColor("#585858")
        end
        CategoryColor = CategoryColor == "#484848" and "#414141" or "#484848"
    end

    itemPanel.LootValue.NpcBuyCheck.onClick = onChangeLootValue
    itemPanel.LootValue.MarketCheck.onClick = onChangeLootValue
end

function onParseItemDetail(itemId, descriptions) -- GET INFO
    itemPanel.InfoBase.DetailsBase.List:destroyChildren()
    local internalData = g_things.getThingType(itemId, ThingCategoryItem)
    local classification = internalData:getClassification()

    for _, description in ipairs(descriptions) do
        local widget = g_ui.createWidget("UIWidget", itemPanel.InfoBase.DetailsBase.List)
        local key = description[1]
        local value = description[2]
        widget:setText(key .. ": " .. value)
        widget:setColor("#C0C0C0")
        widget:setTextWrap(true)
    end

    if classification > 0 then
        local widget = g_ui.createWidget("UIWidget", itemPanel.InfoBase.DetailsBase.List)
        widget:setText("Classification: " .. classification)
        widget:setColor("#C0C0C0")
    end
end

function ResetItemCategorySelection(list)
    for i, child in pairs(list:getChildren()) do
        child:setChecked(false)
        child:setBackgroundColor(child.BaseColor)
    end
end

function OnEnterPage_Items()
    itemPanel.EmptyLabel:setVisible(true)
    itemPanel.InfoBase:setVisible(false)
    itemPanel.LootValue:setVisible(false)
    itemPanel.H1Button:disable()
    itemPanel.H2Button:disable()
    itemPanel.ItemFilter:disable()
end

function selectItemCategory(id)
    if itemPanel.SearchEdit:getText() ~= "" then
        ItemSearch("", true)
    end

    itemPanel.ItemListBase.List:destroyChildren()

    if hasClassificationFilter(id) then
        itemPanel.ItemFilter:clearOptions()
        itemPanel.ItemFilter:addOption("All", 0, true)
        itemPanel.ItemFilter:addOption("None", -1, true)

        for class = 1, 4 do
            itemPanel.ItemFilter:addOption("Class " .. class, class, true)
        end

        itemPanel.ItemFilter:enable()
    else
        itemPanel.ItemFilter:clearOptions()

        itemPanel.ClassificationFilter = 0
    end

    if not table.empty(ItemList[id]) then
        for _, data in pairs(ItemList[id]) do
            local item = internalCreateItem(data)
        end
    end

    if hasHandedFilter(id) then
        itemPanel.H1Button:enable()
        itemPanel.H2Button:enable()
    else
        itemPanel.H1Button:disable()
        itemPanel.H2Button:disable()
    end
end

function ItemSearch(text, clearTextEdit)
    if text ~= "" then
        itemPanel.ItemListBase.List:destroyChildren()
        itemPanel.SelectedItem.Sprite:setItemId(0)
        itemPanel.SelectedItem.Rarity:setImageSource("")

        local searchedItems = {}
        local oldSelected = ArrayCiclopedia.Items.selectedCategory

        if oldSelected then
            oldSelected:setBackgroundColor(oldSelected.BaseColor)
            oldSelected:setChecked(false)
        end

        local searchTermLower = string.lower(text)

        for _, data in pairs(AllItemList) do
            local marketData = data:getMarketData()
            local itemNameLower = string.lower(marketData.name)
            local _, endIndex = itemNameLower:find(searchTermLower, 1, true)

            if endIndex and (itemNameLower:sub(endIndex + 1, endIndex + 1) == " " or endIndex == #itemNameLower) then
                table.insert(searchedItems, data)
            end
        end

        for _, data in ipairs(searchedItems) do
            local item = internalCreateItem(data)
        end
    else
        itemPanel.ItemListBase.List:destroyChildren()
        itemPanel.SelectedItem.Sprite:setItemId(0)
        itemPanel.SelectedItem.Rarity:setImageSource("")
    end

    if clearTextEdit then
        itemPanel.SearchEdit:setText("")
    end
end

function internalCreateItem(data)
    local player = g_game.getLocalPlayer()
    --  local vocation = g_game.getRealVocation(player:getVocation()) or 1
    local vocation = player:getVocation()
    local level = player:getLevel()
    local classification = data:getClassification()
    local marketData = data:getMarketData()
    local vocFilter = ArrayCiclopedia.Items.VocFilter
    local levelFilter = ArrayCiclopedia.Items.LevelFilter
    local h1Filter = ArrayCiclopedia.Items.h1Filter
    local h2Filter = ArrayCiclopedia.Items.h2Filter
    local classificationFilter = ArrayCiclopedia.Items.ClassificationFilter

    if vocFilter and tonumber(marketData.restrictVocation) ~= tonumber(vocation) then
        return
    end

    if levelFilter and level < marketData.requiredLevel then
        return
    end

    if h1Filter and data:getClothSlot() ~= 6 then
        return
    end

    if h2Filter and data:getClothSlot() ~= 0 then
        return
    end

    if classificationFilter == -1 and classification ~= 0 then
        return
    elseif classificationFilter == 1 and classification ~= 1 then
        return
    elseif classificationFilter == 2 and classification ~= 2 then
        return
    elseif classificationFilter == 3 and classification ~= 3 then
        return
    elseif classificationFilter == 4 and classification ~= 4 then
        return
    end

    local item = g_ui.createWidget("ItemsListBaseItem", itemPanel.ItemListBase.List)

    item:setId(data:getId())
    item.Sprite:setItemId(data:getId())
    item.Name:setText(marketData.name)

    -- NEED item:getResultingValue()
    -- item.Value = data:getResultingValue()
    item.Value = 1
    item.Vocation = marketData.restrictVocation

    --[[    

    --Need g_game.getItemFrame(item.Value)

    local frame = g_game.getItemFrame(item.Value)

    if frame > 0 then
        item.Rarity:setImageSource("/images/ui/frames")
        item.Rarity:setImageClip(torect(g_game.getRectFrame(frame)))
    end
 ]]
    function item.onClick(widget)
        itemPanel.InfoBase.SellBase.List:destroyChildren()
        itemPanel.InfoBase.BuyBase.List:destroyChildren()

        local oldSelected = itemPanel.selectItem
        local lootValue = itemPanel.LootValue
        local itemId = tonumber(widget:getId())
        local internalData = g_things.getThingType(itemId, ThingCategoryItem)

        if oldSelected then
            oldSelected:setBackgroundColor("#00000000")
        end

        g_game.inspectionObject(3, itemId) -- SEND

        if not lootValue:isVisible() then
            lootValue:setVisible(true)
        end

        itemPanel.EmptyLabel:setVisible(false)
        itemPanel.InfoBase:setVisible(true)
        itemPanel.InfoBase.ResultGoldBase.Value:setText(formatGold(item.Value))
        itemPanel.SelectedItem.Sprite:setItemId(data:getId())

        --[[    
        --NEED g_game.getItemFrame(item.Value)     

        if frame > 0 then
            itemPanel.InfoBase.ResultGoldBase.Rarity:setImageSource("/images/ui/frames")
            itemPanel.InfoBase.ResultGoldBase.Rarity:setImageClip(torect(g_game.getRectFrame(frame)))
            itemPanel.SelectedItem.Rarity:setImageSource("/images/ui/frames")
            itemPanel.SelectedItem.Rarity:setImageClip(torect(g_game.getRectFrame(frame)))
        else
            itemPanel.InfoBase.ResultGoldBase.Rarity:setImageSource("")
            itemPanel.SelectedItem.Rarity:setImageSource("")
        end ]]

        itemPanel.InfoBase.ResultGoldBase.Rarity:setImageSource("")
        itemPanel.SelectedItem.Rarity:setImageSource("")
        widget:setBackgroundColor("#585858")

        --[[    
        --NEEED getNpcSaleData
     
     
     local buy, sell = formatSaleData(internalData:getNpcSaleData())
        local sellColor = "#484848"

        for index, value in ipairs(sell) do
            local t_widget = g_ui.createWidget("UIWidget", itemPanel.InfoBase.SellBase.List)

            t_widget:setId(index)
            t_widget:setText(value)
            t_widget:setTextAlign(AlignLeft)
            t_widget:setBackgroundColor(sellColor)

            t_widget.BaseColor = sellColor

            function t_widget:onClick()
                ResetItemCategorySelection(itemPanel.InfoBase.SellBase.List)
                self:setChecked(true)
                self:setBackgroundColor("#585858")
            end

            sellColor = sellColor == "#484848" and "#414141" or "#484848"
        end

        local buyColor = "#484848"

        for index, value in ipairs(buy) do
            local t_widget = g_ui.createWidget("UIWidget", itemPanel.InfoBase.BuyBase.List)

            t_widget:setId(index)
            t_widget:setText(value)
            t_widget:setTextAlign(AlignLeft)
            t_widget:setBackgroundColor(buyColor)

            t_widget.BaseColor = buyColor

            function t_widget:onClick()
                ResetItemCategorySelection(itemPanel.InfoBase.BuyBase.List)
                self:setChecked(true)
                self:setBackgroundColor("#585858")
            end

            buyColor = buyColor == "#484848" and "#414141" or "#484848"
        end ]]

        itemPanel.selectItem = widget
    end

    return item
end

-- @ ui call
function onCategoryChange(widget)
    if widget:isChecked() then
        selectItemCategory(tonumber(widget:getId()))

        ArrayCiclopedia.Items.selectedCategory = widget
    end
end

function vocationFilter(value)
    itemPanel.ItemListBase.List:destroyChildren()

    ArrayCiclopedia.Items.VocFilter = value

    applyFilters()
end

function applyFilters()

    --[[     local isSearching = itemPanel.SearchEdit:getText() ~= ""

    if not isSearching then
        local id = tonumber(ArrayCiclopedia.Items.selectedCategory:getId())

        for _, data in pairs(ItemList[id]) do
            local item = internalCreateItem(data)
        end
    else
        ItemSearch(itemPanel.SearchEdit:getText(), false)
    end ]]
end

function levelFilter(value)
    itemPanel.ItemListBase.List:destroyChildren()

    ArrayCiclopedia.Items.LevelFilter = value

    applyFilters()
end

function h1Filter(value)
    itemPanel.ItemListBase.List:destroyChildren()

    local brother = itemPanel.H2Button

    ArrayCiclopedia.Items.h1Filter = value

    applyFilters()

    if value and brother:isChecked() then
        brother:setChecked(false)

        ArrayCiclopedia.Items.h2Filter = false
    end
end

function h2Filter(value)
    itemPanel.ItemListBase.List:destroyChildren()

    local brother = itemPanel.H1Button

    ArrayCiclopedia.Items.h2Filter = value

    applyFilters()

    if value and brother:isChecked() then
        brother:setChecked(false)

        ArrayCiclopedia.Items.h1Filter = false
    end
end

function classificationFilter(data)
    itemPanel.ItemListBase.List:destroyChildren()

    ArrayCiclopedia.Items.ClassificationFilter = tonumber(data)

    applyFilters()
end

function loadItemsCategories()
    local types = g_things.findThingTypeByAttr(ThingAttrMarket, 0)
    local tempItemList = {}

    for _, data in pairs(types) do
        local marketData = data:getMarketData()

        if not tempItemList[marketData.category] then
            tempItemList[marketData.category] = {}
        end

        if marketData then
            table.insert(AllItemList, data)
        end

        table.insert(tempItemList[marketData.category], data)
    end

    for category, itemList in pairs(tempItemList) do
        table.sort(itemList, compareItems)

        ItemList[category] = itemList
    end
    print(#ItemList)
end

function FillItemList()
    local types = g_things.findThingTypeByAttr(ThingAttrMarket, 0)

    for i = 1, #types do
        local itemType = types[i]
        local item = Item.create(itemType:getId())

        if item then
            local marketData = itemType:getMarketData()

            if not table.empty(marketData) then
                item:setId(marketData.showAs)

                local marketItem = {
                    displayItem = item,
                    thingType = itemType,
                    marketData = marketData
                }

                if ItemList[marketData.category] ~= nil then
                    table.insert(ItemList[marketData.category], marketItem)
                end
            end
        end
    end
end

--[[ 
Send = 
g_game.inspectObject(3, itemId)

Get:
itemId, descriptions
]]
