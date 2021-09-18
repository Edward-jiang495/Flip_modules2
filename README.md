# Flip_modules2

## Team Member
Jonathan Ebrahimian  
Nathan Gage  
Edward Jiang  

### If you made the FFT Magnitude Buffer a larger array, would your program still work properly? If yes, why? If not, what would you need to change?

If I made the FFT magnitude buffer larger, the program will still compile with no errors. However, the FFT buffer will become meaningless since it is calcualting max based on empty data, thus showing a straight line on the graph. The Audio Model's FFT must be half of the size of the time data buffer size to have a meaningful output on the graph. If we change we FFT magnitude buffer, we must also change the time data buffer size to twice the size of FFT buffer. 


### Is pausing the audioManager object better than deallocating it when the view has disappeared (explain your reasoning)?

Pausing is better because we remain aware of the number of channels and other constrains and we only need to nil the input block. Once the user wants to play it again, they can re-enter the view to replay it. If we deallocate the object, it is less efficient to re-create the entire object each time the user enters the view, which could cause potential problems if the users enter and exit the view rapidly. We pause the audio manager object and nil the input block but we did not deallocate the audio Manager object.
