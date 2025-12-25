classdef GeometryEngine
    methods (Static)
        function [straightImg, rotAngle] = normalize(maskedRGB, mask, cfg)
            % Detect Orientation
            props = regionprops(mask, 'Orientation', 'BoundingBox');
            if isempty(props)
                straightImg = maskedRGB; rotAngle = 0; return;
            end
            
            % Sort by area (largest is resistor)
            [~, idx] = max([props.Area] if isfield(props,'Area') else 1); 
            rotAngle = -props(idx).Orientation;
            
            % Rotate
            straightImg = imrotate(maskedRGB, rotAngle, 'bicubic', 'crop');
            maskRot = imrotate(mask, rotAngle, 'nearest', 'crop');
            
            % Auto Crop
            [r, c] = find(maskRot);
            if ~isempty(r)
                straightImg = straightImg(min(r):max(r), min(c):max(c), :);
            end
        end
    end
end
