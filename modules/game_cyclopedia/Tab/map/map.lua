local UI = nil
function showMap()
    UI = g_ui.loadUI("map", contentContainer)
    UI:show()
	mapControllerCyclopedia:registerEvents(LocalPlayer, {
		onPositionChange = Cyclopedia.onUpdateCameraPosition
	}):execute()

	UI.InformationBase.InternalBase.NavigationBase.LayerScrollbar.decrementButton:setVisible(false)
	UI.InformationBase.InternalBase.NavigationBase.LayerScrollbar.incrementButton:setVisible(false)
	
	local LayerSlider = UI.InformationBase.InternalBase.NavigationBase.LayerScrollbar.sliderButton
	
	LayerSlider:setImageSource("")
	g_ui.createWidget("MapLayerSelector", LayerSlider)
	
	Cyclopedia.prevFloor = 7
	function UI.InformationBase.InternalBase.NavigationBase.LayerScrollbar:onValueChange(value)
		local layerIndex = ConvertLayer(value)
		local rect = {
			width = 14,
			height = 67,
			y = 0,
			x = layerIndex * 14
		}
	
		UI.InformationBase.InternalBase.NavigationBase.LayerIndicator:setImageClip(rect)
	
		if Cyclopedia.prevFloor ~= layerIndex then
			Cyclopedia.floorScrollBar(Cyclopedia.prevFloor, layerIndex)
		end
	
		Cyclopedia.prevFloor = layerIndex
	end
	
UI.InformationBase.InternalBase.NavigationBase.LayerScrollbar:setValue(150)
Cyclopedia.loadMap()

end

mapControllerCyclopedia = Controller:new()

function mapControllerCyclopedia:onInit()



end

function mapControllerCyclopedia:onGameStart()


end

function mapControllerCyclopedia:onGameEnd()

end

function mapControllerCyclopedia:onTerminate()

end


function Cyclopedia.loadMap()
    local clientVersion = g_game.getClientVersion()
    local minimapWidget = UI.MapBase.minimap

    g_minimap.clean()

    local loaded = false
    local minimapFile = "/minimap.otmm"
    local dataMinimapFile = "/data" .. minimapFile
    local versionedMinimapFile = "/minimap" .. clientVersion .. ".otmm"

    if g_resources.fileExists(dataMinimapFile) then
        loaded = g_minimap.loadOtmm(dataMinimapFile)
    end

    if not loaded and g_resources.fileExists(versionedMinimapFile) then
        loaded = g_minimap.loadOtmm(versionedMinimapFile)
    end

    if not loaded and g_resources.fileExists(minimapFile) then
        loaded = g_minimap.loadOtmm(minimapFile)
    end

    if not loaded then
        print("Minimap couldn't be loaded, file missing?")
    end

    minimapWidget:load()
    --minimapWidget:hideFlags()
end

function Cyclopedia.CreateMarkItem(Data)
    local MarkItem = g_ui.createWidget("MarkListItem",
        UI.InformationBase.InternalBase.DisplayBase.MarkList)

    MarkItem:setIcon("/images/game/minimap/flag" .. Data.flagId)
end




function Cyclopedia.toggleMapFlag(widget, checked)
    UI.MapBase.minimap:filterFlag(widget:getId(), checked)
end

function Cyclopedia.showAllFlags(checked)
    local size = UI.InformationBase.InternalBase.DisplayBase.MarkList:getChildCount()

    if checked then
        for i = 0, size do
            local flag = UI.InformationBase.InternalBase.DisplayBase.MarkList[i]

            if flag then
                flag:setChecked(true)
            end
        end
    else
        for i = 0, size do
            local flag = UI.InformationBase.InternalBase.DisplayBase.MarkList[i]

            if flag then
                flag:setChecked(false)
            end
        end
    end
end

function Cyclopedia.moveMap(widget)
    local distance = 5
    local direction = widget:getId()

    if direction == "n" then
        UI.MapBase.minimap:move(0, distance)
    elseif direction == "ne" then
        UI.MapBase.minimap:move(-distance, distance)
    elseif direction == "e" then
        UI.MapBase.minimap:move(-distance, 0)
    elseif direction == "se" then
        UI.MapBase.minimap:move(-distance, -distance)
    elseif direction == "s" then
        UI.MapBase.minimap:move(0, -distance)
    elseif direction == "sw" then
        UI.MapBase.minimap:move(distance, -distance)
    elseif direction == "w" then
        UI.MapBase.minimap:move(distance, 0)
    elseif direction == "nw" then
        UI.MapBase.minimap:move(distance, distance)
    end
end

function Cyclopedia.floorScrollBar(oldValue, value)
    if value < oldValue then
        UI.MapBase.minimap:floorUp()
    elseif oldValue < value then
        UI.MapBase.minimap:floorDown()
    end

    if value < 0 then
        value = 0
    elseif value > 15 then
        value = 15
    end
end



function ConvertLayer(Value)
	if Value == 150 then
		return 7
	elseif Value == 300 then
		return 15
	elseif Value >= 1 and Value <= 300 then
		return math.floor((Value - 1) / 20)
	else
		return 0
	end
end


function Cyclopedia.onUpdateCameraPosition()
	local player = g_game.getLocalPlayer()
	local minimapWidget =  UI.MapBase.minimap

	if not player then
		return
	end

	local pos = player:getPosition()

	if not pos then
		return
	end

	if not minimapWidget:isDragging() then
		if not fullmapView then
			minimapWidget:setCameraPosition(player:getPosition())
		end

		minimapWidget:setCrossPosition(player:getPosition(), true)
	end

	UI.InformationBase.InternalBase.NavigationBase.LayerScrollbar:setValue(150)
end