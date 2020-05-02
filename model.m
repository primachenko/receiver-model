fd=50000;
td=1/fd;
N=1024*64;
t=0:td:N*td;

freq0=1000;
mag0=1;
ph0=0;

freq1=1500;
mag1=1;
ph1=0;
clear;

fd=59000;
td=1/fd;
N=1024*4;
t=0:td:N*td;

freqLow=1000;
magLow=0.5;
phLow=0;

freqHigh=1500;
magHigh=0.5;
phHigh=0;

freq50=50;
mag50=2;
ph50=0;

WITH_NOISE=false;
NOISE_PWR=1;

RANDOM_DATA=false;

DRAW_SOURCE=true;
DRAW_RESULTS=true;

DUMP_PARAM=false;

signalLow=magLow*sin(2*pi*freqLow*t+phLow);
signalHigh=magHigh*sin(2*pi*freqHigh*t+phHigh);
noise50=mag50*sin(2*pi*freq50*t+ph50);

BitNum=2;
Nbit=N/BitNum;

if RANDOM_DATA
    data = randi([0 1],ceil(N/Nbit),1);
else
    for j=1:BitNum
        if (0 == mod(j,2))
            data(j) = 0;
        elseif (1 == mod(j,2))
            data(j) = 1;
        end
    end
end

disp(data);

dataLen=length(data);
signal=0*t;
for i=1:dataLen
    if data(i)==0
        for idx=(i-1)*Nbit+1:i*Nbit+1
            signal(idx)=signalLow(idx);
            dataSignal(idx)=0;
        end
    else
        for idx=(i-1)*Nbit+1:i*Nbit+1
            signal(idx)=signalHigh(idx);
            dataSignal(idx)=1;
        end
    end
    if idx+Nbit > N+1
        break
    end
end

% mix with 50 hz noise
signalWith50=signal+noise50;
snr=magHigh/mag50;

if WITH_NOISE
    signalWithNoise = signalWith50 + wgn(N, 1, NOISE_PWR);
else
    signalWithNoise = signalWith50;
end

% filtration 50 hz
fc=500;
fc_n=fc/(fd/2);
[filterB50,filterA50]=butter(4,fc_n,'high');
signalFiltered=filter(filterB50,filterA50,signalWithNoise);

% select freqLow
freqLow=1000;
freqLow_l=700/(fd/2);
freqLow_h=1100/(fd/2);
[filterBLow,filterALow]=butter(5,[freqLow_l freqLow_h]);
signalFreqLow=filter(filterBLow,filterALow,signalFiltered);

envelFreqLow=filter(ones([1 125]),1,abs(signalFreqLow));
envelFreqLowNorm = envelFreqLow/max(envelFreqLow);

% select freqHigh
freqHigh=1500;
freqHigh_l=1300/(fd/2);
ffreqHigh_h=2000/(fd/2);
[filterBHigh,filterAHigh]=butter(5,[freqHigh_l ffreqHigh_h]);
signalFreqHigh=filter(filterBHigh,filterAHigh,signalFiltered);

envelFreqHigh=filter(ones([1 75]),1,abs(signalFreqHigh));
envelFreqHighNorm = envelFreqHigh/max(envelFreqHigh);

% compare freqLow and freqHigh
state = 0;
demod = 0*t;
for idx=1:length(envelFreqLowNorm)
    if state == 0
        if envelFreqLowNorm(idx) <= envelFreqHighNorm(idx)
            state = 1;
            demod(idx) = 1;
        else
            demod(idx) = 0;
        end
    elseif state == 1
        if envelFreqLowNorm(idx) > envelFreqHighNorm(idx)
            state = 0;
            demod(idx) = 0;
        else
            demod(idx) = 1;
        end
    end
end

if DRAW_SOURCE
    sourceFigure=figure();
    set(sourceFigure,'color','w');
    set(sourceFigure,'Position',[100 100 800 800]);
    subplot(5,1,1);
    plot(t, signalLow, 'k-');
    ylim([min(signalLow)-1 max(signalLow)+1]);
    xlabel('t, с');
    ylabel('а');

    subplot(5,1,2);
    plot(t, signalHigh, 'k-');
    ylim([min(signalHigh)-1 max(signalHigh)+1]);
    xlabel('t, с');
    ylabel('б');

    subplot(5,1,3);
    plot(t, dataSignal, 'k-');
    ylim([min(dataSignal)-1 max(dataSignal)+1]);
    xlabel('t, с');
    ylabel('в');

    subplot(5,1,4);
    plot(t, signal, 'k-');
    ylim([min(signal)-1 max(signal)+1]);
    xlabel('t, с');
    ylabel('г');

    subplot(5,1,5);
    plot(t, signalWithNoise, 'k-');
    ylim([min(signalWithNoise)-1 max(signalWithNoise)+1]);
    xlabel('t, с');
    ylabel('д');
end
    
if DRAW_RESULTS
    resultsFigure=figure();
    set(resultsFigure,'color','w');
    set(resultsFigure,'Position',[200 200 800 800]);
    subplot(6,1,1);
    plot(t, signalWithNoise, 'k-');
    ylim([min(signalWithNoise)-1 max(signalWithNoise)+1]);
    xlabel('t, с');
    ylabel('а');

    subplot(6,1,2);
    plot(t, signalFiltered, 'k-');
    ylim([min(signalFiltered)-1 max(signalFiltered)+1]);
    xlabel('t, с');
    ylabel('б');

    subplot(6,1,3);
    plot(t, signalFreqLow, 'k-');
    ylim([min(signalFreqLow)-1 max(signalFreqLow)+1]);
    xlabel('t, с');
    ylabel('в');
  
    subplot(6,1,4);
    plot(t, signalFreqHigh, 'k-');
    ylim([min(signalFreqHigh)-1 max(signalFreqHigh)+1]);
    xlabel('t, с');
    ylabel('г');

    subplot(6,1,5);
    plot(t, envelFreqLowNorm, 'k-', t, envelFreqHighNorm, 'k--');
    ylim([min(envelFreqLowNorm)-1 max(envelFreqLowNorm)+1]);
    xlabel('t, с');
    ylabel('д');
    
    subplot(6,1,6);
    plot(t, demod, 'k-');
    ylim([min(demod)-1 max(demod)+1]);
    xlabel('t, с');
    ylabel('е');
end

if DUMP_PARAM
    fd = fopen("Z:\projects\receiver\data-source", 'w');
    if (-1 ~= fd)
        fwrite(fd, s, 'double');
        fclose(fd);
    end
    fd = fopen("Z:\projects\receiver\filters.txt", 'w');
    if (-1 ~= fd)
        fprintf(fd,'iir 50hz\n');
        fprintf(fd,'%s %u\n', "a", length(filterA50));
        for i=1:length(filterA50)
            fprintf(fd, '%5.30f\n', filterA50(i));
        end
        fprintf(fd,'%s %u\n', "b", length(filterB50));
        for i=1:length(filterB50)
            fprintf(fd, '%5.30f\n', filterB50(i));
        end
        fprintf(fd,'iir 200hz\n');
        fprintf(fd,'%s %u\n', "a", length(filterALow));
        for i=1:length(filterALow)
            fprintf(fd, '%5.30f\n', filterALow(i));
        end
        fprintf(fd,'%s %u\n', "b", length(filterBLow));
        for i=1:length(filterBLow)
            fprintf(fd, '%5.30f\n', filterBLow(i));
        end
        fprintf(fd,'iir 400hz\n');
        fprintf(fd,'%s %u\n', "a", length(filterAHigh));
        for i=1:length(filterAHigh)
            fprintf(fd, '%5.30f\n', filterAHigh(i));
        end
        fprintf(fd,'%s %u\n', "b", length(filterBHigh));
        for i=1:length(filterBHigh)
            fprintf(fd, '%5.30f\n', filterBHigh(i));
        end
        fclose(fd);
    end
end
freqn=50;
magn=0;
phn=0;

signal0=mag0*sin(2*pi*freq0*t+ph0);
signal1=mag1*sin(2*pi*freq1*t+ph1);
noise=magn*sin(2*pi*freqn*t+phn);

BitNum=16;
Nbit=N/BitNum;

% data = randi([0 1],ceil(N/Nbit),1);
for j=1:BitNum
    if (0 == mod(j,2))
        data(j) = 0;
    elseif (1 == mod(j,2))
        data(j) = 1;
    end
end
% disp(data);
% data = [0 1 0 1 0 1 0 1 0 1 0 1 0 1];

data_len=length(data);
signal=0*t;
for i=1:data_len
    if data(i)==0
        for idx=(i-1)*Nbit+1:i*Nbit+1
            signal(idx)=signal0(idx);
            data_signal(idx)=0;
        end
    else
        for idx=(i-1)*Nbit+1:i*Nbit+1
            signal(idx)=signal1(idx);
            data_signal(idx)=1;
        end
    end
    if idx+Nbit > N
        break
    end
end

% mix with 50 hz noise
 s=signal+noise;
 snr=mag1/magn;

 % filtration 50hz
 fc=100;
 fc_n=fc/(fd/2);
 [b50,a50]=butter(4,fc_n,'high');
 s_butter_hpf=filter(b50,a50,s);

 % select 200 hz
 f200=200;
 f200_l=700/(fd/2);
 f200_h=1100/(fd/2);
 [b200,a200]=butter(5,[f200_l f200_h]);
 %freqz(b200,a200);
 %figure();
 s_butter_hpf200=filter(b200,a200,s_butter_hpf);

 s_butter_hpf200_align=filter(ones([1 75]),1,abs(s_butter_hpf200));
 s200n = s_butter_hpf200_align/max(s_butter_hpf200_align(1000:N));
 
 % select 400hz
 f400=400;
 f400_l=1300/(fd/2);
 f400_h=2000/(fd/2);
 [b400,a400]=butter(5,[f400_l f400_h]);
 s_butter_hpf400=filter(b400,a400,s_butter_hpf);
 s_butter_hpf400_align=filter(ones([1 75]),1,abs(s_butter_hpf400));
 s400n = s_butter_hpf400_align/max(s_butter_hpf400_align(1000:N));
 
 % draw results
 subplot(5,1,1);
 plot(s);
  ylim([-1.5 1.5 ]);
 xlabel('time, ms');
 ylabel('source signal');
 subplot(5,1,3);
 plot(t, s_butter_hpf200, t, s200n);
 ylim([-1.5 1.5 ]);
 xlabel('time, ms');
 ylabel('200 Hz signal');
 % subplot(3,1,1); plot(t, s200n); ylim([-0.5 1.5 ]);
 subplot(5,1,4);
 plot(t, s_butter_hpf400, t, s400n);
 ylim([-1.5 1.5 ]);
 xlabel('time, ms');
 ylabel('400 Hz signal');
 % subplot(3,1,2); plot(t, s400n); ylim([-0.5 1.5 ]);
 subplot(5,1,2);
 plot(t, data_signal);
 ylim([-0.5 1.5 ]);
 xlabel('time, ms');
 ylabel('source data');

 hlvl = 0.6*Nbit;
 llvl = 0.4*Nbit;
 demod = 0*t;
 sum = 0;
 shift=150;
 corr=300;
 for sample=shift:length(s200n)
     sum = sum + s200n(sample);
     if (sample-shift > 0 && 0 == mod((sample-shift),Nbit))
         if (sum >= hlvl)
            val = 1;
         elseif (sum <= llvl)
            val = 0;
         else
             val = 0.5;
         end
         k = (sample-shift)/Nbit;
         for i=(k*Nbit+1)-shift:((k+1)*Nbit)-shift
             if (i == length(s200n))
                 break;
             end
             demod(i-shift-corr) = val;
         end
         sum=0;
     end
 end
 subplot(5,1,5);
 plot(t, demod);
 ylim([-0.5 1.5 ]);
 xlabel('time, ms');
 ylabel('received data');
%
 fd = fopen("Z:\projects\receiver\data-source", 'w');
 fwrite(fd, s, 'double');
 fclose(fd);
 
 fd = fopen("Z:\projects\receiver\filters.txt", 'w');
 fprintf(fd,'iir 50hz\n');
 fprintf(fd,'%s %u\n', "a", length(a50));
 for i=1:length(a50)
     fprintf(fd, '%5.30f\n', a50(i));
 end
 fprintf(fd,'%s %u\n', "b", length(b50));
 for i=1:length(b50)
     fprintf(fd, '%5.30f\n', b50(i));
 end
 fprintf(fd,'iir 200hz\n');
 fprintf(fd,'%s %u\n', "a", length(a200));
 for i=1:length(a200)
     fprintf(fd, '%5.30f\n', a200(i));
 end
 fprintf(fd,'%s %u\n', "b", length(b200));
 for i=1:length(b200)
     fprintf(fd, '%5.30f\n', b200(i));
 end
 fprintf(fd,'iir 400hz\n');
 fprintf(fd,'%s %u\n', "a", length(a400));
 for i=1:length(a400)
     fprintf(fd, '%5.30f\n', a400(i));
 end
 fprintf(fd,'%s %u\n', "b", length(b400));
 for i=1:length(b400)
     fprintf(fd, '%5.30f\n', b400(i));
 end
 fclose(fd);
 %}
