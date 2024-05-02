classdef SpecificKeyListener < handle
    properties
        keyPressed = false;
    end
    
    methods
        function obj = SpecificKeyListener()
            obj = obj@handle();
        end
        
        function keyTyped(obj, event)
            if event.getKeyChar() == 'x'
                obj.keyPressed = true;
            end
        end
    end
end
