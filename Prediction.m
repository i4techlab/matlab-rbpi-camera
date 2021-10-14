%% Clear/close
clear all
close all

%% Libraries that need to be imported for communications with Node-RED
import matlab.net.*
import matlab.net.http.*

%% AI Model that needs to be loaded
load trainedModelTFG.mat

%% Building HTTP request
url = 'http://10.7.0.25:20000/test1';

%% Image processing

% First step of processing the image is reading it
% decode image stream using Java
jImg = javax.imageio.ImageIO.read(java.io.ByteArrayInputStream(base64decode(webread(url))));
h = jImg.getHeight;
w = jImg.getWidth;

% convert Java Image to MATLAB image
p = reshape(typecast(jImg.getData.getDataStorage, 'uint8'), [3,w,h]);
Icolor = cat(3, ...
        transpose(reshape(p(3,:,:), [w,h])), ...
        transpose(reshape(p(2,:,:), [w,h])), ...
        transpose(reshape(p(1,:,:), [w,h])));
 
% Then it is shown in color/black & white/binary format
figure()
imshow(Icolor);
title('Color image');
I = rgb2gray((Icolor));
figure()
imshow(I);
title('Gray scale image');
% Noise supression
I = wiener2(I,[3 3]);
I = medfilt2(I);
BW = im2bw(I,0.65);
figure()
imshow(BW)
title('Binary image')

%% Classification of elements using picture in binary format
% Image properties extraction
L = bwlabel(BW);
numele = max(max(L));
stats = regionprops(L,'all');
Dades=struct2table(stats);
yfit=trainedModelTFG.predictFcn(Dades);
% Picture with elements found by the model
figure()
imshow(Icolor)
title('Color image with classified items')
hold on;
% Reset all counters, one for each type of piece (washers, nuts and bolts)
Contador_RoscaQuadrada=0; % Square thread
Contador_VolanderaPetita=0; % Small washer
Contador_VolanderaGran=0; % Big washer
Contador_FemellaOberta=0; % Open nut
Contador_CargolCilindric=0; % Cylindrical screw

for k=1:length(stats)
    thisboundingbox=stats(k).BoundingBox;
    
    if strcmp(yfit(k),'Rosca quadrada/Square thread');
    text(stats(k).Centroid(1),stats(k).Centroid(2),'Rosca quadrada/Square thread','Color','r');
    Contador_RoscaQuadrada=Contador_RoscaQuadrada+1;
    rectangle('Position',[thisboundingbox(1), thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)], 'EdgeColor','g','LineWidth',2);

    elseif strcmp(yfit(k),'Volandera petita/Small washer');
    text(stats(k).Centroid(1),stats(k).Centroid(2),'Volandera petita/Small washer','Color','r');
    Contador_VolanderaPetita=Contador_VolanderaPetita+1;
    rectangle('Position',[thisboundingbox(1), thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)], 'EdgeColor','g','LineWidth',2);

    elseif strcmp(yfit(k),'Volandera gran/Big washer');
    text(stats(k).Centroid(1),stats(k).Centroid(2),'Volandera gran/Big washer','Color','r');
    Contador_VolanderaGran=Contador_VolanderaGran+1;
    rectangle('Position',[thisboundingbox(1), thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)], 'EdgeColor','g','LineWidth',2);

    elseif strcmp(yfit(k),'Femella oberta/Open nut');
    text(stats(k).Centroid(1),stats(k).Centroid(2),'Femella oberta/Open nut','Color','r');
    Contador_FemellaOberta=Contador_FemellaOberta+1;
    rectangle('Position',[thisboundingbox(1), thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)], 'EdgeColor','g','LineWidth',2);

    elseif strcmp(yfit(k),'Cargol cilindric/Cylindrical screw');
    text(stats(k).Centroid(1),stats(k).Centroid(2),'Cargol cilindric/Cylindrical screw','Color','r');
    Contador_CargolCilindric=Contador_CargolCilindric+1;
    rectangle('Position',[thisboundingbox(1), thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)], 'EdgeColor','g','LineWidth',2);
    end
end