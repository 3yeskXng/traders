local CityTax = {}

function CityTax.calculate(city)
  local baseTax = city.population * 0.1
  return math.floor(baseTax * city.taxRate)
end

function CityTax.collect(city)
  local tax = CityTax.calculate(city)
  city.wealth = (city.wealth or 0) + tax
  return tax
end

return CityTax
