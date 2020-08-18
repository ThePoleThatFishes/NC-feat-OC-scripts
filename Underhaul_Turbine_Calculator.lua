turbineStats = {...}

bladeStats = {{"stator", 0.75, 0.0},{"steel", 1.4, 1.0},{"extreme", 1.6, 1.1},{"sic", 1.8, 1.25}}
idealExp = turbineStats[1]
baseRFDensity = turbineStats[2]
idealExpList, actualExpList, rawEffs = {}, {}, {}
totalExp, bladeMult, bladeCount = 1.0, 0.0, 0

for i = 3, #turbineStats do
  for j = 1, 4 do
    if turbineStats[i] == bladeStats[j][1] then
      if j ~= 1 then
        bladeCount = bladeCount + 1
      end
      prevExp = totalExp
      idealExpList[i] = math.pow(idealExp, (i - 2.5)/(#turbineStats - 2))
      totalExp = totalExp * bladeStats[j][2]
      rawEffs[i] = bladeStats[j][3]
      actualExpList[i] = (prevExp + totalExp)/2
      bladeMult = bladeMult + (rawEffs[i]*(math.min(idealExpList[i],actualExpList[i])/math.max(idealExpList[i],actualExpList[i])))
      break
    end
  end
end


bladeMult = bladeMult / bladeCount
RFDensity = baseRFDensity*bladeMult*(math.min(idealExp,totalExp)/math.max(idealExp,totalExp))
print(string.format("For expansion %s, energy density %s RF/mB and the given blade combination: ", idealExp, baseRFDensity))
print(string.format("Expansion: %.2f%%", totalExp*100))
print(string.format("Energy Density: %.2f RF/mB [Does not include coil bonus!]", RFDensity))
