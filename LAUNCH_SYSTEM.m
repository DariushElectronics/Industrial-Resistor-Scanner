% INDUSTRIAL RESISTOR SCANNER - LAUNCHER
clc; clear; close all;
disp('🚀 Initializing System...');

% Add source paths
addpath(genpath(fullfile(pwd, 'src')));

% Check Image
imageName = 'Resistor.png';
if ~exist(imageName, 'file')
    error(['❌ Error: Please upload "' imageName '" to the project folder.']);
end

try
    disp('⚙️ Starting APEX Engine Analysis...');
    
    cfg = AppConfig();
    raw = imread(imageName);
    
    % Pipeline Execution
    [~, gray, ~] = Preprocessor.process(raw, cfg);
    [mask, masked] = Segmentor.segment(gray, raw, cfg);
    [final, ~] = GeometryEngine.normalize(masked, mask, cfg);
    
    % Analysis
    data = ApexEngine.analyze(final, cfg);
    rep = data.rep;
    
    % Report
    figure('Name', 'FINAL APEX REPORT', 'Color', 'w');
    subplot(5,1,1); imshow(final); title('Corrected Geometry');
    subplot(5,1,2); imshow(data.roi); title('Smart Edge Clipping');
    subplot(5,1,3); 
    plot(data.signal, 'LineWidth', 2); grid on; hold on;
    plot(data.locs, data.signal(data.locs), 'rv', 'MarkerFaceColor', 'r');
    title(['Detected Bands: ' num2str(data.numBands)]);
    
    subplot(5,1,[4 5]); axis off;
    text(0.5, 0.9, 'APEX INDUSTRIAL CERTIFIED', 'Horiz', 'center', 'FontWeight', 'bold', 'FontSize', 14);
    text(0.5, 0.75, strjoin(data.colors, ' - '), 'Horiz', 'center', 'FontSize', 12, 'Color', [0.3 0.3 0.3]);
    text(0.5, 0.55, rep.val, 'Horiz', 'center', 'FontSize', 30, 'Color', 'b', 'FontWeight', 'bold');
    text(0.5, 0.35, rep.tol, 'Horiz', 'center', 'FontSize', 22, 'Color', [0 0.6 0], 'FontWeight', 'bold');
    if ~isempty(rep.tcrStr)
        text(0.5, 0.15, rep.tcrStr, 'Horiz', 'center', 'FontSize', 16, 'Color', [0.8 0.4 0], 'FontWeight', 'bold');
    end
    
    disp('✅ Report Generated Successfully.');
    
catch ME
    disp(['❌ Runtime Error: ' ME.message]);
end
