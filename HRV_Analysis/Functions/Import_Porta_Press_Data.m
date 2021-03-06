function [data_mat,Variable_Names] = Import_Porta_Press_Data(filename)

        %% Import data from text file.
        % Script for importing data from portapress properly
        %
       

        %% Read columns of data as text:
        % For more information, see the TEXTSCAN documentation.
        formatSpec = '%7s%15s%6s%6s%4s%6s%4s%6s%6s%7s%9s%4s%6s%s%[^\n\r]';

        %% Open the text file.
        fileID = fopen(filename,'r');

        %% Read columns of data according to the format.
        % This call is based on the structure of the file used to generate this
        % code. If an error occurs for a different file, try regenerating the code
        % from the Import Tool.
        dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);

        %% Close the text file.
        fclose(fileID);

        %% Convert the contents of columns containing numeric text to numbers.
        % Replace non-numeric text with NaN.
        raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
        for col=1:length(dataArray)-1
            raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
        end
        numericData = NaN(size(dataArray{1},1),size(dataArray,2));

        for col=1:14
            % Converts text in the input cell array to numbers. Replaced non-numeric
            % text with NaN.
            rawData = dataArray{col};
            for row=1:size(rawData, 1)
                % Create a regular expression to detect and remove non-numeric prefixes and
                % suffixes.
                regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\.]*)+[\,]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\.]*)*[\,]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                try
                    result = regexp(rawData(row), regexstr, 'names');
                    numbers = result.numbers;

                    % Detected commas in non-thousand locations.
                    invalidThousandsSeparator = false;
                    if numbers.contains('.')
                        thousandsRegExp = '^[-/+]*\d+?(\.\d{3})*\,{0,1}\d*$';
                        if isempty(regexp(numbers, thousandsRegExp, 'once'))
                            numbers = NaN;
                            invalidThousandsSeparator = true;
                        end
                    end
                    % Convert numeric text to numbers.
                    if ~invalidThousandsSeparator
                        numbers = strrep(numbers, '.', '');
                        numbers = strrep(numbers, ',', '.');
                        numbers = textscan(char(numbers), '%f');
                        numericData(row, col) = numbers{1};
                        raw{row, col} = numbers{1};
                    end
                catch
                    raw{row, col} = rawData{row};
                end
            end
        end
        %% get variables names
        Variable_Names = raw(1,:);


        %% Find References
        %index_Event = find(strcmp(' EVENTM',raw(:,3)));
        index_Event = find(strcmp('ARK',raw(:,4)));

        %BaseLine_Mat = cell2mat( raw(25:index_Event(1)-1,:) ); % find a char that is reliable
        data_mat = cell2mat( raw(index_Event(2)+1:index_Event(3)-1,:) );

        % normalize for the first value
        %BaseLine_Mat(:,1) = BaseLine_Mat(:,1) - BaseLine_Mat(1,1);
        data_mat(:,1) = data_mat(:,1) - data_mat(1,1);

        %% Replace non-numeric cells with NaN
        R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
        raw(R) = {NaN}; % Replace non-numeric cells

        %% Clear temporary variables
        clearvars filename formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;
end
