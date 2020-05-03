clear;
fd=59000;
fs=2*fd;
td=1/fd;
N=1024*64;
Nlim=1024*8;
t=0:td:Nlim*td;
f=fd*(0:Nlim/2)/Nlim;

% SOURCE PARAM
PATH_TO_ORIG_FILE = "Z:\projects\receiver\original";

% EXPORT PARAM
EXPORT_FILTER_PARAM=true;
PATH_TO_FILTERS = "Z:\projects\receiver\filters.txt";

% DRAW PARAM
DRAW_SOURCE=true;
DRAW_FILTER_50=true;
DRAW_FREQ_LOW=true;
DRAW_FREQ_HIGH=true;
DRAW_DETECTOR=true;
DRAW_SPEC=true;

DRAW_MODEL_RESULTS=true;

% read from file
fileFd = fopen(PATH_TO_ORIG_FILE);
if (-1 ~= fileFd)
    raw=fread(fileFd, 'double');
    fclose(fileFd);
end

% random phase
shift=randi(N/2);
signalReal=raw(shift:shift+Nlim);

% 50hz filtration
fc50=750;
fc_n=fc50/(fd/2);
[filterB50,filterA50]=butter(8,fc_n,'high');
signalFiltered=filter(filterB50,filterA50,signalReal);

% select freqLow
f1c=1000;
f1c_l=750/(fd/2);
f1c_h=1100/(fd/2);
[filterBLow,filterALow]=butter(4,[f1c_l f1c_h]);
signalFreqLow=filter(filterBLow,filterALow,signalFiltered);

% aling
envelFreqLow=filter(ones([1 100]),1,abs(signalFreqLow));

% normalize
envelFreqLowNorm=envelFreqLow/max(envelFreqLow);

% select freqHigh
f2c=1500;
f2c_l=1300/(fd/2);
f2c_h=1750/(fd/2);
[filterBHigh,filterAHigh]=butter(4,[f2c_l f2c_h]);
signalFreqHigh=filter(filterBHigh,filterAHigh,signalFiltered);

% aling
envelFreqHigh=filter(ones([1 50]),1,abs(signalFreqHigh));

% normalize
envelFreqHighNorm=envelFreqHigh/max(envelFreqHigh);

% detection
dataReceived = detectByComp(envelFreqLowNorm, envelFreqHighNorm, t);

if (DRAW_SPEC)
    signalRealSpec=abs(fftshift(fft(signalReal)));
    signalRealSpec=signalRealSpec(Nlim/2:Nlim);

    signalFilteredSpec=abs(fftshift(fft(signalFiltered)));
    signalFilteredSpec=signalFilteredSpec(Nlim/2:Nlim);

    signalFreqLowSpec=abs(fftshift(fft(signalFreqLow)));
    signalFreqLowSpec=signalFreqLowSpec(Nlim/2:Nlim);

    signalFreqHighSpec=abs(fftshift(fft(signalFreqHigh)));
    signalFreqHighSpec=signalFreqHighSpec(Nlim/2:Nlim);
end

if (DRAW_SOURCE)
    sourceFigure=figure();
    set(sourceFigure,'color','w');
    set(sourceFigure,'Position',[100 100 1600 400]);
    subplot(1,1+DRAW_SPEC,1);
    plot(t, signalReal, 'k-');
    xlim([min(t) max(t)]);
    ylim([min(signalReal) max(signalReal)]);
    xlabel('Время, с');
    ylabel('source signal');
    if (DRAW_SPEC)
        subplot(1,2,2);
        plot(f,signalRealSpec, 'k-');
        xlim([min(0) max(3000)]);
        ylim([min(signalRealSpec(10:3000)) max(signalRealSpec(10:3000))]);
        xlabel('Частота, Гц');
        ylabel('source signal spec');
    end
end
if (DRAW_FILTER_50)
    filter50Figure=figure();
    set(filter50Figure,'color','w');
    set(filter50Figure,'Position',[200 200 1600 400]);
    subplot(1,1+DRAW_SPEC,1);
    plot(t, signalFiltered, 'k-');
    xlim([min(t) max(t)]);
    ylim([min(signalFiltered(1000:Nlim)) max(signalFiltered(1000:Nlim))]);
    xlabel('Время, с');
    ylabel('filtered signal');
    if (DRAW_SPEC)
        subplot(1,2,2);
        plot(f,signalFilteredSpec, 'k-');
        xlim([min(0) max(3000)]);
        ylim([min(signalFilteredSpec(10:3000)) max(signalFilteredSpec(10:3000))]);
        xlabel('Частота, Гц');
        ylabel('filtered signal spec');
    end
end
if (DRAW_FREQ_LOW)
    freqLowFigure=figure();
    set(freqLowFigure,'color','w');
    set(freqLowFigure,'Position',[300 300 1600 400]);
    subplot(1,1+DRAW_SPEC,1);
    plot(t, signalFreqLow, 'k-');
    xlim([min(t) max(t)]);
    ylim([min(signalFreqLow(1000:Nlim)) max(signalFreqLow(1000:Nlim))]);
    xlabel('Время, с');
    ylabel('freqLow signal');
    if (true == DRAW_SPEC)
        subplot(1,2,2);
        plot(f,signalFreqLowSpec, 'k-');
        xlim([min(0) max(3000)]);
        ylim([min(signalFreqLowSpec(10:3000)) max(signalFreqLowSpec(10:3000))]);
        xlabel('Частота, Гц');
        ylabel('freqLow signal spec');
    end
end
if (DRAW_FREQ_HIGH)
    freqHighFigure=figure();
    set(freqHighFigure,'color','w');
    set(freqHighFigure,'Position',[400 400 1600 400]);
    subplot(1,1+DRAW_SPEC,1);
    plot(t, signalFreqHigh, 'k-');
    xlim([min(t) max(t)]);
    ylim([min(signalFreqHigh(1000:Nlim)) max(signalFreqHigh(1000:Nlim))]);
    xlabel('Время, с');
    ylabel('freqHigh signal');
    if (DRAW_SPEC)
        subplot(1,2,2);
        plot(f,signalFreqHighSpec, 'k-');
        xlim([min(0) max(3000)]);
        ylim([min(signalFreqHighSpec(10:3000)) max(signalFreqHighSpec(10:3000))]);
        xlabel('Частота, Гц');
        ylabel('freqHigh signal spec');
    end
end

if (DRAW_DETECTOR)
    detectorFigure=figure();
    set(detectorFigure,'color','w');
    set(detectorFigure,'Position',[500 500 800 800]);
    plot(t, dataReceived, 'k-');
    xlim([min(t) max(t)]);
    ylim([min(dataReceived) max(dataReceived)]);
    xlabel('Время, с');
    ylabel('signal');
end

% DRAW LIKE MODEL.m   
if DRAW_MODEL_RESULTS
    resultsFigure=figure();
    set(resultsFigure,'color','w');
    set(resultsFigure,'Position',[600 600 800 800]);
    subplot(6,1,1);
    plot(t, signalReal, 'k-');
    ylim([min(signalReal)-1 max(signalReal)+1]);
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
    plot(t, dataReceived, 'k-');
    ylim([min(dataReceived)-1 max(dataReceived)+1]);
    xlabel('t, с');
    ylabel('е');
end

% EXPORT
if (EXPORT_FILTER_PARAM)
    fileFd = fopen(PATH_TO_FILTERS, 'w');
    if (-1 ~= fileFd)
        fprintf(fileFd,'iir 50hz\n');
        fprintf(fileFd,'%s %u\n', "a", length(filterA50));
        for i=1:length(filterA50)
            fprintf(fileFd, '%5.30f\n', filterA50(i));
        end
        fprintf(fileFd,'%s %u\n', "b", length(filterB50));
        for i=1:length(filterB50)
            fprintf(fileFd, '%5.30f\n', filterB50(i));
        end
        fprintf(fileFd,'iir 200hz\n');
        fprintf(fileFd,'%s %u\n', "a", length(filterALow));
        for i=1:length(filterALow)
            fprintf(fileFd, '%5.30f\n', filterALow(i));
        end
        fprintf(fileFd,'%s %u\n', "b", length(filterBLow));
        for i=1:length(filterBLow)
            fprintf(fileFd, '%5.30f\n', filterBLow(i));
        end
        fprintf(fileFd,'iir 400hz\n');
        fprintf(fileFd,'%s %u\n', "a", length(filterAHigh));
        for i=1:length(filterAHigh)
            fprintf(fileFd, '%5.30f\n', filterAHigh(i));
        end
        fprintf(fileFd,'%s %u\n', "b", length(filterBHigh));
        for i=1:length(filterBHigh)
            fprintf(fileFd, '%5.30f\n', filterBHigh(i));
        end
        fclose(fileFd);
    end
end

% detection

% compare envelLow and envelHigh
function dataReceived = detectByComp(envelLow, envelHigh, t)
    STATE_HIGH=1;
    STATE_LOW=0;
    STATE_UNDEF=0.5;
    state = STATE_LOW;
    dataReceived = 0*t;
    safeInterval=1024;

    DETECTOR_HAS_HYSTERESIS=true;
    DETECTOR_HYST_COEF=1.2;

    for idx=1:length(envelLow)
        if (idx < safeInterval)
            dataReceived(idx)=STATE_UNDEF;
        end
        if state == STATE_LOW
            if envelLow(idx)*DETECTOR_HYST_COEF <= envelHigh(idx)
                state = STATE_HIGH;
            end
        elseif state == STATE_HIGH
            if envelLow(idx) > envelHigh(idx)*DETECTOR_HYST_COEF
                state = STATE_LOW;
            end
        end
        dataReceived(idx) = state;
    end
end

% detect by trashhold
function data_received = detect_by_trashhold(data)
    AP=1100;    % average period
    hlvl=0.6;   % lvl switch low-high
    llvl=0.4;   % lvl switch high-low
    HIGH=1;     % state search low-high
    LOW=2;      % state search high-low
    INIT=0;     % state calc normalize coef

    data_len = length(data);
    state=INIT;
    prev_switch=1;
    data_received=data*0;
    align=0;

    for i=1:data_len
        if (i == 2*AP)
            state = LOW;
            fprintf("init done, align=%f\n", align);
        end

        if (align < data(i))
            align = data(i);
        end

        data(i) = data(i)/align;

        if (INIT == state)
            continue;
        end

        if (hlvl < data(i))
            if (HIGH ~= state)
                state=HIGH;
                if (AP < i - prev_switch)
                    fprintf("low period %d\n", i - prev_switch);
                    for j=prev_switch:i
                        data_received(j)=0;
                    end
                else
                    fprintf("low period %d, so small, ignore\n", i - prev_switch);
                end
                prev_switch = i;
            end
        end

        if (llvl > data(i))
            if (LOW ~= state)
                state=LOW;
                if (AP < i - prev_switch)
                    fprintf("high period %d\n", i - prev_switch);
                    for j=prev_switch:i
                        data_received(j)=1;
                    end
                else
                    fprintf("high period %d, so small, ignore\n", i - prev_switch);
                end
                prev_switch=i;
            end
        end
    end
end
