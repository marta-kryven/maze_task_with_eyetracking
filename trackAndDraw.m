function [ dots_samples, dots_events ] = trackAndDraw(window, el, draw_dots) 
    [ dots_samples, dots_events ] = trackEyesEyelink(el);

     %data is x, y, size, 
     if draw_dots
        for dot=1:size(dots_samples,1)   
           dot_size = dots_samples(dot,3)/180;
           if dot_size < 10 
               dot_size = 10;
           end
           Screen('DrawDots', window, [dots_samples(dot,1) dots_samples(dot,2)], dot_size, [0,255,0,255], [], 2);
        end
     end
end