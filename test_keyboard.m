commandwindow; % focus on the command window
Priority(2);
KbName('UnifyKeyNames');
[oldVisualDebugLevel, oldSupressAllWarnings, slack, window, gray] = defaultPsychtoolboxSetup; % psychtoolbox setup
 
esc = 0;
keyCode = 1;
escapeKey = KbName('ESCAPE');

count = 0;

while ~esc && count < 1000
    
    flush = 0;
    count = count + 1;
    
    FlushEvents('keyDown');
    [ keyIsDown, t, keyCode ] = KbCheck([]);
    ikeyCode = find(keyCode);

    if ~isempty(ikeyCode)

       fprintf('[1] pressed %d %s, flushing... \n', ikeyCode, KbName(ikeyCode));
        
        while ~flush
             
           [ keyIsDown, t, k ] = KbCheck([]);
           ik = find(k);      % what is the next key on the buffer?
           
           if isempty(ik)
                flush = 1;    % if there is nothing then the buffer is flushed
           else
                if k(escapeKey)
                  flush = 1;  % if there is ESC terminate whatever we are doing
                  esc = 1;
                elseif ik ~= ikeyCode
                  flush = 1;  % if it is a key we have not seen before
                  fprintf('[3] new key found, stop reading %d, %s\n', ik, KbName(ik));
                end
                
                %keyCode = k; 
           end
        end
        
        fprintf('after flushing, key %s\n', KbName(keyCode))
    end
end



psychToolboxCleanup(oldVisualDebugLevel, oldSupressAllWarnings);
    