function [d,g] = diffusion_coefficient_fit(tracks,framerate,microns_per_pixel,magnification,minD)

lastlabel = length(tracks);
d = struct('x',zeros(lastlabel,1),'y',zeros(lastlabel,1),'D',zeros(lastlabel,1));
g = zeros(length(tracks),1);

k=1;
for i=1:lastlabel
    
    if length(tracks(i).x)>99
        dr2 = zeros(1,floor(length(baci)/2));
        stddr2 = zeros(1,floor(length(baci)/2));
        
        for m = 1:floor(length(baci)/2)
            
            dr2(m) = mean((tracks(i).x((m+1):end) - tracks(i).x(1:end-m)).^2 + (tracks(i).y((m+1):end) - tracks(i).y(1:end-m)).^2);
            stddr2(m) = std((tracks(i).x((m+1):end) - tracks(i).x(1:end-m)).^2 + (tracks(i).y((m+1):end) - tracks(i).y(1:end-m)).^2);
        end
        
        dt =((1:floor(length(baci)/2))/framerate)';
        %A=polyfit(x,dr2,1);
        [xData, yData] = prepareCurveData( dt, dr2 );
        
        % Set up fittype and options.
        ft = fittype( 'a*x', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = 40;
        
        % Fit model to data.
        [fitresult, gof] = fit( xData, yData, ft, opts );
        
        
        d.x(k) = mean(tracks(i).x);
        d.y(k) = mean(tracks(i).y);
        d.D(k) = fitresult.a*(microns_per_pixel/magnification)^2/4;
        g(i) = gof.rsquare;
        
        %d.D(k) = A(1)*(microns_per_pixel/20)^2/4;
        
        
        k = k+1;
    end
end

d.x(d.D<minD,:) = [];
d.y(d.D<minD,:) = [];
d.D(d.D<minD,:) = [];
d.D(g<0.98) = [];
g(g<0.98) = [];

end