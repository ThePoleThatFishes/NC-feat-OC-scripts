local c = require("component")
local t = require("term")
local event = require("event")
local fusr = c.nc_fusion_reactor

print("Welcome to Fusion Controller v2 by ThePoleThatFishes!")
print("Hold down Q to quit, U to force updates. (If stats are looking wrong!)")
os.sleep(1)
print("This message will self destruct in 5 seconds.")
os.sleep(5)
t.clear()

local function fusrStats()
	size = fusr.getToroidSize()
	fuel1 = fusr.getFirstFusionFuel()
	fuel2 = fusr.getSecondFusionFuel()
	bestMK = fusr.getFusionComboHeatVariable()*1.21875567483
	combo_rf = fusr.getFusionComboPower()*100
	combo_time = fusr.getFusionComboTime()
end

function stats()
	rf_t = fusr.getReactorProcessPower()
	eff = fusr.getEfficiency()/100
	tempMK = fusr.getTemperature()/1e6
	if fusr.isProcessing() then
		stat = "Active"
	elseif (1 - tempMK/bestMK) < 0.002 or tempMK >= 19500 then
		stat = "Inactive - Cooling"
	elseif tempMK < 8 then
		stat = "Inactive - Has not ignited"
	elseif fuel1 == "Empty" or fuel2 == "Empty" then
		stat = "Inactive - Out of fuel"
	end
	fusrINames = {"Toroid Size: ", "Fuel Combo: ", "Combo RF/t - Lifetime: ", "Temp/Optimal Temp: ", "Energy Gen: ", "Efficiency: ", "Status: "}
	fusrI = {size, string.format("%s/%s", fuel1, fuel2), string.format("%s RF/t - %s t", combo_rf, combo_time),
				string.format("%.1f MK/%.1f MK", tempMK, bestMK), string.format("%.1f RF/t", rf_t), string.format("%.3f", eff), stat}
end

fusrStats()
stats()
for i = 1, 3 do
	print(fusrINames[i] .. fusrI[i])
end

k = 1
while k > 0 do
	local ev, ad, chr, code, player = event.pull(0.5)
	if ev == "key_down" and chr == 113 then
		print("Quitting...")
		break
	end
	if ev == "key_down" and chr == 117 then
		fusrStats()
		t.clear()
		for i = 1,7 do
			print(fusrINames[i] .. fusrI[i])
		end
	end
	stats()
	if (1 - tempMK/bestMK) < 0.002 then
		fusr.deactivate()
	else
		fusr.activate()
	end
	for i = 4, 7 do
		t.setCursor(1,i)
		t.clearLine()
		print(fusrINames[i] .. fusrI[i])
	end
	os.sleep(0.5)
end

