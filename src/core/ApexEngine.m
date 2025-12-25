classdef ApexEngine
    methods (Static)
        function result = analyze(resistorImg, cfg)
            % ENGINE: APEX v1.0 (The Ultimate Solution)
            Logger.info('Running ApexEngine...');
            
            % 1. Smart Edge Clipping (Remove Caps/Wires)
            [h, w, ~] = size(resistorImg);
            clipX = round(w * 0.12); % 12% clipping
            roiImg = resistorImg(:, clipX:(w-clipX), :);
            
            % 2. Lab Space Processing
            img = double(roiImg);
            normImg = uint8(img);
            labImg = rgb2lab(normImg);
            
            [rh, ~, ~] = size(labImg);
            strip = labImg(floor(rh*0.4):floor(rh*0.6), :, :);
            
            sigL = smoothdata(median(strip(:,:,1),1), 'gaussian', 15);
            sigA = smoothdata(median(strip(:,:,2),1), 'gaussian', 15);
            sigB = smoothdata(median(strip(:,:,3),1), 'gaussian', 15);
            
            bgL = median(sigL); bga = median(sigA); bgb = median(sigB);
            deltaE = sqrt((sigL-bgL).^2 + (sigA-bga).^2*2.5 + (sigB-bgb).^2*2.5);
            
            % 3. Peak Detection
            [pks, locs] = findpeaks(deltaE, 'MinPeakProminence', 15, 'MinPeakDistance', 20, 'MinPeakWidth', 8);
            
            % Weak Band Recovery
            if length(locs) >= 3 && length(locs) < 6
                 avgD = mean(diff(locs));
                 expPos = locs(end) + avgD;
                 if expPos < length(deltaE)
                     rng = round(expPos-15:min(expPos+15, length(deltaE)));
                     if ~isempty(rng)
                         [m, i] = max(deltaE(rng));
                         if m > 5, locs = [locs, rng(1)+i-1]; end
                     end
                 end
            end
            
            % Filter Top 6 Bands
            if length(locs) > 6
                [~, sortIdx] = sort(pks, 'descend');
                keepIdx = sort(sortIdx(1:6));
                locs = locs(keepIdx);
            end
            
            % 4. Color Matching
            detectedColors = {}; codes = [];
            for i=1:length(locs)
                idx = locs(i);
                [name, code] = ApexEngine.matchIEC(sigL(idx), sigA(idx), sigB(idx));
                detectedColors{end+1} = name; codes(end+1) = code;
            end
            
            % 5. Output Generation
            result.numBands = length(locs);
            result.colors = detectedColors;
            result.signal = deltaE;
            result.locs = locs;
            result.roi = roiImg;
            result.rep = ApexEngine.calculate(codes, detectedColors);
        end
        
        function [name, code] = matchIEC(L, a, b)
            iec = {'Black',0,[15,0,0]; 'Brown',1,[30,20,20]; 'Red',2,[45,50,30];
                   'Orange',3,[60,40,60]; 'Yellow',4,[85,5,85]; 'Green',5,[50,-35,20];
                   'Blue',6,[30,10,-50]; 'Violet',7,[30,35,-35]; 'Grey',8,[55,0,0];
                   'White',9,[90,0,0]; 'Gold',-1,[65,10,50]; 'Silver',-2,[75,0,0]};
            minD=inf; name='?'; code=NaN;
            for k=1:size(iec,1)
                r=iec{k,3};
                d=sqrt((L-r(1))^2*0.8 + (a-r(2))^2*1.2 + (b-r(3))^2*1.2);
                if d<minD, minD=d; name=iec{k,1}; code=iec{k,2}; end
            end
            if b<-45, name='Blue'; code=6; end
            if (strcmp(name,'Red')||strcmp(name,'Orange')) && L<32, name='Brown'; code=1; end
        end
        
        function rep = calculate(codes, names)
            n = length(codes);
            rep.type = sprintf('%d-Band Generic', n); rep.tcrStr = '';
            if n == 6
                digits=codes(1:3); mult=codes(4); tolCode=codes(5); tcrCode=codes(6);
                rep.type = '6-Band High Precision';
                ts=0; if tcrCode==1, ts=100; elseif tcrCode==2, ts=50; elseif tcrCode==3, ts=15; elseif tcrCode==4, ts=25; elseif tcrCode==6, ts=10; end
                if ts>0, rep.tcrStr = sprintf('TCR: %d ppm/K', ts); end
            elseif n == 5
                digits=codes(1:3); mult=codes(4); tolCode=codes(5); rep.type='5-Band Precision';
            elseif n == 4
                digits=codes(1:2); mult=codes(3); tolCode=codes(4); rep.type='4-Band Standard';
            else, rep.val='Error'; rep.tol=''; return; end
            
            base=0; for k=1:length(digits), base=base*10+digits(k); end
            if mult==-1, m=0.1; elseif mult==-2, m=0.01; else, m=10^mult; end
            val = base * m;
            
            if val>=1e6, rep.val=sprintf('%.2f M Ohms', val/1e6); 
            elseif val>=1e3, rep.val=sprintf('%.2f k Ohms', val/1e3); 
            else, rep.val=sprintf('%.0f Ohms', val); end
            
            t=20; if tolCode==-1, t=5; elseif tolCode==-2, t=10; elseif tolCode==1, t=1; elseif tolCode==2, t=2; end
            rep.tol = sprintf('+/- %g%%', t);
        end
    end
end
