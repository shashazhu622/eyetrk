function [ave] = frame(filename)


str=['cat ' filename ' | sed ''1,5d;$d'' | grep -v Trigger | awk ''{print $1}'' '] ;
[jk a]=system(str);
ave.a=str2num(a);

ave.b=diff(ave.a);

ave.mean=mean(ave.b);

ave.max=max(ave.b);


histogram(ave.b);
set(gca,'yscale','log');
ylim([0.1, 10e7]);
title(filename);
xlabel('Difference between two subsequent frames in millisecs')
ylabel('Frequency')
saveas(gcf,'/Users/shz4003/Desktop/QC_Frame_Check(Old)/HistogramFile_001.fig'); %change numbers every time we run a new one 

% ave.m =[ave.mean,ave.max];
% writematrix(ave.m,'frame.xls','WriteMode','append');
% writematrix(filename,'frame.xls','WriteMode','append');

end 
% cp <yourfilename> temp.txt
% cp (copy) filename1 (which file) filename2 (name of the copy)

