local root = Element.getById('widget')
print(root.padding)

local function scaleElement(element, amount)
    -- 0 is - amount / 2
    -- 0.5 is + 0
    -- 1 is + amount / 2
    local offsetX, offsetY = element.anchorPoint.x - 0.5, element.anchorPoint.y - 0.5
    print(offsetX, offsetY)
    element.origin = element.origin + Scaled2.new(amount.x.scale * offsetX / 2, 0, amount.y.scale * offsetY, 0) -- - Scaled2.new(offset.x.scale * anchorX, offset.x.offset * anchorX, offset.y.scale * anchorY, offset.y.offset * anchorY)
    element.size = element.size + amount
end

for i = 3, 4 do
    local element = root.children[i]

    element:addEventListener('onMouseEnter', function(event)
        -- scaleElement(element, Scaled2.fromScale(0.15, 0.15))
    end)
    
    element:addEventListener('onMouseLeave', function(event)
        -- scaleElement(element, Scaled2.fromScale(-0.15, -0.15))
    end)
end

-- root:addEventListener('onMouseEnter', function(event)
--     scaleElement(root, Scaled2.fromScale(0.05, 0.05))
-- end)

-- root:addEventListener('onMouseLeave', function(event)
--     scaleElement(root, Scaled2.fromScale(-0.05, -0.05))
-- end)