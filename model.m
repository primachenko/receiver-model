clear;

fd=59000;
td=1/fd;
N=1024*4;
t=0:td:N*td;
f=fd*(0:N/2)/N;

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

DRAW_SOURCE=false;
DRAW_RESULTS=false;
DRAW_FILTERS=true;

% EXPORT PARAM
PATH_TO_SOURCE_FILE = "Z:\projects\receiver\data-source";
PATH_TO_FILTERS = "Z:\projects\receiver\filters.txt";
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
filter50=freqz(filterB50,filterA50, N/2, fd);

% select freqLow
freqLow=1000;
freqLow_l=700/(fd/2);
freqLow_h=1100/(fd/2);
[filterBLow,filterALow]=butter(5,[freqLow_l freqLow_h]);
signalFreqLow=filter(filterBLow,filterALow,signalFiltered);
filterFreqLow=freqz(filterBLow,filterALow, N/2, fd);

envelFreqLow=filter(ones([1 125]),1,abs(signalFreqLow));
envelFreqLowNorm = envelFreqLow/max(envelFreqLow);

% select freqHigh
freqHigh=1500;
freqHigh_l=1300/(fd/2);
ffreqHigh_h=2000/(fd/2);
[filterBHigh,filterAHigh]=butter(5,[freqHigh_l ffreqHigh_h]);
signalFreqHigh=filter(filterBHigh,filterAHigh,signalFiltered);
filterFreqHigh=freqz(filterBHigh,filterAHigh, N/2, fd);

envelFreqHigh=filter(ones([1 75]),1,abs(signalFreqHigh));
envelFreqHighNorm = envelFreqHigh/max(envelFreqHigh);

% detection
demod = detectByComp(envelFreqLowNorm, envelFreqHighNorm, t);

if DRAW_FILTERS
    filter50Figure=figure();
    set(filter50Figure,'color','w');
    set(filter50Figure,'Position',[100 100 600 600]);
    yyaxis left;
    plot(f(1:N/2), db(abs(filter50)));
    xlim([0 1500]);
    ylim([-100 0]);
    xlabel('Частота, Гц');
    ylabel('дБ');
    yyaxis right;
    plot(f(1:N/2), phase(filter50)*180/pi);
    xlim([0 1500]);
    ylabel('град.');
    grid on;

    filterFreqLowFigure=figure();
    set(filterFreqLowFigure,'color','w');
    set(filterFreqLowFigure,'Position',[100 100 600 600]);
    yyaxis left;
    plot(f(1:N/2), db(abs(filterFreqLow)));
    xlim([0 2500]);
    ylim([-100 0]);
    xlabel('Частота, Гц');
    ylabel('дБ');
    yyaxis right;
    plot(f(1:N/2), phase(filterFreqLow)*180/pi);
    xlim([0 2500]);
    ylabel('град.');
    grid on;
    
    filterFreqHighFigure=figure();
    set(filterFreqHighFigure,'color','w');
    set(filterFreqHighFigure,'Position',[100 100 600 600]);
    yyaxis left;
    plot(f(1:N/2), db(abs(filterFreqHigh)));
    xlim([0 4000]);
    ylim([-100 0]);
    xlabel('Частота, Гц');
    ylabel('дБ');
    yyaxis right;
    plot(f(1:N/2), phase(filterFreqHigh)*180/pi);
    xlim([0 4000]);
    ylabel('град.');
    grid on;
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
    fd = fopen(PATH_TO_SOURCE_FILE, 'w');
    if (-1 ~= fd)
        fwrite(fd, s, 'double');
        fclose(fd);
    end
    fd = fopen(PATH_TO_FILTERS, 'w');
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

% compare envelLow and envelHigh
function dataReceived = detectByComp(envelLow, envelHigh, t)
    STATE_HIGH=1;
    STATE_LOW=0;
    state = STATE_LOW;
    dataReceived = 0*t;
    for idx=1:length(envelLow)
        if state == STATE_LOW
            if envelLow(idx) <= envelHigh(idx)
                state = STATE_HIGH;
            end
        elseif state == STATE_HIGH
            if envelLow(idx) > envelHigh(idx)
                state = STATE_LOW;
            end
        end
        dataReceived(idx) = state;
    end
end
