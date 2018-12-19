**TimeSelector**  

The Time Picker that is available in Android... Now available in iOS!  
  
  
![Selecting the hour](https://playr.app/images/timeSelector.jpg)
![Selecting the minute](https://playr.app/images/timeSelector2.jpg)

**Example Usage (Swift)**  
    let timeSelector = TimeSelector()  
    
    timeSelector.timeSelected = {  
	    (timeSelector) in  
		   self.setLabelFromDate(timeSelector.date)  
    }  
    timeSelector.overlayAlpha = 0.8  
    timeSelector.clockTint = rgb(0, 230, 0)  
    timeSelector.minutes = 30  
    timeSelector.hours = 5  
    timeSelector.isAm = false  
    timeSelector.presentOnView(view: self.view)  
  
Test out the sample project!
