function bacpos = centers_gaussian_fit(obj,writerObj,numFrames,fileName,radius,minArea,maxArea,eccentricity,sigma,options)
% FIT CENTERS FUNCTION DYH 2019.6.11


sx = fspecial('sobel');
sy = sx';

se = strel('disk',radius);

centers = cell( 50, numFrames );

frame(1:numFrames, 1:50) = struct('Pos',[]);

figure(1);

for i = 1 : numFrames
    
    frame1 = read(obj,i);       % 读取每一帧
    disp(['数据处理中...',num2str(i),'/',num2str(numFrames)]);
    
    f=frame1(:,:,1);
    f2 = tofloat(f);
    
    %% 基于梯度的边缘信息
    gx = imfilter(f2, sx ,'replicate');
    gy = imfilter(f2, sy ,'replicate');
    grad = sqrt(gx.*gx + gy.*gy);
    grad = grad/max(grad(:));
    
    h = imhist(grad);
    Q = percentile2i(h,0.995);
    
    markerImage = grad > Q;
    
    
    %% 提取边界像素
    
    g1 = bwperim(markerImage);
    
    
    %% 填充孔洞
    
    g2 = imfill(g1,4,'holes');
    
    
    %% 圆形膨胀
    
    g3 = imdilate(g2,se);
    
    
    %% 质心定位
    
    s = regionprops('table',g3,'Area','Eccentricity');
    
    idx = find([s.Area] > minArea & [s.Eccentricity] < eccentricity & [s.Area] < maxArea);
    cc = bwconncomp(g3);
    g = ismember(labelmatrix(cc), idx);
    [L,n] = bwlabel(g);
    
    centroids = zeros(n,2);
    
    %% Gaussian fit centers
    for q = 1:n
        
        [r, c] = find(L==q);
        Z = f(min(r):max(r),min(c):max(c))-min(min(f(min(r):max(r),min(c):max(c))))-(max(max(f(min(r):max(r),min(c):max(c))))-min(min(f(min(r):max(r),min(c):max(c)))))/sigma;
        
        amp = double(max(max(Z)));
        [peak_R, peak_C] = find(Z==amp);
        peak_mR = mean(peak_R);
        peak_mC = mean(peak_C);
        stdev = 3;
        v = [amp peak_mR stdev peak_mC];
        [R, C] = find(Z~=0);
        Z = double(Z(Z~=0));
        
        aa = fminsearch(@gauss2DY,v,options,R,C,Z);
        centroids(q,2) = aa(2)+ min(r)-1;
        centroids(q,1) = aa(4)+ min(c)-1;
        
    end
    
    %s = regionprops('table',g,'Centroid','MajorAxisLength','MinorAxisLength');
    %centroids = cat(1, s.Centroid);
    
    
    %% 分区域统计质心
    
    for j = 1:50
        [row,col] =  find(centroids(:,1)<40*j & centroids(:,1)>= 40*(j-1)) ;
        
        centers{j,i} = [centroids(row,1),centroids(row,2)];
        
        frame(i,j).Pos(:,1:2) = centers{j,i};
        frame(i,j).Pos(:,3) = i;
        
    end
    
    %% 绘图质心
    
    
    imshow(f);
    hold on
    plot(centroids(:,1),centroids(:,2), 'r.')
    
    
    
    hold off
    
    
    %% write avi
    frame2 = getframe;            %// 把图像存入视频文件中
    writeVideo(writerObj,frame2); %// 将帧写入视频
    
    
end
close(writerObj); %// 关闭视频文件句柄
close(figure(1));


bacpos(1:50) = struct('Pos',[]);
for j = 1:50
    bacpos(j).Pos(:,1:3) = cell2mat((cell({frame(:,j).Pos}))');
    
end

save(['F:\实验室\暑假课题\DYH实验数据\brown\2019.5.23\processedgauss\' fileName(1:end-3) 'mat'],'pos');

end