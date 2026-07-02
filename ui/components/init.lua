local Components = {}
Components.setTheme = require("ui.components.theme").setTheme
Components.getTheme = require("ui.components.theme").getTheme
Components.currentTheme = require("ui.components.theme").currentTheme
Components.drawPanel = require("ui.components.panel").draw
Components.drawButton = require("ui.components.widgets").drawButton
Components.drawLabel = require("ui.components.widgets").drawLabel
Components.drawValue = require("ui.components.widgets").drawValue
Components.drawSlider = require("ui.components.widgets").drawSlider
Components.drawIconBar = require("ui.components.widgets").drawIconBar
Components.isInRect = require("ui.components.helpers").isInRect
Components.formatNumber = require("ui.components.helpers").formatNumber
return Components
