function writeToFileEyelink(fileID, ...
         logtimestamp, ...
         subject, ... %subject ID
         rt, ... %reaction time that it takes the subjevt to move to a new cell
         samples_data, ... % eyelink data, sampled coordinates at all times
         events_data, ... % eyelink data, fixation event, will have the timing of the fixation
         world, ... % the current maze
         worldtopleft_x, worldtopleft_y, ... % the top-left coordinates of the maze being rendered
         path, ... % the subject's path so far
         visible, ... % the area seen by the subject
         trial_type, ... % 1 -- practice, 2 -- experiment
         readKeyName, ... % the readable name of the key that was pressed
         actionName, ... % if the keypress resulted in an action : U,D,L,R
         actionValid, ... % 1 -- valid action 0-- invalid action, such as going intoa wall
         blackremains, ... % number of balck squares that remains to open
         numsquaresopen, ... % if an observation was received, how many squares opened? otherwise 0
         squaretype, ...   % 'O' - observation, 'N' - nothing happened, 'X' - the first square,  'G' - observing the goal
          ...                 % 'D'-- observation with > 2 exits
         numexits, ... % number of exits from this square
         cellsize, ... % the size of the cells that we render
         gridworld) % the world structure
     
 % The file format will be this:    
 %fprintf(fileID,'subject\trt\teyex\teyey\tdatatype\ttimefrom\ttimeto\tpupil\teyecellx\teyecelly\tworld\tpath\tvisible\ttrialtype\tkeyPressed\tkeyAction\tvalidAction\tblackremains\tnumsquaresopen\tsquaretype\tnumexits\n');  % The file format  
       
 %sample
 % data(i,1) = x;
 % data(i,2) = y;
 % data(i,3) = pupil;
 % data(i,4) = timestamp;

 %event
 % data(i,1) = x;
 % data(i,2) = y;
 % data(i,3) = pupil;
 % data(i,4) = from;
 % data(i,5) = to;
    
% fprintf('writing file \n');
 world_w = size(gridworld,2); % x
 world_h = size(gridworld,1); %
    
 svisible = '';
 for j=1:size(visible,1)
     for i=1:size(visible,2)
         svisible=sprintf('%s%d', svisible, visible(j,i));
     end
 end
 
 s_trial = 'practice';
 
 if trial_type == 2
     s_trial = 'experiment';
 end
 
 if length(readKeyName) == 0
      readKeyName = 'NA';
 elseif iscell(readKeyName)
     numberofkeys = length(readKeyName);
     fprintf('%d keys pressed: %s, %s\n', numberofkeys, readKeyName{1}, readKeyName{2});
     readKeyName = readKeyName{2};
     fprintf('Forcing key:%s, %s\n', readKeyName, actionName);
 end
 
 only_non_et_recording = 0;
 
 if size(events_data,1) == 0 && size(samples_data,1) == 0
     only_non_et_recording = 1;
     events_data = zeros(2,5);     % if we received no data AT ALL, at least record everything else
 end
     
 if ~only_non_et_recording
     for i=1:size(samples_data,1)

        %which cell they look in?
        eye_x = samples_data(i,1);
        eye_y = samples_data(i,2);

        if  (~isnan(eye_x) && ~isnan(eye_y))

            [cellx, celly] = getCell(world_w, world_h, worldtopleft_x, worldtopleft_y, cellsize, eye_x, eye_y);
            pupil = samples_data(i,3);
            timestamp = samples_data(i,4);

            %record eye position relative to the top left corner of the world
            line1 = sprintf('%s\t%s\t%4.0f\t%4.0f\t%4.0f\tsample\t', logtimestamp, subject, rt, eye_x-worldtopleft_x, eye_y-worldtopleft_y);
            line2 = sprintf('%8.0f\t0\t%4.0f\t%d\t%d\t', timestamp, pupil, cellx, celly);
            line3 = sprintf('%s\t%s\t%s\t%s\t%s\t%s\t%d\t', world, path, svisible, s_trial, readKeyName, actionName, actionValid );
            line4 = sprintf('%d\t%d\t%s\t%d\n', blackremains, numsquaresopen, squaretype, numexits);
            fprintf(fileID, [line1 line2 line3 line4]);
        end
     end
 end
 
 for i=1:size(events_data,1)
     
    if ~only_non_et_recording
        %which cell they look in?
        eye_x = events_data(i,1);
        eye_y = events_data(i,2);

        if  (~isnan(eye_x) && ~isnan(eye_y))
            [cellx, celly] = getCell(world_w, world_h, worldtopleft_x, worldtopleft_y, cellsize, eye_x, eye_y);
            eye_x = eye_x-worldtopleft_x;
            eye_y = eye_y-worldtopleft_y;
        end
        
        pupil = events_data(i,3);
        timefrom = events_data(i,4);
        timeto = events_data(i,5);
    else
        eye_x = -1;
        eye_y = -1;
        cellx = -1;
        celly = -1;
        pupil = -1;
        timefrom = -1;
        timeto = -1;
    end
    
    

    %'rt\teyex\teyey\tdatatype\ttimefrom\ttimeto\tpupil\teyecellx\teyecelly\tworld\tpath'
    %\tvisible is not written

    line1 = sprintf('%s\t%s\t%4.0f\t%4.0f\t%4.0f\tevent\t', logtimestamp, subject, rt, eye_x, eye_y);
    line2 = sprintf('%8.0f\t%8.0f\t%4.0f\t%d\t%d\t', timefrom, timeto, pupil, cellx, celly);
    line3 = sprintf('%s\t%s\t%s\t%s\t%s\t%s\t%d\t', world, path, svisible, s_trial, readKeyName, actionName, actionValid );
    line4 = sprintf('%d\t%d\t%s\t%d\n', blackremains, numsquaresopen, squaretype, numexits);
    fprintf(fileID, [line1 line2 line3 line4]);
    
 end
 
end