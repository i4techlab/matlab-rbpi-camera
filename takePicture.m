clear all
close all

%% Libraries that need to be imported for communications with Node-RED
import matlab.net.*
import matlab.net.http.*

%% AI Model that needs to be loaded
load trainedModelTFG.mat

%% Building HTTP request
r = RequestMessage;
% URI = Uniform Resource Identifier
uri = URI('http://10.7.0.25:20000/test1');
% Send to port 1880 where Node-RED is listening

%options = matlab.net.http.HTTPOptions('ConvertResponse',false);
%response = send(r,uri,options);
resp1 = send(r,uri);

% Image is received as a response
filename = 'http://10.7.0.25:20000/test1';

%% Image processing 
% First step of processing the image is reading it
Icolor = imread(filename);
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