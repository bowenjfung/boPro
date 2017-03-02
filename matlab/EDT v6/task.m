function [trialLog] = task(params)
try
    
    % Setup screen
    window = params.window;
    width = params.width;
    height = params.height;
    params.ifi = Screen('GetFlipInterval', window);
    Screen('TextFont', window, 'Helvetica');
    Screen('TextSize', window, 30);
    
    % Instructions
    % drawText(window, 'This final component is a combination of the previous two tasks. In each trial, make a decision between the options, and then during the delay, try and press a button when you think half the interval has elapsed.\n\n[Press any button to start]');
    drawText(window, 'This final component is almost identical to the first, but the choice options that are presented will be slightly different.\n\n[Press any button to start]');
    
    
    %% Trial loop
    refills = 1;
    exit = 0;
    for t = 1:params.numTrials
        
        % Break every 20 trials
        if mod(t,20) == 0;
            drawText(window,'Take a break.\nPress any button to proceed.');
        end
        
        % Setup data
        trialLog(t).A = params.stimuli(t,2);
        trialLog(t).fA = params.stimuli(t,1);
        trialLog(t).D = params.stimuli(t,4);
        trialLog(t).fD = params.stimuli(t,3);
        trialLog(t).delay = [trialLog(t).fD, trialLog(t).D, trialLog(t).D];
        trialLog(t).amount = [trialLog(t).fA, trialLog(t).A, 0];
        trialLog(t).choice = 3; % 3 if missed
        trialLog(t).rt = -1; % -1 if missed
        trialLog(t).bisectRt = -1; % -1 if missed
        trialLog(t).choiceBias = params.stimuli(t,5); % Options generated by IP or logit fit
        
        % Randomise presentation side
        if rand < 0.5
            trialLog(t).swapped = 0;
        else
            trialLog(t).swapped = 1;
        end
        
        % Present options
        drawOptions(params,trialLog);
        onset = Screen(window, 'Flip');
        
        %% Capture response
        
        % Wait until all keys are released
        while KbCheck
        end
        % Check for response
        button_down = [];
        while GetSecs < (onset + params.choicetime)
            [ keyIsDown, ~, keyCode, ~ ] = KbCheck;
            if keyIsDown && isempty(button_down)
                button_down = GetSecs;
                trialLog(t).rt = button_down - onset;
                if keyCode(params.escapekey) == 1
                    exit = 1;
                    break;
                end
                switch trialLog(t).swapped
                    case 0
                        if keyCode(params.leftkey) == 1 % In case SS
                            trialLog(t).choice = 1;
                            position = 1;
                        elseif keyCode(params.rightkey) == 1 % In case LL
                            trialLog(t).choice = 2;
                            position = 2;
                        end
                    case 1
                        if keyCode(params.rightkey) == 1 % In case SS
                            trialLog(t).choice = 1;
                            position = 2;
                        elseif keyCode(params.leftkey) == 1 % In case LL
                            trialLog(t).choice = 2;
                            position = 1;
                        end
                end % Swapped switch
                if trialLog(t).choice ~= 3
                    drawOptions(params,trialLog);
                    Screen(window,'Flip');
                end
                break;
            end
        end
        
        % Make sure response window is consistent
        %         while GetSecs < (onset + params.choicetime);
        %         end
        WaitSecs(0.5);
        
        % Record remaining response window time to add to post-reward
        % buffer
        extraTime = 0;
        if trialLog(t).choice ~= 3
            extraTime = params.choicetime - trialLog(t).rt;
        end
        
        %% Delay
        % Build delay stimulus
        % Build delay stimulus
        Screen(window, 'FillRect', [128 128 128]); % Draw background
        oldSize = Screen('TextSize', window, 40);
        DrawFormattedText(window, '...', 'center', 'center',  [0 0 0], 70, 0, 0, 2);
        Screen('TextSize', window, oldSize);
        delay_onset = Screen(window, 'Flip');
        
        %% Capture response
        
        % Wait until all keys are released
        while KbCheck
        end
        % Check for response
        button_down = [];
        while GetSecs < (delay_onset + (trialLog(t).delay(trialLog(t).choice))) % Response window
            [ keyIsDown, ~, ~, ~ ] = KbCheck;
            if keyIsDown && isempty(button_down)
                button_down = GetSecs;
                % Build delay stimulus
                Screen(window, 'FillRect', [128 128 128]); % Draw background
                oldSize = Screen('TextSize', window, 40);
                DrawFormattedText(window, '...', 'center', 'center',  [20 240 20], 70, 0, 0, 2);
                Screen('TextSize', window, oldSize);
                Screen('Flip', window);
                break; % Break out of response window
            end
        end
        
        % Record data
        if ~isempty(button_down)
            trialLog(t).bisectRt = button_down - delay_onset;
            trialLog(t).rawbisect = trialLog(t).bisectRt - (trialLog(t).delay(trialLog(t).choice) / 2);
            trialLog(t).bisect = trialLog(t).bisectRt/(trialLog(t).delay(trialLog(t).choice));
        end
        
        while GetSecs < (delay_onset + (trialLog(t).delay(trialLog(t).choice)))
        end
        
        %% Reward delivery
        if params.testing == 1
            text = sprintf('%05.3f', trialLog(t).amount(trialLog(t).choice));
            Screen(window, 'FillRect', [128 128 128]); % Draw background
            DrawFormattedText(window, text, 'center', 'center',  [20 240 20], 35, 0, 0, 2);
            Screen(window, 'Flip');
        else
            if trialLog(t).choice == 3
                Screen(window, 'FillRect', [128 128 128]); % Draw background
                DrawFormattedText(window, 'You missed the choice! Please try and respond next time.', 'center', 'center',  [0 0 0], 35, 0, 0, 2);
                Screen(window, 'Flip');
            else
                pumpInf(params.pump, trialLog(t).amount(trialLog(t).choice));
                Screen(window, 'FillRect', [128 128 128]); % Draw background
                DrawFormattedText(window, 'Juice is dispensing...', 'center', 'center',  [0 0 0], 35, 0, 0, 2);
                Screen(window, 'Flip');
            end
        end
        
        % Total juice count
        if isempty(params.totalvolume)
            if t == 1
                trialLog(t).totalvolume = trialLog(t).amount(trialLog(t).choice);
            else
                trialLog(t).totalvolume = trialLog(t-1).totalvolume + trialLog(t).amount(trialLog(t).choice);
            end
        else
            trialLog(t).totalvolume = params.totalvolume + trialLog(t).amount(trialLog(t).choice);
            params.totalvolume = [];
        end
        
        %% Check to see if pump is empty
        if trialLog(t).totalvolume > refills * 250 && ~params.testing
            pumpWit(params.pump, 8);
            Screen(window, 'FillRect', [128 128 128]); % Draw background
            DrawFormattedText(window, 'Syringes are almost out of juice.\nPlease see the experimenter so they can be refilled.', 'center', 'center',  [0 0 0], 35, 0, 0, 2);
            Screen(window, 'Flip');
            
            % Backup data in case of quit
            oldcd = cd;
            cd(params.dataDir);
            data.trialLog = trialLog;
            data.params = params;
            save('recoveredData', 'data');
            cd(oldcd);
            
            KbWait([], 2)
            
            % Prompt refill and trigger pump withdrawal
            Screen(window, 'FillRect', [128 128 128]); % Draw background
            DrawFormattedText(window, 'Ready to fill? Press down arrow to refill via withdrawal (remember to press a button to stop). Press escape once finished.', 'center', 'center',  [0 0 0], 35, 0, 0, 2);
            Screen(window, 'Flip');
            
            response = [];
            while isempty(response)
                [ keyIsDown, ~, keyCode, ~ ] = KbCheck;
                if keyIsDown && isempty(button_down)
                    if keyCode(params.escapekey) == 1
                        exit = 1;
                        break;
                    elseif keyCode(params.downkey) == 1
                        pumpRefill(params.pump);
                    end
                end
            end
            
            refills = refills + 1;
        end
        
        if exit == 1
            break;
        end
        
        WaitSecs(params.drinktime + extraTime); % Modified ITI (extra response window time)
    end % Trial loop
    
catch
    ShowCursor;
    ListenChar(1);
    Screen('CloseAll');
    psychrethrow(psychlasterror)
    
    % Save data
    data.trialLog = trialLog;
    data.params = params;
    oldcd = cd;
    cd(params.dataDir);
    save('recoveredData', 'data');
    cd(oldcd);
    
end % Try
return