clear;
fd=59000;
fs=2*fd;
td=1/fd;
Nlim=1024*64;
t=0:td:Nlim*td;
f=fd*(0:Nlim/2)/Nlim;

f50=50;
freqLow=1000;
freqHigh=1500;
%{
% filter 50 Hz
fc50=750;
fc_n=fc50/(fd/2);
[b_butter,a_butter]=butter(8,fc_n,'high');
filterButter=freqz(b_butter,a_butter, Nlim/2, fs/2);
figure();
plot(f(1:4096), abs(filterButter));
xlim([0 2500]);
ylim([0 1]);
%}

L=40;
A=1;

% select freqLow
f1c_l=800/(fd/2);
f1c_h=1200/(fd/2);
[b_butter,a_butter]=butter(4,[f1c_l f1c_h]);
filterButter=freqz(b_butter,a_butter, Nlim/2, fs/2);

% f1c_l=900/(fd/2);
% f1c_h=1100/(fd/2);
[b_cheby1,a_cheby1]=cheby1(4,A,[f1c_l f1c_h]);
filterCheby1=freqz(b_cheby1,a_cheby1, Nlim/2, fs/2);

% f1c_l=840/(fd/2);
% f1c_h=1160/(fd/2);
[b_cheby2,a_cheby2]=cheby2(4,L,[f1c_l f1c_h]);
filterCheby2=freqz(b_cheby2,a_cheby2, Nlim/2, fs/2);

% f1c_l=900/(fd/2);
% f1c_h=1100/(fd/2);
[b_ellip,a_ellip]=ellip(4,A,L,[f1c_l f1c_h]);
filterEllip=freqz(b_ellip,a_ellip, Nlim/2, fs/2);

resultsFigure=figure();
set(resultsFigure,'color','w');
set(resultsFigure,'Position',[200 200 800 800]);
plot(f(1:Nlim/2), mag2db(abs(filterButter)), ...
     f(1:Nlim/2), mag2db(abs(filterCheby1)), ...
     f(1:Nlim/2), mag2db(abs(filterCheby2)), ...
     f(1:Nlim/2), mag2db(abs(filterEllip)));
legend('Фильтр Баттерворта','Фильтр Чебышева','Инверсный фильтр Чебышева','Эллиптический фильтр');
xlim([0 2500]);
ylim([-100 0]);
xlabel('Частота, Гц');
ylabel('дБ');
grid on;
%{
% select freqHigh
f2c_l=1400/(fd/2);
f2c_h=1600/(fd/2);
[b_butter,a_butter]=butter(4,[f2c_l f2c_h]);
filterButter=freqz(b_butter,a_butter, Nlim/2, fs/2);
figure();
plot(f(1:4096), abs(filterButter));
xlim([0 2500]);
ylim([0 1]);
%}
