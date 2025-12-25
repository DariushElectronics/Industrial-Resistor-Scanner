classdef Preprocessor
    methods (Static)
        function [resized, gray, doubleImg] = process(rawImg, cfg)
            % 1. Resize for performance
            scale = cfg.acquisition.processWidth / size(rawImg, 2);
            resized = imresize(rawImg, scale);
            
            % 2. Denoise
            denoised = imguidedfilter(resized);
            
            % 3. Convert Types
            gray = rgb2gray(denoised);
            doubleImg = im2double(denoised);
        end
    end
end
