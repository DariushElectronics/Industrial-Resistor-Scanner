classdef Segmentor
    methods (Static)
        function [mask, maskedRGB] = segment(grayImg, colorImg, cfg)
            % Otsu Thresholding
            thresh = graythresh(grayImg);
            bin = imbinarize(grayImg, thresh);
            
            % Invert if background is white (common in resistor photos)
            if mean(bin(:)) > 0.5
                bin = ~bin;
            end
            
            % Morphological Cleanup
            bin = imclose(bin, strel('disk', 5));
            bin = bwareaopen(bin, 1000); % Remove small noise
            
            % Convex Hull for solid shape
            mask = bwconvhull(bin);
            
            % Apply Mask
            maskedRGB = colorImg;
            maskedRGB(repmat(~mask, [1 1 3])) = 0;
        end
    end
end
