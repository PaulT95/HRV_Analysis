# HRV_Analysis
Here is sample script to import Data from txt collected using Porta Press. 
Basically this software works in two steps:
  1) Import data and cut automatically between two maker in the txt (Part of interest of the data in this case),
     Perform HRV analysis using an open-source library validated and developed by Marcus Vollmer (https://marcusvollmer.github.io/HRV/)
     In addition other calculations are made like BaroRecepector Gain
     This is performed every 60sec
     In the end it saves in a mat file with the parameters for each minute of each txt imported
  2) Simply here you import all the mat file created before and it put all the data in a single Excel file, 
     with multiple sheets, each one for each parameters returnered by the HRV analysis
