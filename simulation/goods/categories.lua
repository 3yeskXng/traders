local Categories = {
  FOOD = "food",
  RAW = "raw",
  CRAFTED = "crafted",
  LUXURY = "luxury",
}

function Categories.isValid(cat)
  for _, v in pairs(Categories) do
    if v == cat then return true end
  end
  return false
end

return Categories
