fd=59000;
fs=2*fd;
td=1/fd;
N=1024*64;
Nlim=1024*16;
t=0:td:Nlim*td;
f=fd*(0:Nlim/2)/Nlim;

% EXPORT PARAM
EXPORT_SOURCE=false;
EXPORT_FILTER_PARAM=true;

% DRAW PARAM
DRAW_SOURCE=false;
DRAW_FILTER_50=false;
DRAW_FREQ1=false;
DRAW_FREQ2=false;
DRAW_DETECTOR=false;
DRAW_SPEC=false;

% random phase
shift=randi(N/2);

source=rawOrig(shift:shift+Nlim);


% 50hz filtration
fc50=500;
fc_n=fc50/(fd/2);
[b50,a50]=butter(8,fc_n,'high');
filter50=filter(b50,a50,source);

%{
% work band filtration
fc_l=800/(fd/2);
fc_h=1700/(fd/2);
[b50,a50]=butter(4,[fc_l fc_h]);
filter50=filter(b50,a50,source);
%}
% first harmonic select
f1c=1000;
f1c_l=750/(fd/2);
f1c_h=1100/(fd/2);
[b200,a200]=butter(4,[f1c_l f1c_h]);
filterFreq1=filter(b200,a200,filter50);

% aling
filterFreq1Aligned=filter(ones([1 100]),1,abs(filterFreq1));

% normalize
filterFreq1Aligned=filterFreq1Aligned/max(filterFreq1Aligned);

% second harmonic select
f2c=1500;
f2c_l=1300/(fd/2);
f2c_h=1750/(fd/2);
[b400,a400]=butter(4,[f2c_l f2c_h]);
filterFreq2=filter(b400,a400,filter50);

% aling
filterFreq2Aligned=filter(ones([1 50]),1,abs(filterFreq2));

dataReceivedFreq1 = detect(filterFreq1Aligned, t, DRAW_DETECTOR);
dataReceivedFreq2 = detect(filterFreq2Aligned, t, DRAW_DETECTOR);

if (DRAW_SPEC)
    sourceSpec=abs(fftshift(fft(source)));
    sourceSpec=sourceSpec(Nlim/2:Nlim);

    filter50Spec=abs(fftshift(fft(filter50)));
    filter50Spec=filter50Spec(Nlim/2:Nlim);

    filterFreq1Spec=abs(fftshift(fft(filterFreq1)));
    filterFreq1Spec=filterFreq1Spec(Nlim/2:Nlim);

    filterFreq2Spec=abs(fftshift(fft(filterFreq2)));
    filterFreq2Spec=filterFreq2Spec(Nlim/2:Nlim);
end

if (DRAW_SOURCE)
    figure();
    subplot(1,1+DRAW_SPEC,1);
    plot(t, source);
    xlim([min(t) max(t)]);
    ylim([min(source) max(source)]);
    xlabel('time, ms');
    ylabel('source signal');
    if (DRAW_SPEC)
        subplot(1,2,2);
        plot(f,sourceSpec);
        xlim([min(0) max(3000)]);
        ylim([min(sourceSpec(10:3000)) max(sourceSpec(10:3000))]);
        xlabel('frequency, Hz');
        ylabel('source signal spec');
    end
end
if (DRAW_FILTER_50)
    figure();
    subplot(1,1+DRAW_SPEC,1);
    plot(t, filter50);
    xlim([min(t) max(t)]);
    ylim([-0.5 0.5]);
    xlabel('time, ms');
    ylabel('filtered signal');
    if (DRAW_SPEC)
        subplot(1,2,2);
        plot(f,filter50Spec);
        xlim([min(0) max(3000)]);
        ylim([min(filter50Spec(10:3000)) max(filter50Spec(10:3000))]);
        xlabel('frequency, Hz');
        ylabel('filtered signal spec');
    end
end
if (DRAW_FREQ1)
    figure();
    subplot(1,1+DRAW_SPEC,1);
    plot(t, filterFreq1);
    xlim([min(t) max(t)]);
    ylim([-0.5 1.5]);
    xlabel('time, ms');
    ylabel('freq1 signal');
    if (true == DRAW_SPEC)
        subplot(1,2,2);
        plot(f,filterFreq1Spec);
        xlim([min(0) max(3000)]);
        ylim([min(filterFreq1Spec(10:3000)) max(filterFreq1Spec(10:3000))]);
        xlabel('frequency, Hz');
        ylabel('freq1 signal spec');
    end
end
if (DRAW_FREQ2)
    figure();
    subplot(1,1+DRAW_SPEC,1);
    plot(t, filterFreq2);
    xlim([min(t) max(t)]);
    ylim([-0.5 1.5]);
    xlabel('time, ms');
    ylabel('freq2 signal');
    if (DRAW_SPEC)
        subplot(1,2,2);
        plot(f,filterFreq2Spec);
        xlim([min(0) max(3000)]);
        ylim([min(filterFreq2Spec(10:3000)) max(filterFreq2Spec(10:3000))]);
        xlabel('frequency, Hz');
        ylabel('freq2 signal spec');
    end
end
if (EXPORT_SOURCE)
    if (-1 ~= fd)
        fd = fopen("Z:\projects\receiver\data-source", 'w');
        fwrite(fd, s, 'double');
        fclose(fd);
    end
end
if (EXPORT_FILTER_PARAM)
    fd = fopen("Z:\projects\receiver\filters.txt", 'w');
    if (-1 ~= fd)
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
    end
end

% detection
function data_received = detect(data, t, DRAW_DETECTOR)
    fprintf("detect start\n");
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
    if (DRAW_DETECTOR)
        figure();
        plot(t, data, t, data_received);
        xlim([min(t) max(t)]);
        ylim([-0.5 1.5]);
        xlabel('time, ms');
        ylabel('signal');
    end
end
