function slides_diffusion_coefficent_together(minfile,maxfile)

D_x =[];
D_y =[];
D_d =[];
figure(3);

for II=minfile:maxfile
    
    D = load(['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\' files(II).name(1:end-3) 'mat'],'D');
    for j = 1:50
        D_x =[D_x ; D.D{1,j}.x];
        D_y =[D_y ; D.D{1,j}.y];
        D_d =[D_d ; D.D{1,j}.D];
        
    end
    
end
%%
scatter3(D_x,D_y,D_d,10,D_d,'filled');
colorbar

hold on
str=strcat([' mean = ',num2str(mean(D_d)),'  std =',num2str(std(D_d)),'  median=',num2str(median(D_d))]);
title({files(II).name(1:end-4);str});

savefig(['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\together\' files(II).name(1:end-3) 'fig']);
saveas(gcf,['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\together\' files(II).name(1:end-3) '.png']) ;
%%
figure(4);
nbins = 50;

hist(D_d,nbins);

savefig(['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\together\' files(II-1).name(1:end-3) 'fig']);
saveas(gcf,['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\together\' files(II-1).name(1:end-3) '.png']) ;
close(figure(4));
end

