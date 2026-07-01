local PortFees = {}

function PortFees.calculate(city, shipCargoValue)
  if not city.hasPort then return 0 end
  local fee = city.portFee or 2
  if shipCargoValue then
    fee = fee + math.floor(shipCargoValue * 0.01)
  end
  return fee
end

function PortFees.collect(city, shipCargoValue)
  local fee = PortFees.calculate(city, shipCargoValue)
  city.wealth = (city.wealth or 0) + fee
  return fee
end

return PortFees
