function [processedImage_base64,counters,binarizedImage_base64] = PredictFunctionServer(inputImage_base64)
%#function ClassificationTree
    %% AI Model that needs to be loaded
    load trainedModelTFG.mat;

    %% Image processing

    % decode image stream using Java
    jImg = javax.imageio.ImageIO.read(java.io.ByteArrayInputStream(matlab.net.base64decode(inputImage_base64)));
    h = jImg.getHeight;
    w = jImg.getWidth;

    % convert Java Image to MATLAB image
    p = reshape(typecast(jImg.getData.getDataStorage, 'uint8'), [3, w, h]);
    Icolor = cat(3, transpose(reshape(p(3, :, :), [w, h])), transpose(reshape(p(2, :, :), [w, h])), transpose(reshape(p(1, :, :), [w, h])));

    I = rgb2gray((Icolor));
    % Noise supression
    I = wiener2(I, [3 3]);
    I = medfilt2(I);
    BW = im2bw(I, 0.65);
    imwrite(BW, 'ImatgeBinaritzada.jpeg');

    %% Classification of elements using picture in binary format
    % Image properties extraction
    L = bwlabel(BW);
    numele = max(max(L));
    stats = regionprops(L, 'all');
    Dades = struct2table(stats);
    
    yfit = trainedModelTFG.predictFcn(Dades);
    fh = figure;
    % Picture with elements found by the model
    imshow(Icolor)
    hold on;
    % Reset all counters, one for each type of piece (washers, nuts and bolts)
    Contador_RoscaQuadrada = 0; % Square thread
    Contador_VolanderaPetita = 0; % Small washer
    Contador_VolanderaGran = 0; % Big washer
    Contador_FemellaOberta = 0; % Open nut
    Contador_CargolCilindric = 0; % Cylindrical screw

    for k = 1:length(stats)
        thisboundingbox = stats(k).BoundingBox;

        if strcmp(yfit(k), 'Rosca quadrada');
            text(stats(k).Centroid(1), stats(k).Centroid(2), 'Rosca quadrada/Square thread', 'Color', 'r', 'FontSize', 24);
            Contador_RoscaQuadrada = Contador_RoscaQuadrada + 1;
            rectangle('Position', [thisboundingbox(1), thisboundingbox(2), thisboundingbox(3), thisboundingbox(4)], 'EdgeColor', 'g', 'LineWidth', 2);

        elseif strcmp(yfit(k), 'Volandera petita');
            text(stats(k).Centroid(1), stats(k).Centroid(2), 'Volandera petita/Small washer', 'Color', 'r', 'FontSize', 24);
            Contador_VolanderaPetita = Contador_VolanderaPetita + 1;
            rectangle('Position', [thisboundingbox(1), thisboundingbox(2), thisboundingbox(3), thisboundingbox(4)], 'EdgeColor', 'g', 'LineWidth', 2);

        elseif strcmp(yfit(k), 'Volandera gran');
            text(stats(k).Centroid(1), stats(k).Centroid(2), 'Volandera gran/Big washer', 'Color', 'r', 'FontSize', 24);
            Contador_VolanderaGran = Contador_VolanderaGran + 1;
            rectangle('Position', [thisboundingbox(1), thisboundingbox(2), thisboundingbox(3), thisboundingbox(4)], 'EdgeColor', 'g', 'LineWidth', 2);

        elseif strcmp(yfit(k), 'Femella oberta');
            text(stats(k).Centroid(1), stats(k).Centroid(2), 'Femella oberta/Open nut', 'Color', 'r', 'FontSize', 24);
            Contador_FemellaOberta = Contador_FemellaOberta + 1;
            rectangle('Position', [thisboundingbox(1), thisboundingbox(2), thisboundingbox(3), thisboundingbox(4)], 'EdgeColor', 'g', 'LineWidth', 2);

        elseif strcmp(yfit(k), 'Cargol cilindric')
            text(stats(k).Centroid(1), stats(k).Centroid(2), 'Cargol cilindric/Cylindrical screw', 'Color', 'r', 'FontSize', 24);
            Contador_CargolCilindric = Contador_CargolCilindric + 1;
            rectangle('Position', [thisboundingbox(1), thisboundingbox(2), thisboundingbox(3), thisboundingbox(4)], 'EdgeColor', 'g', 'LineWidth', 2);
        end
    end
    hold off
    
    % Save processed image
    frm = getframe(fh);
    imwrite(frm.cdata, 'ImatgeClassificada.jpeg');
    % ImatgeClassificada = (imread('ImatgeClassificada.png')); 

    % Base64 Image Encoder
    fid = fopen('ImatgeClassificada.jpeg','rb');
    bytes = fread(fid);
    fclose(fid);
    encoder = org.apache.commons.codec.binary.Base64;
    processedImage_base64 = char(encoder.encode(bytes))';
    
    fid = fopen('ImatgeBinaritzada.jpeg','rb');
    bytes = fread(fid);
    fclose(fid);
    encoder = org.apache.commons.codec.binary.Base64;
    binarizedImage_base64 = char(encoder.encode(bytes))';

    % A struct is built as a response
   
    field1 = 'Contador_CargolCilindric';  value1 = {Contador_CargolCilindric};
    field2 = 'Contador_FemellaOberta';  value2 = {Contador_FemellaOberta};
    field3 = 'Contador_RoscaQuadrada'; value3 = {Contador_RoscaQuadrada};
    field4 = 'Contador_VolanderaGran'; value4 = {Contador_VolanderaGran};
    field5 = 'Contador_VolanderaPetita'; value5 = {Contador_VolanderaPetita};
    counters = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5);