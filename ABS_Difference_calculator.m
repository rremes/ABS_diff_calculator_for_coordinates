%Read the desired files from the selected folder
clc
[dataFile, folder, ~] = uigetfile( {'*.xlsx', 'Data files (*.xlsx)'; '*.*','All Files (*.*)'}, ...
    'Choose reference coordinate file and measured points file', 'C:\Users\Data\Measurements','MultiSelect','on');  %USER CAN EDIT THE FOLDER

%Check if the there are files selected, if not display error message to
%user and break 
if folder ~= 0
    dataLoaded = 1;
    
else
    f = errordlg('Select file(s)','File Error');
    dataLoaded = 0;
    return
end

%Read the coordinate values of other points which are not used in the
%measurement. These points are used to plot 3D point cloud.
%Change the directory if needed.

POINTCLOUDCOORDINATES = importfile("C:\Users\Data\POINTCLOUD_COORDINATES.xlsx", "Taul1", [2, 178]);   %USER CAN EDIT THE FOLDER


%Names of the selected excel files 
fileNames = string(dataFile);


%Check whether the reference points belong to measurement1-1 or other

Index_data1_1 = find(contains(fileNames,'Referenssipisteet_data1_1.xlsx'));
Index_restData = find(contains(fileNames,'Referenssipisteet.xlsx'));


%Load the reference points based on whether the selected reference points belong to data1-1 or not

if Index_data1_1 ~= 0
    %Download reference points as double variable
    workbookFile = string(folder) + fileNames{1,Index_data1_1};
    Reference_points = importfile(workbookFile, "Taul1", [1, 90]);
    %Index = Index_data1_1;
else
    %Download reference points as double variable
    workbookFile2 = string(folder) + fileNames{1,Index_restData};
    Reference_points = importfile2(workbookFile2, "Taul1", [1, 65]);
    %Index = Index_restData;
    
end





%Check the indeces of selected measurement points files

if Index_data1_1 ~= 0
    index_for_measuredPoints = find(fileNames ~= 'Referenssipisteet_data1_1.xlsx');
else
    index_for_measuredPoints = find(fileNames ~= 'Referenssipisteet.xlsx');
end


%Dowload the measurement points as a double format and store them to struct
%element, so multiple files can be selected, also check if the measured
%points belong to data1_1 or not.

if Index_data1_1 ~= 0
    %Download measured points as double variable that belongs to data1_1
    for k=1:length(index_for_measuredPoints(1,:))
        my_field{k,:} = strcat('Mittauspisteet',num2str(k));
        workbookFile3 = string(folder) + fileNames{1,index_for_measuredPoints(k)};
        Measured_points = importfile3(workbookFile3, "Taul1", [4, 92]);
        measured_coordinates.(my_field{k,:}) = Measured_points;
    end
    
    Index = Index_data1_1;
else
    %Download measured points as double variable that belongs to other
    %measurements than data1_1
    for k=1:length(index_for_measuredPoints(1,:))
        my_field{k,:} = strcat('Mittauspisteet',num2str(k));
        workbookFile4 = string(folder) + fileNames{1,index_for_measuredPoints(k)};
        Measured_points = importfile4(workbookFile4, "Taul1", [4, 67]);
        measured_coordinates.(my_field{k,:}) = Measured_points;
    end
    Index = Index_restData;
    
end

 





%%%%%%ABSOLUTE DIFFERENCE BETWEEN REFERENCE POINTS & MEASURED POINTS%%%%%%%

for i = 1:length(index_for_measuredPoints(1,:))
    
    %Get measured test coordinates
    test_coordinate_values1 = getfield(measured_coordinates,my_field{i,:});
    
    %Get reference coordinate values
    reference_coordinate_values = Reference_points(2:end,:);
    
    %Create names for results
    
    my_field2{i,:} = strcat('Results',num2str(i));
    
    
    
    %Calculate the absolute difference values between measured and
    %reference points
    
    for x = 1:length(reference_coordinate_values(:,1)) %value of how many rows there are in reference coordinate matrix
        for j = 1:length(reference_coordinate_values(1,:)) %value of how many columns there are in reference coordinate matrix
            
            absolute_difference(x,j) = abs(reference_coordinate_values(x,j) - test_coordinate_values1(x,j));
 
            
            %Store the results to struct format
            Difference_between_coordinates.(my_field2{i,:}) = absolute_difference;
        end
        
    end
    
    %Pop out the table for user that contains the results
    figure('Name','The absolute differences between reference & measured points');
    vars = {'X','Y','Z'};
    t = absolute_difference;
    T = table(t);
    uitable('Data',T{:,:},'ColumnName',vars,...
        'Units', 'Normalized', 'Position',[0, 0, 1, 1],'ColumnWidth',{150,100,150});
    
    
    
end
    

%Plot a figure that illustrates the absolute difference between measured
%points and reference coordinate values

for i = 1:length(index_for_measuredPoints(1,:))
    
    %Get variable that contains absolute difference
    absolute_difference = getfield(Difference_between_coordinates,my_field2{i,:});
    x_axis = linspace(1,length(absolute_difference(:,1)),length(absolute_difference(:,1)));
    figure()
    hold on
    for i = 1:length(absolute_difference(:,1))
        plot(x_axis(1,i),absolute_difference(i,1),'g.')
        plot(x_axis(1,i),absolute_difference(i,2),'b.')
        plot(x_axis(1,i),absolute_difference(i,3),'r.')
        plot(x_axis(1,:),absolute_difference(:,1),'g-')
        plot(x_axis(1,:),absolute_difference(:,2),'b-')
        plot(x_axis(1,:),absolute_difference(:,3),'r-')
    end
    title('The absolute differences between measured and reference coordinate points')
    legend('x-coordinate', 'y-coordinate', 'z-coordinate')
    xlabel('Coordinate point number')
    ylabel('[mm]')
    hold off
end



%%%BAR GRAPH & 3D POINT CLOUD PLOTTING
%The color of the bar in the graph and corresponding point in the 3D point
%cloud depends on the value of the absolute difference between the measured
%and the reference value. 


for i = 1:length(index_for_measuredPoints(1,:))
    %Get variable that contains absolute difference
    absolute_difference = getfield(Difference_between_coordinates,my_field2{i,:});
    
    %Get reference coordinate values
    reference_coordinate_values = Reference_points(2:end,:);
    
    %calculate the length of the absolute difference vector for each
    %measurement point
    for i = 1:length(reference_coordinate_values(:,1))
        
        ABS_difference_vector(i,:) = sqrt((absolute_difference(i,1)^2) + (absolute_difference(i,2)^2) + (absolute_difference(i,3)^2));
        
    end
    
    
    %plot the bar graph
    number_of_points = length(ABS_difference_vector(:,1));
    
    x_axis = linspace(1,number_of_points,number_of_points);
    
    
    %sort the absolute differences from min to max and store their indices
    
    [sorted_differences,Indx] = sort(ABS_difference_vector);
    
    
    
    figure()
    hold on
    
    for i = 1:length(ABS_difference_vector(:,1))
        
        b = bar(x_axis(1,i),ABS_difference_vector(i,1),'Facecolor','flat','EdgeColor',[0 0 0],'LineWidth',1.1);
        %b = bar(x_axis(1,i),ABS_difference_vector(i,1),'Facecolor','flat');
        %set(gca,'Ytick',0:16)
        
        if ABS_difference_vector(i,1) <= 2
            color = [0 1 0];
            %b2.CData(Indx(i),:) = cmap1(4*i,:);
            set(b,'Facecolor',color);
            
        elseif 2 < ABS_difference_vector(i,1) && ABS_difference_vector(i,1) <= 4
            color = [1 1 0];
            %b2.CData(Indx(i),:) = cmap2(4*i,:);
            set(b,'Facecolor',color);
            
        elseif 4 < ABS_difference_vector(i,1) && ABS_difference_vector(i,1) <= 6
            color = [1 0.5  0];
            %b2.CData(Indx(i),:) = cmap2(4*i,:);
            set(b,'Facecolor',color);
            
        else
            color = [1 0 0];
            %b2.CData(Indx(i),:) = cmap3(4*i,:);
            set(b,'Facecolor',color);
        end
        
    end
    
    %Colorbar that can be used when caxis is set to be 0-8mm
    %cmap = interp1([0 1 0; 1 1 0; 1 0.5 0; 1 0 0], linspace(1, 4, 4));
    
    %Colorbar that shows every values higher than 6 as red
    cmap = interp1([0 1 0; 1 1 0; 1 0.5 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0], linspace(1, 8, 8));
    colormap(cmap)
    cbh = colorbar;
    cbh.Label.String = '[mm]';
    caxis([0 16])
    title('The absolute differences between measured and reference coordinate points')
    xlabel('Measuring point number')
    ylabel('[mm]')
    ylim([0 16])
    hold off
    
    
    %plot 3D point cloud containing the reference points, and their color will
    %depend on how much is the absolute difference between the reference and measured coordinate value.
    %So, the color of each point should be the same as in the previously
    %plotted bar graph. Points with black color indicate points that were not
    %measured. 

    figure()
    hold on
    %c = scatter3(reference_coordinate_values(:,1),reference_coordinate_values(:,2),reference_coordinate_values(:,3),'filled'); 
    %h = scatter3(POINTCLOUDCOORDINATES(:,1),POINTCLOUDCOORDINATES(:,2),POINTCLOUDCOORDINATES(:,3),'filled','MarkerFaceColor',[0.5 0.5 0.5]);
    %h = scatter3(POINTCLOUDCOORDINATES(:,1),POINTCLOUDCOORDINATES(:,2),POINTCLOUDCOORDINATES(:,3),'MarkerEdgeColor',[0.5 0.5 0.5]);
    h = scatter3(POINTCLOUDCOORDINATES(:,1),POINTCLOUDCOORDINATES(:,2),POINTCLOUDCOORDINATES(:,3),'filled','MarkerFaceColor',[0.8 0.8 0.8]);

    for i = 1:length(ABS_difference_vector(:,1))
         
        if ABS_difference_vector(i,1) <= 2
            color = [0 1 0];
            c = scatter3(reference_coordinate_values(i,1),reference_coordinate_values(i,2),reference_coordinate_values(i,3),'filled','MarkerFaceColor',color); 
            
        elseif 2 < ABS_difference_vector(i,1) && ABS_difference_vector(i,1) <= 4
            color = [1 1 0];
            c = scatter3(reference_coordinate_values(i,1),reference_coordinate_values(i,2),reference_coordinate_values(i,3),'filled','MarkerFaceColor',color);
            
        elseif 4 < ABS_difference_vector(i,1) && ABS_difference_vector(i,1) <= 6
            color = [1 0.5  0];
            c = scatter3(reference_coordinate_values(i,1),reference_coordinate_values(i,2),reference_coordinate_values(i,3),'filled','MarkerFaceColor',color);
        else
            color = [1 0 0];
            c = scatter3(reference_coordinate_values(i,1),reference_coordinate_values(i,2),reference_coordinate_values(i,3),'filled','MarkerFaceColor',color);
        end
        
        
        
    end
    %cmap = interp1([0 1 0; 1 1 0; 1 0.5 0; 1 0 0], linspace(1, 4, 4));
    cmap = interp1([0 1 0; 1 1 0; 1 0.5 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0], linspace(1, 8, 8));
    colormap(cmap)
    cbh = colorbar;
    cbh.Label.String = '[mm]';
    caxis([0 16])
    set(gca,'XLim', [-150 150])
    set(gca,'YLim', [-150 150])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%














%%%%%%%%%CALCULATE PERCENTAGE ERROR BETWEEN MEASURED AND REFERENCE POINTS%%%%%%%%%%

for i = 1:length(index_for_measuredPoints(1,:))
    
    %Get measured test coordinates
    test_coordinate_values2 = getfield(measured_coordinates,my_field{i,:});
    
    %Get reference coordinate values
    reference_coordinate_values = Reference_points(2:end,:);
    
    %Create names for results
    
    my_field3{i,:} = strcat('Results',num2str(i));
    
    
    
    %calculate the percentage errors between measured and coordinate values
    
    for x = 1:length(reference_coordinate_values(:,1)) %value of how many rows there are in reference coordinate matrix
        for j = 1:length(reference_coordinate_values(1,:)) %value of how many columns there are in reference coordinate matrix
            
            %Percentage errors
            difference_percentile(x,j) = ((abs(test_coordinate_values2(x,j) - reference_coordinate_values(x,j))) / abs(reference_coordinate_values(x,j))) * 100;
 
            
            %store results to struct format
            Percentage_difference.(my_field3{i,:}) = difference_percentile;
        end
        
    end
    
    %Pop out the table for user that contains the results
    figure('Name','Percentage difference between reference & measured points');
    vars = {'X','Y','Z'};
    t = difference_percentile;
    T = table(t);
    uitable('Data',T{:,:},'ColumnName',vars,...
        'Units', 'Normalized', 'Position',[0, 0, 1, 1],'ColumnWidth',{150,100,150});
    
end

%Plot a figure that illustrates the percentage error between measured
%points and reference coordinate values

for i = 1:length(index_for_measuredPoints(1,:))
    
    %Get variable that contains percentage error
    difference_percentile = getfield(Percentage_difference,my_field3{i,:});
    x_axis = linspace(1,length(difference_percentile(:,1)),length(difference_percentile(:,1)));
    figure()
    hold on
    for i = 1:length(difference_percentile(:,1))
        plot(x_axis(1,i),difference_percentile(i,1),'g.')
        plot(x_axis(1,i),difference_percentile(i,2),'b.')
        plot(x_axis(1,i),difference_percentile(i,3),'r.')
        plot(x_axis(1,:),difference_percentile(:,1),'g-')
        plot(x_axis(1,:),difference_percentile(:,2),'b-')
        plot(x_axis(1,:),difference_percentile(:,3),'r-')
    end
    title('Percentage error between measured and reference coordinate points')
    legend('x-coordinate', 'y-coordinate', 'z-coordinate')
    xlabel('Coordinate point number')
    ylabel('[%]')
    hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










%%%%%%%PERCENTAGE ERROR & ABSOLUTE DIFFERENCES BETWEEN SAME X,Y,Z - COORDINATES FOR MULTIPLE FILES%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%
%%%For example, if there are multiple files selected where coordinates are
%%%measured by using the same registration method, it is possible to
%%%calculate the percentage error & absolute differences between point 5 and its
%%%x,y,z-coordinates for each file. For example, how much the value of
%%%x-coordinate will differ for point 5 between the measurements.
%%%%%%%%%%%%%%

%THIS WILL ONLY SHOW CORRECT RESULTS WHEN THE SELECTED FILES ARE
%TAKEN WITH SAME REGISTRATION METHOD AND THERE ARE SAME AMOUNT OF MEASURED
%POINTS IN BOTH FILE. 




%%ONLY TWO MEASUREMENT FILES CAN BE COMPARED AT THE MOMENT%%


if length(index_for_measuredPoints(1,:)) == 2


    for i = 1:length(index_for_measuredPoints(1,:)) - 1
        
        %Get values of measured points of the first file
        first_points = getfield(measured_coordinates,my_field{i,:});
        
        %Get values of measured points of the second file
        second_points = getfield(measured_coordinates,my_field{i+1,:});
        
        %Create names for results
        
        for c = 1:length(index_for_measuredPoints(1,:))
            my_field4{c,:} = strcat('Results',num2str(c));
        end
        
        
        
        %calculate the percentage error between the same measurement points
        %that are taken in different measurements
        
        for x = 1:length(first_points(:,1)) %value of how many rows there are in reference coordinate matrix
            for j = 1:length(first_points(1,:)) %value of how many columns there are in reference coordinate matrix
                
                
                %Calculate percentage errors between the
                %same coordinates between separate measurements
                
                percentageError_between_coords(x,j) = ((abs(second_points(x,j) - first_points(x,j))) / abs(first_points(x,j))) * 100; %Calculate percentage errors
                ABS_diff_between_coords(x,j) = abs(second_points(x,j) - first_points(x,j)); %Calculate absolute differences
                
                %store results to struct formats
                Percentage_difference_betweenCoords.(my_field4{i,:}) = percentageError_between_coords;
                ABS_difference_betweenCoords.(my_field4{i,:}) = ABS_diff_between_coords;
            end
            
        end
        
        %pop out the table for user that contains the results for
        %percentage errors
        figure('Name','Percentage difference between same points for two different measurements');
        vars = {'X','Y','Z'};
        t = percentageError_between_coords;
        T = table(t);
        uitable('Data',T{:,:},'ColumnName',vars,...
            'Units', 'Normalized', 'Position',[0, 0, 1, 1],'ColumnWidth',{150,100,150});
        
        %pop out the table for user that contains the results for
        %absolute differences
        figure('Name','The absolute difference between the same points for two different measurements');
        vars = {'X','Y','Z'};
        t = ABS_diff_between_coords;
        T = table(t);
        uitable('Data',T{:,:},'ColumnName',vars,...
            'Units', 'Normalized', 'Position',[0, 0, 1, 1],'ColumnWidth',{150,100,150});
        
    end
    
%Plot a figure that illustrates the absolute difference between measured
%points in two different measurement files

%Get variable that contains absolute difference
absolute_difference_for_multiple_files = ABS_diff_between_coords;
x_axis = linspace(1,length(ABS_diff_between_coords(:,1)),length(ABS_diff_between_coords(:,1)));
figure()
hold on
for i = 1:length(absolute_difference_for_multiple_files(:,1))
    plot(x_axis(1,i),absolute_difference_for_multiple_files(i,1),'g.')
    plot(x_axis(1,i),absolute_difference_for_multiple_files(i,2),'b.')
    plot(x_axis(1,i),absolute_difference_for_multiple_files(i,3),'r.')
    plot(x_axis(1,:),absolute_difference_for_multiple_files(:,1),'g-')
    plot(x_axis(1,:),absolute_difference_for_multiple_files(:,2),'b-')
    plot(x_axis(1,:),absolute_difference_for_multiple_files(:,3),'r-')
end
title('The absolute difference between measured points for two separate measurement files')
legend('x-coordinate', 'y-coordinate', 'z-coordinate')
xlabel('Coordinate point number')
ylabel('[mm]')
hold off



    
    f = msgbox('All Operations Completed!','Info');
    
else
    
    f = msgbox({'Could not calculate percentage difference between the same points for multiple measurement files because there are not 2 selected'; ' '; ...        
        '                                   Other operations completed!'}, 'Info');
    
    
end


clear absolute_difference
clear difference_percentile
clear ABS_difference_vector
clear b
clear c
clear h
if length(index_for_measuredPoints(1,:)) == 2
    clear percentageError_between_coords
    clear ABS_diff_between_coords
    clear absolute_difference_for_multiple_files
end


%%%%%%READ FUNCTIONS FOR EXCEL FILES#%%%%%%%%%%


function Referenssipisteetdata1_1 = importfile(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  REFERENSSIPISTEETDATA11 = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the numeric data.
%
%  REFERENSSIPISTEETDATA11 = IMPORTFILE(FILE, SHEET) reads from the
%  specified worksheet.
%
%  REFERENSSIPISTEETDATA11 = IMPORTFILE(FILE, SHEET, DATALINES) reads
%  from the specified worksheet for the specified row interval(s).
%  Specify DATALINES as a positive scalar integer or a N-by-2 array of
%  positive scalar integers for dis-contiguous row intervals.
%
%  Example:
%  Referenssipisteetdata11 = importfile("C:\Users\Data\Referenssipisteet_data1_1.xlsx", "Taul1", [1, 90]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 03-Nov-2021 07:01:12

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [1, 90];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "B" + dataLines(1, 1) + ":D" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["X", "Y", "Z"];
opts.VariableTypes = ["double", "double", "double"];

% Import the data
Referenssipisteetdata1_1 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "B" + dataLines(idx, 1) + ":D" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Referenssipisteetdata1_1 = [Referenssipisteetdata1_1; tb]; %#ok<AGROW>
end

%% Convert to output type
Referenssipisteetdata1_1 = table2array(Referenssipisteetdata1_1);
end


function Referenssipisteet = importfile2(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  REFERENSSIPISTEET = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the numeric data.
%
%  REFERENSSIPISTEET = IMPORTFILE(FILE, SHEET) reads from the specified
%  worksheet.
%
%  REFERENSSIPISTEET = IMPORTFILE(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  Referenssipisteet = importfile("C:\Users\Data\Referenssipisteet.xlsx", "Taul1", [1, 65]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 03-Nov-2021 07:16:49

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [1, 65];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "B" + dataLines(1, 1) + ":D" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["X", "Y", "Z"];
opts.VariableTypes = ["double", "double", "double"];

% Import the data
Referenssipisteet = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "B" + dataLines(idx, 1) + ":D" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Referenssipisteet = [Referenssipisteet; tb]; %#ok<AGROW>
end

%% Convert to output type
Referenssipisteet = table2array(Referenssipisteet);
end

function Mittauspisteet = importfile3(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  MITTAUSPISTEET = IMPORTFILE(FILE) reads data from the first worksheet
%  in the Microsoft Excel spreadsheet file named FILE.  Returns the
%  numeric data.
%
%  MITTAUSPISTEET = IMPORTFILE(FILE, SHEET) reads from the specified
%  worksheet.
%
%  MITTAUSPISTEET = IMPORTFILE(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  Mittauspisteet = importfile("C:\Users\Data\Mittauspisteet.xlsx", "Taul1", [4, 92]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 08-Nov-2021 14:11:47

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [4, 92];
end

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "I" + dataLines(1, 1) + ":K" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["X", "Y", "Z"];
opts.VariableTypes = ["double", "double", "double"];

% Import the data
Mittauspisteet = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "I" + dataLines(idx, 1) + ":K" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Mittauspisteet = [Mittauspisteet; tb]; %#ok<AGROW>
end

%% Convert to output type
Mittauspisteet = table2array(Mittauspisteet);
end


function Kaikkimittauspisteetdatalle12 = importfile4(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  KAIKKIMITTAUSPISTEETDATALLE12 = IMPORTFILE(FILE) reads data from the
%  first worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the numeric data.
%
%  KAIKKIMITTAUSPISTEETDATALLE12 = IMPORTFILE(FILE, SHEET) reads from
%  the specified worksheet.
%
%  KAIKKIMITTAUSPISTEETDATALLE12 = IMPORTFILE(FILE, SHEET, DATALINES)
%  reads from the specified worksheet for the specified row interval(s).
%  Specify DATALINES as a positive scalar integer or a N-by-2 array of
%  positive scalar integers for dis-contiguous row intervals.
%
%  Example:
%  Kaikkimittauspisteetdatalle12 = importfile("C:\Users\Data\Kaikki mittauspisteet datalle 1-2.xlsx", "Taul1", [4, 67]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 08-Nov-2021 14:17:24

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [4, 67];
end

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "I" + dataLines(1, 1) + ":K" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["X", "Y", "Z"];
opts.VariableTypes = ["double", "double", "double"];

% Import the data
Kaikkimittauspisteetdatalle12 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "I" + dataLines(idx, 1) + ":K" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Kaikkimittauspisteetdatalle12 = [Kaikkimittauspisteetdatalle12; tb]; %#ok<AGROW>
end

%% Convert to output type
Kaikkimittauspisteetdatalle12 = table2array(Kaikkimittauspisteetdatalle12);
end

function POINTCLOUDCOORDINATES = importfile5(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  POINTCLOUDCOORDINATES1 = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the numeric data.
%
%  POINTCLOUDCOORDINATES1 = IMPORTFILE(FILE, SHEET) reads from the
%  specified worksheet.
%
%  POINTCLOUDCOORDINATES1 = IMPORTFILE(FILE, SHEET, DATALINES) reads
%  from the specified worksheet for the specified row interval(s).
%  Specify DATALINES as a positive scalar integer or a N-by-2 array of
%  positive scalar integers for dis-contiguous row intervals.
%
%  Example:
%  POINTCLOUDCOORDINATES = importfile("C:\Users\Data\POINTCLOUD_COORDINATES.xlsx", "Taul1", [2, 238]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 12-Dec-2021 13:01:58

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [2, 238];
end

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "B" + dataLines(1, 1) + ":D" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["X", "Y", "Z"];
opts.VariableTypes = ["double", "double", "double"];

% Import the data
POINTCLOUDCOORDINATES = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "B" + dataLines(idx, 1) + ":D" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    POINTCLOUDCOORDINATES = [POINTCLOUDCOORDINATES; tb]; %#ok<AGROW>
end

%% Convert to output type
POINTCLOUDCOORDINATES = table2array(POINTCLOUDCOORDINATES);
end