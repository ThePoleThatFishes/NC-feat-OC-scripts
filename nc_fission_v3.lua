local c = require("component")
local t = require("term")
local event = require("event")
local fisr = c.nc_fission_reactor

print("Welcome to Fission Controller v3 - by ThePoleThatFishes")
print("Hold Q to quit, U to force an update. (If stats are looking wrong!)")
os.sleep(1)
print("This message will self destruct in 5 seconds.")
print("After the self-destruction, the script will begin.")
os.sleep(5)

local x = fisr.getLengthX()
local y = fisr.getLengthY()
local z = fisr.getLengthZ()
local size = string.format("%s*%s*%s", x, y, z)
local max_rf = fisr.getMaxEnergyStored()
local max_hu = fisr.getMaxHeatLevel()
local mult_rf = fisr.getEfficiency() .. "%"
local mult_hu = fisr.getHeatMultiplier() .. "%"
local no_cells = fisr.getNumberOfCells()
local k = 1


local function fuelStats()
	fuel = fisr.getFissionFuelName()
	fuel_base = string.format("%s RF/t - %s HU/t", fisr.getFissionFuelPower(), fisr.getFissionFuelHeat())
	rf_t = fisr.getReactorProcessPower() .. " RF/t"
	net_hu = fisr.getReactorProcessHeat() .. " HU/t"
	return fuel, fuel_rf_t, fuel_hu_t, rf_t, net_hu
end

local function currentProcess()
	rf = fisr.getEnergyStored()
	hu = fisr.getHeatLevel()
	rf_lvl = string.format("%s/%s RF", rf, max_rf)
	hu_lvl = string.format("%s/%s HU", hu, max_hu)
	timeleft = (fisr.getReactorProcessTime() - fisr.getCurrentProcessTime()/no_cells)/20
	return rf, hu, timeleft
end

local function reactorControl()
	if rf/max_rf > 0.4 or hu/max_hu > 0.2 then
		fisr.deactivate()
	else
		fisr.activate()
	end
end

local function reactorStatus()
	if fisr.isProcessing() then
		stat = "Active"
	else
		if hu/max_hu > 0.2 then
			stat = "Inactive - Cooling"
		elseif rf/max_rf > 0.4 then
			stat = "Inactive - Discharging"
		elseif fuel == "No Fuel" then
			stat = "Inactive - No Fuel"
		else
			stat = "Inactive - " .. fisr.getProblem()
		end
	end
	return stat
end

local function infoOutput()
	fisrStatsNames = {"Size: ", "Cells: ", "Eff. Mult.: ", "Heat Mult.: ", "Energy: ", "Heat Level: ", "Status: "}
	fisrStats = {size, no_cells, mult_rf, mult_hu, rf_lvl, hu_lvl, stat}
	fuelInfoNames = {"Fuel: ", "Base Power-Heat: ", "Energy Gen: ", "Net Heat: ", "Time Left: "}
	fuelInfo = {fuel, fuel_base, rf_t, net_hu, string.format("%.1f sec", timeleft)}
end

function fisrInit()
	fuelStats()
	currentProcess()
	reactorControl()
	reactorStatus()
	infoOutput()
	print("Reactor Info")
	for i = 1, 7 do
		print(fisrStatsNames[i] .. fisrStats[i])
	end
	print("Fuel Info")
	for i = 1, 5 do
		print(fuelInfoNames[i] .. fuelInfo[i])	
	end
end

function fisrRun()
	while k > 0 do
		local ev, ad, chr, code, player = event.pull(0.35)
		if ev == "key_down" and chr == 113 then
			print("Quitting...")
			break
		end
		if ev == "key_down" and chr == 117 then
			t.clear()
			fisrInit()
		end
		currentProcess()
		reactorControl()
		reactorStatus()
		infoOutput()
		local clearLines = {6, 7, 8, 14}
		for i = 1, 4 do
			t.setCursor(1, clearLines[i])
			t.clearLine()
			if clearLines[i] ~= 14 then
				print(fisrStatsNames[i+4] .. fisrStats[i+4])
			else
				print(fuelInfoNames[i+1] .. fuelInfo[i+1])
			end
		end
		os.sleep(0.35)
	end
end

t.clear()
fisrInit()
fisrRun()
		
		
	
