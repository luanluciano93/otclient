Cyclopedia = {}

contentContainer = nil
local buttonSelection = nil
local items = nil
local bestiary = nil
local charms = nil
local map = nil
local houses = nil
local character = nil
local CyclopediaButton = nil
local bosstiary = nil
local bossSlot = nil
trackerButton = nil
trackerWindow = nil

function toggle()
    if not controllerCyclopedia.ui then
        return
    end
    if controllerCyclopedia.ui:isVisible() then
        return hide()
    end
    show()
end

controllerCyclopedia = Controller:new()
controllerCyclopedia:setUI('game_cyclopedia')
function controllerCyclopedia:onInit()
    CyclopediaButton = modules.game_mainpanel.addToggleButton('CyclopediaButton', tr('Cyclopedia'),
        '/images/options/cooldowns', toggle, false, 7)
    CyclopediaButton:setOn(false)
    contentContainer = controllerCyclopedia.ui:recursiveGetChildById('contentContainer')
    buttonSelection = controllerCyclopedia.ui:recursiveGetChildById('buttonSelection')
    items = buttonSelection:recursiveGetChildById('items')
    bestiary = buttonSelection:recursiveGetChildById('bestiary')
    charms = buttonSelection:recursiveGetChildById('charms')
    map = buttonSelection:recursiveGetChildById('map')
    houses = buttonSelection:recursiveGetChildById('houses')
    character = buttonSelection:recursiveGetChildById('character')
    bosstiary = buttonSelection:recursiveGetChildById('bosstiary')
    bossSlot = buttonSelection:recursiveGetChildById('bossSlot')

	g_ui.importStyle("cyclopedia_widgets")
	g_ui.importStyle("cyclopedia_pages")

    controllerCyclopedia:registerEvents(g_game, {
        -- bestiary
        onParseBestiaryRaces = Cyclopedia.LoadBestiaryCategories,
        onParseBestiaryOverview = Cyclopedia.onParseBestiaryOverview,
        onParseBestiaryMonster = Cyclopedia.loadBestiarySelectedCreature,
        onUpdateBestiaryMonsterData = Cyclopedia.loadBestiarySelectedCreature,
        -- boss_slot
        onParseBosstiarySlots = Cyclopedia.loadBossSlots,
        -- Bosstiary
        onParseSendBosstiary = Cyclopedia.LoadBoostiaryCreatures,
        -- character
        onParseCyclopediaCharacterGeneralStats = Cyclopedia.loadCharacterGeneralStats,
        onParseCyclopediaCharacterCombatStats = Cyclopedia.loadCharacterCombatStats,
        onParseCyclopediaCharacterBadges = Cyclopedia.loadCharacterBadges,
        onCyclopediaCharacterRecentDeaths = Cyclopedia.loadCharacterRecentDeaths,
        onCyclopediaCharacterRecentKills = Cyclopedia.loadCharacterRecentKills,
        onUpdateCyclopediaCharacterItemSummary = Cyclopedia.loadCharacterItems,
        onParseCyclopediaCharacterAppearances = Cyclopedia.loadCharacterAppearances,
        -- charms
        onUpdateBestiaryCharmsData = Cyclopedia.loadCharms,
        -- items
        onParseItemDetail = onParseItemDetail,

        onparseBestiaryTracker = Cyclopedia.onBestiaryUpdate
    })
    
--[[
===================================================
=					tracker		  =
=================================================== 
]]
    trackerButton = modules.client_topmenu.addRightGameToggleButton("trackerButton", tr("Bestiary Tracker"), "/images/options/bestiaryTracker", Cyclopedia.toggleBestiaryTracker, false, 17)

	trackerButton:setOn(true)
	
	trackerWindow = g_ui.loadUI("Tab/Bestiary/bestiary_tracker", modules.game_interface.getRightPanel())
	
	trackerWindow.miniwindowScrollBar:mergeStyle({
		["$!on"] = {}
	})
	trackerWindow:setContentMinimumHeight(120)
	trackerWindow:setup()
	

end

function controllerCyclopedia:onGameStart()

end

function controllerCyclopedia:onGameEnd()
    trackerWindow.contentsPanel.trackerPanel:destroyChildren()
    hide()
end

function controllerCyclopedia:onTerminate()

end

function hide()
    if not controllerCyclopedia.ui then
        return
    end
    controllerCyclopedia.ui:hide()
end

function show()
    if not controllerCyclopedia.ui or not CyclopediaButton then
        return
    end

    controllerCyclopedia.ui:show()
    controllerCyclopedia.ui:raise()
    controllerCyclopedia.ui:focus()
    SelectWindow("items")
    controllerCyclopedia.ui.GoldBase.Value:setText(g_game.getLocalPlayer():getResourceBalance(1))
end

-- LuaFormatter off
function SelectWindow(type)
    local windowTypes = {
        items = {obj = items,func = showItems},
        bestiary = {obj = bestiary,func = showBestiary},
        charms = {obj = charms,func = showCharms},
        map = {obj = map,func = showMap},
        houses = {obj = houses,func = showHouse}, 
        character = {obj = character,func = showCharacter},
        bosstiary = {obj = bosstiary,func = showBosstiary},
        bossSlot = {obj = bossSlot,func = showBossSlot}
    }

    if previousType then
        previousType.obj:enable()
        previousType.obj:setOn(false)
    end
    contentContainer:destroyChildren()

    local window = windowTypes[type]
    if window then
        window.obj:setOn(true)
        window.obj:disable()
        previousType = window
        if window.func then
            window.func(contentContainer)
        end
    end
end
-- LuaFormatter on
