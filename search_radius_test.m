function search_radius_test(pos,microns_per_pixel,magnification)
tic
sp = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 5.0];
tranum = zeros(1,length(sp));

for i = 1:length(sp)
    for j = 1:50
    tracks = TrackBeads(pos(j).Pos,microns_per_pixel,sp(i),magnification);
    tranum(i) = tranum(i)+length(tracks);
    end
end
plot(sp,tranum,'b-.');

toc
end
