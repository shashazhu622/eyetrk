clear all
direct = '/Users/shz4003/Desktop/trk_copy';
direc = dir(direct);
num_subdir = size(direc, 1);
how_many_unique = zeros(84,1);
j = 0; % counter - counts how many trk files you will work on
figure(1)
tiledlayout(2,3)
for i = 4:num_subdir %the number of the folders in the direct 
    fs = dir([direct '/' direc(i).name]);
    for ii = 3: size(fs, 1) %the number of files in each sub folder
        curr_file = [fs(ii).folder '/' fs(ii).name];
    % check if .trk with 
        if and(strcmp(curr_file(end-2:end), 'trk'), (fs(ii).bytes > 0))
            j = j + 1;
            str=['cat ' curr_file ' | sed ''1,5d;$d'' | grep -v Trigger | awk ''{print $1}'' '] ;
            [jk, a]=system(str);
            % does not work for the weird file for an unknown reason;
            % str2num seems to work
            ave.b=diff(str2num(a));
            nexttile
            scatter(1:numel(ave.b), ave.b, '.k')
            xlabel('timepoints'); ylabel('delay between adjacent frames, ms')
            title(curr_file)
            % ave.b=diff(ave.a);
%             imcurious.which_values(j) = {unique(ave.b)};
%             imcurious.how_many_unique(j) = numel(imcurious.which_values);
%             imcurious.in_which_file(j) = {curr_file};
%             imcurious.max_val(j) = max(ave.b);
%             imcurious.min_val(j) = min(ave.b);
        end
    end
end
% 
% for i = 1:numel(imcurious.which_values)
%     imcurious.which_values{i} % this type of indexing expands cell values as their type
% end
