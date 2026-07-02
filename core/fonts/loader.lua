local Loader = {}

local loadedFontData

function Loader.getFont(size)
  size = size or 14
  if loadedFontData then
    local ok, font = pcall(love.graphics.newFont, loadedFontData, size)
    if ok and font then
      return font
    end
  end
  return love.graphics.newFont(size)
end

function Loader.setGlobalFont(langCode, size)
  local fontSize = size or 14
  local font

  local function tryLoad(path)
    local ok, result = pcall(love.graphics.newFont, path, fontSize)
    if ok and result then
      return result
    end
    if path:sub(1, 1) == "/" then
      local ok2, fh = pcall(io.open, path, "rb")
      if ok2 and fh then
        local data = fh:read("*all")
        fh:close()
        if data then
          loadedFontData = love.filesystem.newFileData(data, path:match("[^/]+$"))
          local ok3, result3 = pcall(love.graphics.newFont, loadedFontData, fontSize)
          if ok3 and result3 then
            return result3
          end
          loadedFontData = nil
        end
      end
    end
    return nil
  end

  if langCode == "zh" then
    local candidates = {
      "assets/fonts/NotoSansCJK-VF.ttc",
      "assets/fonts/NotoSansSC-Regular.otf",
      "assets/fonts/wqy-microhei.ttc",
      "/usr/share/fonts/google-noto-sans-cjk-vf-fonts/NotoSansCJK-VF.ttc",
      "/usr/share/fonts/google-droid-sans-fonts/DroidSansFallbackFull.ttf",
      "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
      "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
      "C:/Windows/Fonts/msyh.ttc",
      "C:/Windows/Fonts/msyhbd.ttc",
      "C:/Windows/Fonts/simhei.ttf",
      "C:/Windows/Fonts/simsun.ttc",
      "C:/Windows/Fonts/meiryo.ttc",
      "/System/Library/Fonts/PingFang.ttc",
      "/System/Library/Fonts/STHeiti Light.ttc",
    }
    for _, path in ipairs(candidates) do
      font = tryLoad(path)
      if font then
        break
      end
    end
  end

  if not font then
    font = love.graphics.newFont(fontSize)
  end

  love.graphics.setFont(font)
  return font
end

return Loader
