local GUI = require("GUI")
local system = require("System")
local computer = require("computer")
local component = require("component")

-- Создаем главное окно приложения (ширина 60, высота 20)
local window = GUI.window(1, 1, 60, 20)

-- Фоновая панель
window:addChild(GUI.panel(1, 1, window.width, window.height, 0xF0F0F0))

-- Заголовок
local title = window:addChild(GUI.label(1, 2, window.width, 1, 0x2D2D2D, "MineOS Benchmark Tool"))
title:setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_CENTER)

-- Текстовые метки для вывода информации и результатов
local ramTotal = math.floor(computer.totalMemory() / 1024)
local ramLabel = window:addChild(GUI.label(3, 5, 54, 1, 0x2D2D2D, "ОЗУ (RAM): " .. ramTotal .. " КБ"))
local cpuLabel = window:addChild(GUI.label(3, 7, 54, 1, 0x2D2D2D, "CPU Test: Ожидание запуска..."))
local scoreLabel = window:addChild(GUI.label(3, 9, 54, 1, 0x2D2D2D, "Итоговый балл: ---"))

-- Кнопка запуска теста
local startButton = window:addChild(GUI.button(15, 14, 30, 3, 0x3C3C3C, 0xFFFFFF, 0x2D2D2D, 0xFFFFFF, "Запустить тест"))

startButton.onTouch = function()
    cpuLabel.text = "CPU Test: Выполняется нагрузка..."
    scoreLabel.text = "Итоговый балл: считаем..."
    window:draw()

    -- Имитируем тяжелую математическую нагрузку для процессора
    local iterations = 400000
    local startTime = computer.uptime()
    
    local val = 0
    for i = 1, iterations do
        val = val + math.sqrt(i) * math.sin(i)
    end
    
    local endTime = computer.uptime()
    local duration = endTime - startTime
    if duration < 0.01 then duration = 0.01 end -- Защита от деления на ноль на мощных серверах

    -- Вычисляем условный балл (чем быстрее прошли итерации, тем выше балл)
    local score = math.floor(iterations / duration)

    -- Выводим результаты
    cpuLabel.text = string.format("CPU Test: %.3 сек (%d итераций)", duration, iterations)
    scoreLabel.text = "Итоговый балл производительности: " .. score
    window:draw()
end

-- Кнопка закрытия приложения ("X")
local closeButton = window:addChild(GUI.button(window.width - 2, 1, 3, 1, 0xCC4444, 0xFFFFFF, 0xFF0000, 0xFFFFFF, "X"))
closeButton.onTouch = function()
    window:remove()
    system.getTopWindow():remove()
end

-- Отрисовываем окно на экране
window:draw()