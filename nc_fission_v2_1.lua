c = require("component")
t = require("term")
fisr = c.nc_fission_reactor

local x = fisr.getLengthX()
local y = fisr.getLengthY()
local z = fisr.getLengthZ()
local size = string.format("%s*%s*%s", x, y, z)
local max_rf = fisr.getMaxEnergyStored()
local max_hu = fisr.getMaxHeatLevel()
local mult_rf = fisr.getEfficiency() .. "%"
local mult_hu = fisr.getHeatMultiplier() .. "%"
local no_cells = fisr.getNumberOfCells()



function fuelStats()
	fuel = fisr.getFissionFuelName()
	fuel_base = string.format("%s RF/t - %s HU/t", fisr.getFissionFuelPower(), fisr.getFissionFuelHeat())
	rf_t = fisr.getReactorProcessPower() .. " RF/t"
	net_hu = fisr.getReactorProcessHeat() .. " HU/t"
	return fuel, fuel_rf_t, fuel_hu_t, rf_t, net_hu
end

function currentProcess()
	rf = fisr.getEnergyStored()
	hu = fisr.getHeatLevel()
	rf_lvl = string.format("%s/%s RF", rf, max_rf)
	hu_lvl = string.format("%s/%s HU", hu, max_hu)
	timeleft = (fisr.getReactorProcessTime() - fisr.getCurrentProcessTime()/no_cells)/20 .. " sec"
	return rf, hu, timeleft
end

function reactorControl()
	if rf/max_rf > 0.4 or hu/max_hu > 0.2 then
		fisr.deactivate()
	else
		fisr.activate()
	end
end

function reactorStatus()
	status = fisr.isProcessing()
	if status then
		stat = "Active"
	else
		if hu/max_hu > 0.2 then
			stat = "Inactive - Cooling"
		elseif rf/max_rf > 0.4 then
			stat = "Inactive - Discharging"
		else
			stat = "Inactive - " .. fisr.getProblem()
		end
	end
	return stat
end

function infoOutput()
	fisrStatsNames = {"Size: ", "Cells: ", "Eff. Mult.: ", "Heat Mult.: ", "Energy: ", "Heat Level: ", "Status: "}
	fisrStats = {size, no_cells, mult_rf, mult_hu, rf_lvl, hu_lvl, stat}
	fuelInfoNames = {"Fuel: ", "Base Power-Heat: ", "Energy Gen: ", "Net Heat: ", "Time Left: "}
	fuelInfo = {fuel, fuel_base, rf_t, net_hu, timeleft}
end

function fisrInit()
	fuelStats()
	currentProcess()
	reactorControl()
	reactorStatus()
	print("Reactor Info")
	for i = 1, 7 do
		print(fisrStatsNames[i] .. fisrStats[i])
	end
	print("Fuel Info")
	for i = 1, 5
		print(fuelInfoNames[i] .. fuelInfo[i])	
	end
end

function fisrRun()
	while timeleft > 0 do
		currentProcess()
		reactorControl()
		reactorStatus()
		infoOutput()
		local clearLines = {6, 7, 8, 14}
		for i = 1, 4 do
			t.setCursor(1, clearLines[i])
			t.clearLine()
			if clearLines[i] ~= 14 then
				print(fisrStatsNames[v3-1] .. fisrStats[fisrStatsNames[v3-1]])
			else
				print(fuelInfoNames[v3-9] .. fuelInfo[fuelInfoNames[v3-9]])
			end
		end
		os.sleep(0.7)
	end
end

t.clear()
fisrInit()
fisrRun()
		
		
	