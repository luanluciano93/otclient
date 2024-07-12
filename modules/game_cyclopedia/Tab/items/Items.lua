-- LuaFormatter off
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


function getChildrenData(widget)
    local data = {
        id = widget:getId(),
        className = widget:getClassName(),
        properties = {}
    }

    local children = widget:getChildren()
    data.children = {}
    for _, child in ipairs(children) do
        table.insert(data.children, getChildrenData(child))
    end

    return data
end


function showItems()

    itemPanel = g_ui.loadUI("items", contentContainer)
    itemPanel:show()

    itemPanel.ManageButton.onClick = function()
        hide()
        -- modules.game_quickloot.QuickLoot.toggle(true)
        print("not yet game_quickloot")
    end

    local data = getChildrenData(itemPanel)
    local jsonString = json.encode(data, { indent = true }) 
    local file = io.open("file.json", "w") 
    if file then
        file:write(jsonString)
        file:close()
        print("Exported successfully to /path/to/your/file.json")
    else
        print("Failed to open the file for writing")
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
end

function onParseItemDetail(itemId, descriptions)
    itemPanel.InfoBase.DetailsBase.List:destroyChildren()
    local internalData = g_things.getThingType(itemId, ThingCategoryItem)
    local classification = internalData:getClassification()

    for _, description in ipairs(descriptions) do
        local widget = g_ui.createWidget("UIWidget", itemPanel.InfoBase.DetailsBase.List)

        for key, value in pairs(description) do
            widget:setText(key .. ": " .. value)
            widget:setColor("#C0C0C0")
        end

        widget:setTextWrap(true)
    end
    if classification > 0 then
        local widget = g_ui.createWidget("UIWidget", itemPanel.InfoBase.DetailsBase.List)
        widget:setText("Classification" .. ": " .. classification)
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
			local item = Cyclopedia.internalCreateItem(data)
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
        local oldSelected = itemPanel.selectedCategory

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
            local item = Cyclopedia.internalCreateItem(data)
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
--[[ 
Send = 
g_game.inspectObject(3, itemId)

Get:
itemId, descriptions
]]








