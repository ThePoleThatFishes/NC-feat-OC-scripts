c = require("component")
t = require("term")
fusr = c.nc_fusion_reactor
t.clear()

local size = fusr.getToroidSize()
local fuel1 = fusr.getFirstFusionFuel()
local fuel2 = fusr.getSecondFusionFuel()
local bestMK = fusr.getFusionComboHeatVariable()*1.21875567483
local combo_rf = fusr.getFusionComboPower()*100
local combo_time = fusr.getFusionComboTime()

function stats()
	rf_t = fusr.getReactorProcessPower()
	eff = fusr.getEfficiency()/100
	tempMK = fusr.getTemperature()/1e6
	if fusr.isProcessing() then
		stat = "Active"
	elseif (1 - tempMK/bestMK) < 0.002 then
		stat = "Inactive - Cooling Down"
	else
		stat = fusr.getProblem()
	end
	fusrINames = {"Size: ", "Fuel Combo: ", "Combo RF/t - Lifetime: ", "Temp/Optimal Temp: ", "Energy Gen: ", "Efficiency: ", "Status: "}
	fusrI = {size, string.format("%s/%s", fuel1, fuel2), string.format("%s RF/t - %s t", combo_rf, combo_time), string.format("%s MK/%s MK", tempMK, bestMK),
		string.format("%.1f RF/t", rf_t), string.format("%.3f", eff), stat}
end
 
for i = 1, 3 do
	print(fusrINames[i] .. fusrI[i])
end

timer = 1200 --can run for 10 mins straight
while timer > 0 do
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
	timer = timer - 1
end

		

	
