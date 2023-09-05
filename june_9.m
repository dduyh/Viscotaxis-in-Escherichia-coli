clear all;

tic;

files = dir('F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\*% Ficoll 1um *%bead_*.avi');

microns_per_pixel = 5.5;

figure(1);
close(figure(1));

figure(2);
ax1 = subplot(2,1,1);
colorbar
ax2 = subplot(2,1,2);

figure(3);
close(figure(3));

figure(4);
close(figure(4));

for II=1:length(files)
    
    %% Load the data.
    %%
    
    fileName = strcat('F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\',files(II).name);
    obj = VideoReader(fileName);
    numFrames = obj.NumberOfFrames;                     % 读取视频的帧数
    FrameRate= obj.FrameRate;
    
    
    %% output the data.
    %%
    
    writerObj=VideoWriter(strcat('F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\',files(II).name(1:end-4),'_processed.avi'));  %// 定义一个视频文件用来存动画
    writerObj.FrameRate = FrameRate;
    open(writerObj);                    %// 打开该视频文件
    
    %% 球心定位
    %%
    radius = 2;
    minArea = 20;
    maxArea = 100;
    eccentricity = 0.8;
    sigma = 5;
    options = optimset('Display','off','TolX',0.0000000001,...
        'TolFun',0.0000000001,...
        'MaxFunEvals',10000000,'MaxIter',10000000);
    
    pos = centers_gaussian_fit(obj,writerObj,numFrames,files(II).name,radius,minArea,maxArea,eccentricity,sigma,options);
    
    %% search_radius_test
    %%
    magnification = 30;  %20*1.5X
    search_radius_test(pos,microns_per_pixel,magnification)
    
    %%
    tracksall = cell( 1, 50 );
    
    micron_search_radius = 0.5;   %um
    
    
    D = cell( 1, 50 );
     G = cell( 1, 50 );
     
    for j = 1:50
        disp(['数据处理中...',num2str(j),'/',num2str(50)]);
        
        %% Track Beads
        %%
        
        tracks = TrackBeads(pos(j).Pos,microns_per_pixel,microns_search_radius,magnification);
         tracksall{1,j} = tracks;
         
        %% 计算Rsquare , 拟合斜率（扩散系数）
        %% 
        minD = 0.1;
        
        [d,g] = diffusion_coefficient_fit(tracks,FrameRate,microns_per_pixel,magnification,minD);
        D{1,j} = d;
        G{1,j} = g;
        
        clearvars tracks
    end   
    
    save(['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\' files(II).name(1:end-3) 'mat'],'tracksall','D','G','-append');
    
    figure(2);
    %% plot扩散系数
        %% 
    
    D_x =[];
    D_y =[];
    D_d =[];
    for j = 1:50
        D_x =[D_x ; D{1,j}.x];
        D_y =[D_y ; D{1,j}.y];
        D_d =[D_d ; D{1,j}.D];
        
    end
    
    scatter3(ax1,D_x,D_y,D_d,10,D_d,'filled');
    colorbar
    
    D_mean = zeros(1,50);
    
    for j = 1:50
        D_mean(j) =   mean(D{1,j}.D);
    end
    plot(ax2,1:50,D_mean,'o-');
    
    
    savefig(['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\' files(II).name(1:end-3) 'fig']);
    saveas(gcf,['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\' files(II).name(1:end-3) '.png']) ;
    %%
    clearvars -except files II microns_per_pixel ax1 ax2;
    
end

slides_diffusion_coefficent_together(11,20);
slides_diffusion_coefficent_together(21,30);
slides_diffusion_coefficent_together(31,40);
slides_diffusion_coefficent_together(41,50);
slides_diffusion_coefficent_together(51,60);
slides_diffusion_coefficent_together(61,70);
slides_diffusion_coefficent_together(71,80);
slides_diffusion_coefficent_together(81,90);
slides_diffusion_coefficent_together(91,100);
%%
toc    
    