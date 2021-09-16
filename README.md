### Flip_modules2

# If you made the FFT Magnitude Buffer a larger array, would your program still work properly? If yes, why? If not, what would you need to change?

If I made the FFT magnitude buffer larger, the program will still compile with no errors. However, the FFT graph shown on the screen will have a huge flat line since FFT depends on the audio waves. SInce we did not change the audio wave buffer size while increasing the FFT data size by a lot, this will cause many storage wasted and makes users hard to see the FFT of the audio graph above. To fix this disparity, we should make the FFT buffer size the same with the time data(audio wave) in the file or 1/2 size of the time data in the file. This should fix the disparity on screen. 


# Is pausing the audioManager object better than deallocating it when the view has disappeared (explain your reasoning)?

No, deallocating the audio manager object is better than simply pausing the audio manager object because if users simply pause it when they quit the view and never use it again, the audio manager object will continue to take up memory while never being used or called again. Therefore, deallocating the memory when view has disappeared is a better choice. There are tradeoff in this approach; However, if the user wants to reactivate the audio model and resume the part where they stopped, there will be no way back since the audio model is deallocated and returning to the view will only create a new object instead of returning the old paused object.
