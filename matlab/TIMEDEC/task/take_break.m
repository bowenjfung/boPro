function take_break(window, width, height, h)
CedrusResponseBox('FlushEvents', h);
centerx = width/2;
centery = height/2;
ifi = Screen('GetFlipInterval', window);
slack = ifi/2;
grey = [128 128 128]; %pixel value for grey
defaultFont = 'Helvetica';
fontSize = 40;
Screen('TextFont',window, defaultFont);

Screen(window, 'FillRect', grey);
Screen('TextSize',window, fontSize);
text0 = 'Take a break!';
textbox0 = Screen('TextBounds', window, text0);
Screen('DrawText', window, text0, centerx - textbox0(3)/2, centery - textbox0(4), [0 0 0]);

text0 = ['Press any button to proceed'];
textbox0 = Screen('TextBounds', window, text0);
Screen('DrawText', window, text0, centerx - textbox0(3)/2, centery + textbox0(4) + fontSize*2, [0 0 0]);

Screen(window, 'Flip');
CedrusResponseBox('FlushEvents', h);
CedrusResponseBox('WaitButtons',h);

Screen('Close');

