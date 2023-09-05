function tracks = TrackBeads(pos,micron_per_pixel,micron_search_radius,magnification)

pixel_per_micron = 1/micron_per_pixel;
pixel_search_radius = micron_search_radius*pixel_per_micron*magnification;

x = pos(:,1)';
y = pos(:,2)';
frame = pos(:,3);

spanA = find(frame==min(frame));
baclabel = zeros(length(frame),1);
baclabel(1:length(spanA)) = 1:length(spanA);
lastlabel = length(spanA);

for i = min(frame):max(frame)-1     % loop over all frame(i),frame(i+1) pairs.
    spanA = find(frame==i);
    spanB = find(frame==i+1);
    dx = ones(length(spanA),1)*x(spanB) - x(spanA)'*ones(1,length(spanB));
    dy = ones(length(spanA),1)*y(spanB) - y(spanA)'*ones(1,length(spanB));
    dr2 = dx.^2 + dy.^2;
    dr2test=(dr2<pixel_search_radius^2);
    
    dr2test(sum(dr2test~=0,2)>1,:) = false;
    dr2test(:,sum(dr2test~=0,1)>1) = false;
    
    [R,C] = find(dr2test);
    OC = setdiff(1:size(dr2test,2),C);
    
    from=spanA(R); to=spanB(C); orphan=spanB(OC);
    baclabel(to) = baclabel(from);
    if ~isempty(orphan)
        baclabel(orphan) = lastlabel+(1:length(orphan));
        lastlabel = lastlabel+length(orphan);
    end
end

tracks(1:lastlabel) = struct('x',zeros(max(frame),1),'y',zeros(max(frame),1));
for i=1:lastlabel
    
    baci = find(baclabel==i);
    tracks(i).x = x(baci);
    tracks(i).y = y(baci);
    
end

