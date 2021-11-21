clc
clear all
close all

disp('what is the group number?');
number_gp=inputdlg ('gp number.=');
q=cellfun(@str2num,number_gp);

disp('what are the surnames of the group members?');
a=inputdlg('enter the first surname= ' ,'s');
b=inputdlg('enter the second surname= ' ,'s');
c=inputdlg('enter the third surname= ' ,'s');

names_sort= [a;b;c];

disp('i sorted your surnames alphabetically');
sort_surnames = sort(names_sort) %sort the surnames

% the paramters giving for the filter
p=mod(q,2);
x=strlength(sort_surnames(1));
y=strlength(sort_surnames(2));
N=(2^p)*[mod(x,2)+1]+6*p; % order of the filter
nb=mod(y,7)+8;


sample_freq= inputdlg('enter the freq (Hz)');
fs=cellfun(@str2num,sample_freq);



disp('p=0 ==>iir ; p=1 ==>fir');

if p==0 type = 'iir filter';
 else
      	type = 'fir filter';

end

sprintf('result of the  parameters are:\ntype=%s\nnumber of bits=nb=%d\nfilter order=N=%d\np=%d\nx=%d\ny=%d',type,nb,N,p,x,y)

pause

if p==0
	my_iir_filter(nb,N,fs)
	else
	my_fir_filter(nb,N,fs)
end

fp=fopen('resultsm.txt','r');
Y=fscanf(fp,'%d');
fclose(fp);
THD=thd(Y)
%%



