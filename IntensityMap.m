function [ IM ] = IntensityMap( I )
% Subtask #1
% Returns Intensity map of HU saliency model

V = rgb2gray(I);
V = im2double(V);
V8 = imresize(V,.25);


% http://www.mathworks.com/help/images/ref/nlfilter.html
fun = @(x) std(x(:));
IM = nlfilter(V8, [2,2], fun);

IM = imresize(IM, 4);
end
