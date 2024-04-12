local element = Element.getById('widget')

element:addEventListener('onMouseEnter', function(event)
    print('ENTER')
    element.origin = Point.fromOffset(15, 35)
end)

element:addEventListener('onMouseLeave', function(event)
    print('LEAVE')
    element.origin = Point.fromOffset(10, 30)
end)