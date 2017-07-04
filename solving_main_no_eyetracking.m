    
%-----------------------------------------------------------------------
%
%    Maze-Solvig task Version Jyly 04 2017
%
%    NOTE
%    This is the cope without eyelink so that we can run and test it without the
%    device
%
%    Maze maps will be loaded from the directory "world_maps"
%
%    If you would like to change worlds or to add new worlds, you will need
%    to edit files in the "world_maps" directory. 
%
%    For example, the world 1tunnel.txt looks like this:
%
%    3
%    6
%    000
%    030
%    032
%    030
%    030
%    003
%
%    The first two rows are world width and height;
%    The map is an array, in which each element can be empty (0), wall (3),
%    or exit (2). We assume there is always only one exit in each maze.
%
%    practice trials are not scored
%
%    pressing ESCAPE terminates the experiment; necessary to debug
%    or if something goes wrong during the session (e.g. the eyetracker
%    gave up or the patient has a sizeure)
%
%-----------------------------------------------------------------------

function [escaped_experiment, step_counter_1, step_counter_2] = solving_main_eyetracking(subject, window, mon)

    %-----------------------------------------------------------------------
    % setup the experiment
    %-----------------------------------------------------------------------
         
    step_counter_1 = 0;
    step_counter_2 = 0;
    
    fixationlog_here = 'solving_log_dir/';               % logging

    test_maps_easy_block_1 = loadAllMaps(strcat(pwd, '/block1/world_design_easy/'));  % maze maps
    number_of_test_trials_easy_block_1 = size(test_maps_easy_block_1,1);              % how many maze maps were loaded
    
    test_maps_med_block_1 = loadAllMaps(strcat(pwd, '/block1/world_design_medium/')); % maze maps
    number_of_test_trials_med_block_1 = size(test_maps_med_block_1,1);                % how many maze maps were loaded
    
    test_maps_hard_block_1 = loadAllMaps(strcat(pwd, '/block1/world_design_hard/'));  % maze maps
    number_of_test_trials_hard_block_1 = size(test_maps_hard_block_1,1);              % how many maze maps were loaded
    
    test_maps_easy_block_2 = loadAllMaps(strcat(pwd, '/block2/world_design_easy/'));  % maze maps
    number_of_test_trials_easy_block_2 = size(test_maps_easy_block_2,1);              % how many maze maps were loaded
    
    test_maps_med_block_2 = loadAllMaps(strcat(pwd, '/block2/world_design_medium/')); % maze maps
    number_of_test_trials_med_block_2 = size(test_maps_med_block_2,1);                % how many maze maps were loaded
    
    test_maps_hard_block_2 = loadAllMaps(strcat(pwd, '/block2/world_design_hard/'));  % maze maps
    number_of_test_trials_hard_block_2 = size(test_maps_hard_block_2,1);              % how many maze maps were loaded
    
    demo_maps = loadAllMaps(strcat(pwd, '/practice_world_maps/'));               % practice maze maps
    number_of_practice_trials = size(demo_maps,1);           
    
    %-----------------------------------------------------------------------
    %
    % test_maps and demo_maps are arrays of filenames
    %
    %-----------------------------------------------------------------------
      
    
    %-----------------------------------------------------------------------
    %
    %  experimenter demo uses the pre-cofignred goal
    %
    %  patient practice ignores the baked in location of the goal, 
    %  and places the goal at a random location, this is to show that the
    %  goal really can be anywhere
    %
    %-----------------------------------------------------------------------
    
    practiceTrialPermutation = 1:1:number_of_practice_trials; % the first five trials are practice trials, which are not scored
    
    %-----------------------------------------------------------------------
    %
    % create the agent image
    %
    %-----------------------------------------------------------------------
    
    img = imread(strcat(pwd, '/tex/agent1.png')); % the agent's face
    imageAgent = Screen('MakeTexture', window, img);
    

    %-----------------------------------------------------------------------
    %
    % instructions screen
    %
    %-----------------------------------------------------------------------
    
    fprintf('Showing instructions\n');
    flipTime = showInstructions(window);
    
    KbWait;
    [ keyIsDown, t, keyCode ] = KbCheck;   % wait for any key to be pressed
    KbReleaseWait;
    
    escapeKey = KbName('ESCAPE');
    if keyCode(escapeKey)
      fprintf('Experiment skipped.\n');
    else
       
      fprintf('Starting experiment...\n');
      
      fileID = fopen([fixationlog_here subject '_solving_log.txt'],'w');
      fprintf(fileID,'subject\trt\tworld\tpath\tvisible\ttrialtype\tkeyPressed\tkeyAction\tvalidAction\tblackremains\tnumsquaresopen\tsquaretype\tnumexits\n');  % The file format  
       
      fprintf('Starting demo...\n');
      
      [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ...
            practiceTrialPermutation, ... % the order in which the worlds will be shown
            demo_maps, ...% the array of world maps loaded from file
            0, ... % 0 -- demo, 1 -- practice, 2 -- experiment
            fileID, window, mon, subject, 0, number_of_practice_trials );
        
      %-----------------------------------------------------------------------
      %
      %    Intro to practice 
      %
      %-----------------------------------------------------------------------
      
      if escaped_experiment
          fprintf('Demo skipped...\n');
      end
      
      escaped_experiment = showIntroToPractice(window);
      
      if escaped_experiment
          fprintf('Practice skipped...\n');
      end
                 
      if ~escaped_experiment
            
            repeat_practice = 2;
            
            while repeat_practice == 2 && ~escaped_experiment
            
                fprintf('Starting practice...\n');
                
                [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ...
                    practiceTrialPermutation, ... % the order in which the worlds will be shown
                    demo_maps, ...% the array of world maps loaded from file
                    1, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                    fileID, window, mon, subject, 0, number_of_practice_trials );
                
                 %-----------------------------------------------------------------------
                 %
                 %    Ask if the subject wants to continue 
                 %
                 %-----------------------------------------------------------------------
                 
                 repeat_practice = askIfMorePractice(window);
                 
                 if repeat_practice == 1
                     escaped_experiment=1;
                 end
                 
            end
      else
          escaped_experiment = 0;
      end
                
      done = 0;
     
     
     
      %-----------------------------------------------------------------------
      %
      %    Here is the main experiment loop 
      %
      %-----------------------------------------------------------------------
            

      while ~escaped_experiment && ~done

           total_trials = number_of_test_trials_easy_block_1 + ...
               number_of_test_trials_med_block_1 + number_of_test_trials_hard_block_1;

            testTrialsPermutation = randperm(number_of_test_trials_easy_block_1);

            [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_easy_block_1, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, 0, total_trials );

            if escaped_experiment
                break;
            end

            step_counter_1 = step_counter_1 + step_counter;

            testTrialsPermutation = randperm(number_of_test_trials_med_block_1);

            [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_med_block_1, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, ...
                number_of_test_trials_easy_block_1,  total_trials);

            step_counter_1 = step_counter_1 + step_counter;

            if escaped_experiment
                break;
            end

            testTrialsPermutation    = randperm(number_of_test_trials_hard_block_1);

            [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_hard_block_1, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, ...
                number_of_test_trials_easy_block_1+number_of_test_trials_med_block_1,  total_trials);

            step_counter_1 = step_counter_1 + step_counter;

            if escaped_experiment
                break;
            end


            escaped_experiment = showSplash(window);

            if escaped_experiment
                fprintf('Second half skipped...\n');
                break;
            end

            total_trials = number_of_test_trials_easy_block_2 + ...
               number_of_test_trials_med_block_2 + number_of_test_trials_hard_block_2;
           
            testTrialsPermutation  = randperm(number_of_test_trials_easy_block_2); 

            [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_easy_block_2, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, 0, total_trials );

            step_counter_2 = step_counter_2 + step_counter;

            if escaped_experiment
                break;
            end

            testTrialsPermutation  = randperm(number_of_test_trials_med_block_2); 

            [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_med_block_2, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, ...
                number_of_test_trials_easy_block_2,  total_trials);

            step_counter_2 = step_counter_2 + step_counter;

            if escaped_experiment
                break;
            end

            testTrialsPermutation  = randperm(number_of_test_trials_hard_block_2); 

            [escaped_experiment, step_counter] = trialsLoopNoET( imageAgent, ... 
                testTrialsPermutation, ... % the order in which the worlds will be shown
                test_maps_hard_block_2, ...% the array of world maps loaded from file
                2, ... % 0 -- demo, 1 -- practice, 2 -- experiment
                fileID, window, mon, subject, ...
                number_of_test_trials_easy_block_2+number_of_test_trials_med_block_2,  total_trials );

            step_counter_2 = step_counter_2 + step_counter;

            if escaped_experiment
                break;
            end

            done = 1;
        end

        fclose(fileID);
       
    end
    
    
end