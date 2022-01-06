# ABS_diff_calculator_for_coordinates
MATLAB code that can be used to calculate absolute differences between measured and reference coordinate points

#######
When the code is run, the user can select an excel file containing the reference coordinate values and the excel file containing the measured coordinate values.
Code will then calculate the absolute difference values between the points, percentage error between the points, and it will pop out a table containing the numerical values for each x, y, and z coordinates. 
In addition, after the absolute differences for x,y, and z coordinates are calculated, the code will calculate the length of the absolute difference vector by using obtained absolute differences for x,y, and z coordinates. 
Obtained vector lengths for each measurement points are presented as a bar graph, and the color of each bar will depend on the value.
Reference points are then used to create a 3D scatter plot where the color of the point is the same than corresponding bar's color in the bar graph. For instance, if the color of the second bar is orange, then the color of the corresponding reference point is orange.

NOTE:
The code is only capable of reading specifically named excel-files, and there must be specific number of points. The reading functions for the files can be found at the end of the script.
In addition, the user must add a file named "POINTCLOUD_COORDINATES.xlsx" to path. This file will include more reference points that are used to create 3D scatter plot. The points in this file have no other use, and they are plotted as gray. These points only help to visualize the shape of the head better.
One file containing the reference points, one file containing the measured points, and the "POINTCLOUD_COORDINATES.xlsx" file can be found in the repository as an example.
