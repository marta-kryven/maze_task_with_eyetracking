%very simple eyelink example

clc 
clear all
close all
commandwindow; %focus on command window
Priority(2);

eyetracker_dummy_mode = 1;  % native eyetracker dummy mode, will call ET functions, but they will not do anything
                            % 0=no, 1=yes


[mon, dres, rm] = configMonitor(); % set resolution suitable for eyetracking  
[oldVisualDebugLevel, oldSupressAllWarnings, slack, window, gray] = defaultPsychtoolboxSetup;

try

    
    W=mon.wp; H= mon.hp;
    
    el=EyelinkInitDefaults(window);
    
    if ~EyelinkInit(eyetracker_dummy_mode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    % open file to record data to
    edfFile='very_simple_test.edf';
    Eyelink('Openfile', edfFile);
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    
    %now try recording something
    stopkey=KbName('space');
    
    img = imread('test.jpg');
    imageSize = size(rgb2gray(img));
    pos = [(W-imageSize(2))/2 (H-imageSize(1))/2 (W+imageSize(2))/2 (H+imageSize(1))/2];
    imageDisplay = Screen('MakeTexture', window, img);
           
    Screen(window, 'FillRect', gray);
    Screen('DrawTexture', window, imageDisplay, [], pos);
    flipTime = Screen('Flip', window);
    
    Eyelink('StartRecording');
    Eyelink('Message', 'SYNCTIME'); % mark zero-plot time in data file
    
    while 1
        %fprintf('Drawing...\n');
         
        %Screen('FillRect', win, [255,255,255], [200 200 400 400] );
        Screen('DrawTexture', window, imageDisplay, [], pos); 
        
        error=Eyelink('CheckRecording');

        if(error==el.ABORT_EXPT) % ABORT_EXPT if link disconnected. 
            fprintf('CheckRecording error... ABORT_EXPT %d\n', error);
            %break;
        elseif (error==el.TRIAL_ERROR) % TRIAL_ERROR if other non-recording state.
            fprintf('CheckRecording error... TRIAL_ERROR %d\n', error);
        elseif (error~= 0)
            fprintf('CheckRecording error... %d\n', error);
        end
        
        % if spacebar was pressed stop display
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(stopkey)
            break;
        end
        
        % get the ET data 
        [samples_data, events_data]=Eyelink('GetQueuedData');
                
        if ~isempty(events_data) && any(events_data(2,:) == el.ENDFIX)
            en=find(events_data(2,:) == el.ENDFIX);
            
            fx=events_data(19,en);  % display gaze position average x (in pixel coordinates set by screen_pixel_coords command)
            fy=events_data(20,en);  % display gaze position average y (in pixel coordinates set by screen_pixel_coords command)
            
            pupil=events_data(21,en); % average pupil size (arbitrary units, area or diameter as selected by pupil_size_diameter command)
            
            fstart=events_data(5,en); % start time
            fend=events_data(6,en); % end time
            event_type=events_data(2,en); % end time
            
            %fend-fstart is also quite large, it will be something like 747
            
            %event type is always 8, but the duration is that of a typical
            %fixation
            fprintf('event...  %d, duration %d\n', event_type, fend-fstart);
            
            Screen('DrawDots', window, [fx+20 fy+20], (fend-fstart)/20, [255,255,0,255], [], 2);
        else
            %fprintf('events_data is empty...\n');
        end
        
        if ~isempty(samples_data)
            gss=samples_data(14,:)>0;
            left_x = nanmean(samples_data(14,gss)); %left gaze position x (in pixel coordinates set by screen_pixel_coords command)      
            left_y = nanmean(samples_data(16,gss)); %left gaze position y (in pixel coordinates set by screen_pixel_coords command)
            ftime_stamp = nanmean(samples_data(1,gss)); %time of sample (when camera imaged eye, in milliseconds since tracker was activated)
            left_pupil = nanmean(samples_data(12,gss)); % left pupil size (arbitrary units, area or diameter as selected by pupil_size_diameter command)
            
            %normally left_pupil = 6563.7, has to be scaled down
            Screen('DrawDots', window, [left_x left_y], left_pupil/200, [255,0,0,255], [], 2);
        else
            fprintf('samples_data is empty...\n');
        end
    
        flipTime = Screen('Flip', window, flipTime + 0.01, 0);
    end
    
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end
    
    fprintf('Showing instructions\n');
    
    Screen('TextSize',window,50);
    DrawFormattedText(window, 'Thanks!', 'center', 'center', [0 0 0]);
    DrawFormattedText(window, 'You''ve completed the experiment.', 'center', 250, [0 0 0]);
    t.final_screen = Screen('Flip', window);
    
    KbWait;                 
    
    psychToolboxCleanup(oldVisualDebugLevel, oldSupressAllWarnings);
    
catch
    psychToolboxCleanup(oldVisualDebugLevel, oldSupressAllWarnings);
    psychrethrow(psychlasterror);
    
end

SetResolution(rm, dres.width, dres.height);
