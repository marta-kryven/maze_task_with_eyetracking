%-------------------------------------------------------------------------
% Want to return the dots structure in the form x, y, size
% 
%  data(i,1) = x;
%  data(i,2) = y;
%  data(i,3) = size_dot;
%  data(i,4) = durationStep*size_dot;
%  data(i,5) = min(timeStampAll) - initTimeStamp;
%
%  so, durationStep is the length that the fixation lasted, may be we do
%  not need this since it can be derived from other data
%
%  data(i,5) is the timing of this fixation from the start of the trial
%-------------------------------------------------------------------------


% sample rows are as follows:
% 1: time of sample (when camera imaged eye, in milliseconds since tracker was
% activated)
% 2: type (always SAMPLE_TYPE or LOSTDATAEVENT as returned by
% EyelinkInitDefaults)
% 3: flags (bits indicating what types of data are present, and for which eye(s)
% - see eye_data.h)
% 4: left pupil center x (camera coordinates)
% 5: right pupil center x (camera coordinates)
% 6: left pupil center y (camera coordinates)
% 7: right pupil center y (camera coordinates)
% 8: left HEADREF x (angular gaze coordinates)
% 9: right HEADREF x (angular gaze coordinates)
% 10: left HEADREF y (angular gaze coordinates)
% 11: right HEADREF y (angular gaze coordinates)
% 12: left pupil size (arbitrary units, area or diameter as selected by
% pupil_size_diameter command)
% 13: right pupil size (arbitrary units, area or diameter as selected by
% pupil_size_diameter command)
% 14: left gaze position x (in pixel coordinates set by screen_pixel_coords
% command)
% 15: right gaze position x (in pixel coordinates set by screen_pixel_coords
% command)
% 16: left gaze position y (in pixel coordinates set by screen_pixel_coords
% command)
% 17: right gaze position y (in pixel coordinates set by screen_pixel_coords
% command)
% 18: angular resolution x (at gaze position in screen pixels per visual degree)
% 19: angular resolution y (at gaze position in screen pixels per visual degree)
% 20: status (error and status flags (only useful for EyeLink II and
% EyeLink1000, report CR status and tracking error). see eye_data.h.)
% 21: input (data from input port(s))
% 22: button input data: high 8 bits indicate changes from last sample, low 8
% bits indicate current state of buttons 8 (MSB) to 1 (LSB)
% 23: head-tracker data type (0=none)
% 24: head-tracker data (not prescaled) 1
% 25: head-tracker data (not prescaled) 2
% 26: head-tracker data (not prescaled) 3
% 27: head-tracker data (not prescaled) 4
% 28: head-tracker data (not prescaled) 5
% 29: head-tracker data (not prescaled) 6
% 30: head-tracker data (not prescaled) 7
% 31: head-tracker data (not prescaled) 8
% if you request the raw sample fields, they will appear in the following
% additional rows:
% 32: raw x sensor position of the pupil
% 33: raw y sensor position of the pupil
% 34: raw x sensor position of the corneal reflection
% 35: raw y sensor position of the corneal reflection
% 36: raw pupil area
% 37: raw corneal reflection area
% 38: raw width of pupil
% 39: raw height of pupil
% 40: raw width of corneal reflection
% 41: raw height of corneal reflection
% 42: raw x position of tracking window on sensor
% 43: raw y position of tracking window on sensor
% 44: (raw pupil x) - (raw corneal reflection x)
% 45: (raw pupil y) - (raw corneal reflection y)
% 46: raw area of 2nd corneal reflection candidate
% 47: raw x sensor position of the 2nd corneal reflection candidate
% 48: raw y sensor position of the 2nd corneal reflection candidate



% event rows are as follows:
% 1: effective time of event
% 2: event type
% 3: read (bits indicating which data fields contain valid data - see
% eye_data.h.)
% 4: eye
% 5: start time
% 6: end time
% 7: HEADREF gaze position starting point x
% 8: HEADREF gaze position starting point y
% 9: display gaze position starting point x (in pixel coordinates set by
% screen_pixel_coords command)
% 10: display gaze position starting point y (in pixel coordinates set by
% screen_pixel_coords command)
% 11: starting pupil size (arbitrary units, area or diameter as selected by
% pupil_size_diameter command)
% 12: HEADREF gaze position ending point x
% 13: HEADREF gaze position ending point y
% 14: display gaze position ending point x (in pixel coordinates set by
% screen_pixel_coords command)
% 15: display gaze position ending point y (in pixel coordinates set by
% screen_pixel_coords command)
% 16: ending pupil size (arbitrary units, area or diameter as selected by
% pupil_size_diameter command)
% 17: HEADREF gaze position average x
% 18: HEADREF gaze position average y
% 19: display gaze position average x (in pixel coordinates set by
% screen_pixel_coords command)
% 20: display gaze position average y (in pixel coordinates set by
% screen_pixel_coords command)
% 21: average pupil size (arbitrary units, area or diameter as selected by
% pupil_size_diameter command)
% 22: average gaze velocity magnitude (absolute value) in visual degrees per
% second
% 23: peak gaze velocity magnitude (absolute value) in visual degrees per second
% 24: starting gaze velocity in visual degrees per second
% 25: ending gaze velocity in visual degrees per second
% 26: starting angular resolution x in screen pixels per visual degree
% 27: ending angular resolution x in screen pixels per visual degree
% 28: starting angular resolution y in screen pixels per visual degree
% 29: ending angular resolution y in screen pixels per visual degree
% 30: status (collected error and status flags from all samples in the event
% (only useful for EyeLink II and EyeLink1000, report CR status and tracking
% error). see eye_data.h.)

function [ sample_dots, event_dots] = trackEyesEyelink(el) 

    sample_dots=[];
    
    event_dots=[];
    
    count_sample_dots = 0;
    count_event_dots = 0;

    %------------------ Monitor for fixation-related events --------------
    
    [samples_data, events_data]=Eyelink('GetQueuedData');
    
    if ~isempty(events_data) && any(events_data(2,:) == el.ENDFIX)
        en=find(events_data(2,:) == el.ENDFIX);

        fx=events_data(19,en);  % display gaze position average x (in pixel coordinates set by screen_pixel_coords command)
        fy=events_data(20,en);  % display gaze position average y (in pixel coordinates set by screen_pixel_coords command)

        pupil=events_data(21,en); % average pupil size (arbitrary units, area or diameter as selected by pupil_size_diameter command)

        fstart=events_data(5,en); % start time
        fend=events_data(6,en); % end time

        %try fend-fstart for dot size
        
        count_event_dots = count_event_dots+1;
        event_dots(count_event_dots,1) = fx;
        event_dots(count_event_dots,2) = fy;
        event_dots(count_event_dots,3) = pupil;
        event_dots(count_event_dots,4) = fstart;
        event_dots(count_event_dots,5) = fend;
        
    else
       % fprintf('events_data is empty...\n');
    end

    if ~isempty(samples_data)
        gss=samples_data(14,:)>0;
        
        %usually it only tracks the left eye
        eye_x = nanmean(samples_data(14,gss)); %left gaze position x (in pixel coordinates set by screen_pixel_coords command)      
        eye_y = nanmean(samples_data(16,gss)); %left gaze position y (in pixel coordinates set by screen_pixel_coords command)
        ftime_stamp = nanmean(samples_data(1,gss)); %time of sample (when camera imaged eye, in milliseconds since tracker was activated)
        pupil = nanmean(samples_data(12,gss)); % left pupil size (arbitrary units, area or diameter as selected by pupil_size_diameter command)

        %normally left_pupil = 6563.7, has to be scaled down
        count_sample_dots = count_sample_dots+1;
        sample_dots(count_sample_dots, 1) = eye_x;
        sample_dots(count_sample_dots, 2) = eye_y;
        sample_dots(count_sample_dots, 3) = pupil;
        sample_dots(count_sample_dots, 4) = ftime_stamp;
        
    else
        %fprintf('samples_data is empty...\n');
    end

end