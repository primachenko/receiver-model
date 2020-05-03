ORIG_READED               = false;
FILTER50_READED           = false;
FILTER_FREQ_LOW_READED    = false;
FILTER_FREQ_HIGH_READED   = false;
FABS_FREQ_LOW_READED      = false;
FABS_FREQ_HIGH_READED     = false;
ALIGN_FREQ_LOW_READED     = false;
ALIGN_FREQ_HIGH_READED    = false;
DETECTOR_FREQ_LOW_READED  = false;
DETECTOR_FREQ_HIGH_READED = false;
BITS_FREQ_LOW_READED      = false;
BITS_FREQ_HIGH_READED     = false;
BITS_RESULT_READED        = false;

PATH = "Z:\projects\receiver\";

ORIG_FILE               = "original";
FILTER50_FILE           = "filter-50";
FILTER_FREQ_LOW_FILE    = "filter-200";
FILTER_FREQ_HIGH_FILE   = "filter-400";
FABS_FREQ_LOW_FILE      = "fabs-200";
FABS_FREQ_HIGH_FILE     = "fabs-400";
ALIGN_FREQ_LOW_FILE     = "align-200";
ALIGN_FREQ_HIGH_FILE    = "align-400";
DETECTOR_FREQ_LOW_FILE  = "detector-200";
DETECTOR_FREQ_HIGH_FILE = "detector-400";
BITS_FREQ_LOW_FILE      = "bits-200";
BITS_FREQ_HIGH_FILE     = "bits-400";
BITS_RESULT_FILE        = "result";

DRAW_SPEC      = false;
DRAW_FILTER    = false;
DRAW_FILTERED  = true;
DRAW_FABS      = false;
DRAW_ALIGN     = true;
DRAW_DETECTORS = false;
DRAW_BITS      = false;
DRAW_RESULT    = false;

DRAW_SOURCE    = true;
DRAW_FILTER50  = true;
DRAW_FREQ_LOW  = true;
DRAW_FREQ_HIGH = true;

if DRAW_SOURCE
    fileFd = fopen(PATH+ORIG_FILE);
    if (-1 ~= fileFd)
        rawOrig=fread(fileFd, 'double');
        fclose(fileFd);
        ORIG_READED=true;
    end
end

fs=58000;
td=1/fs;
N=length(rawOrig)-1;
t=0:td:N*td;
f=-N/(2*N*td):1/(N*td):N/(2*N*td);

if DRAW_FILTER50
    fileFd = fopen(PATH+FILTER50_FILE);
    if (-1 ~= fileFd)
        rawFilter50=fread(fileFd, 'double');
        fclose(fileFd);
        FILTER50_READED=true;
    end
end
if DRAW_FREQ_LOW && DRAW_FILTERED
    fileFd = fopen(PATH+FILTER_FREQ_LOW_FILE);
    if (-1 ~= fileFd)
        rawFilter200=fread(fileFd, 'double');
        fclose(fileFd);
        FILTER_FREQ_LOW_READED=true;
    end
end
if DRAW_FREQ_HIGH && DRAW_FILTERED
    fileFd = fopen(PATH+FILTER_FREQ_HIGH_FILE);
    if (-1 ~= fileFd)
        rawFilter400=fread(fileFd, 'double');
        fclose(fileFd);
        FILTER_FREQ_HIGH_READED=true;
    end
end
if DRAW_FREQ_LOW && DRAW_FABS
    fileFd = fopen(PATH+FABS_FREQ_LOW_FILE);
    if (-1 ~= fileFd)
        rawFabs200=fread(fileFd, 'double');
        fclose(fileFd);
        FABS_FREQ_LOW_READED=true;
    end
end
if DRAW_FREQ_HIGH && DRAW_FABS
    fileFd = fopen(PATH+FABS_FREQ_HIGH_FILE);
    if (-1 ~= fileFd)
        rawFabs400=fread(fileFd, 'double');
        fclose(fileFd);
        FABS_FREQ_HIGH_READED=true;
    end
end
if DRAW_FREQ_LOW && DRAW_ALIGN
    fileFd = fopen(PATH+ALIGN_FREQ_LOW_FILE);
    if (-1 ~= fileFd)
        rawFilterAlign200=fread(fileFd, 'double');
        fclose(fileFd);
        ALIGN_FREQ_LOW_READED=true;
    end
end
if DRAW_FREQ_HIGH && DRAW_ALIGN
    fileFd = fopen(PATH+ALIGN_FREQ_HIGH_FILE);
    if (-1 ~= fileFd)
        rawFilterAlign400=fread(fileFd, 'double');
        fclose(fileFd);
        ALIGN_FREQ_HIGH_READED=true;
    end
end
if DRAW_FREQ_LOW && DRAW_DETECTORS
    fileFd = fopen(PATH+DETECTOR_FREQ_LOW_FILE);
    if (-1 ~= fileFd)
        rawDataRecvFreq1=fread(fileFd, 'double');
        fclose(fileFd);
        DETECTOR_FREQ_LOW_READED=true;
    end
end
if DRAW_FREQ_HIGH && DRAW_DETECTORS
    fileFd = fopen(PATH+DETECTOR_FREQ_HIGH_FILE);
    if (-1 ~= fileFd)
        rawDataRecvFreq2=fread(fileFd, 'double');
        fclose(fileFd);
        DETECTOR_FREQ_HIGH_READED=true;
    end
end
if DRAW_FREQ_LOW && DRAW_BITS
    fileFd = fopen(PATH+BITS_FREQ_LOW_FILE);
    if (-1 ~= fileFd)
        bitsFreq1=fread(fileFd, 'double');
        fclose(fileFd);
        BITS_FREQ_LOW_READED=true;
    end
end
if DRAW_FREQ_HIGH && DRAW_BITS
    fileFd = fopen(PATH+BITS_FREQ_HIGH_FILE);
    if (-1 ~= fileFd)
        bitsFreq2=fread(fileFd, 'double');
        fclose(fileFd);
        BITS_FREQ_HIGH_READED=true;
    end
end
if DRAW_RESULT
    fileFd = fopen(PATH+BITS_RESULT_FILE);
    if (-1 ~= fileFd)
        bitsResult=fread(fileFd, 'double');
        fclose(fileFd);
        BITS_RESULT_READED=true;
    end
end
figure();

graphs = ORIG_READED + ...
         FILTER50_READED + ...
         FILTER_FREQ_LOW_READED + ...
         FILTER_FREQ_HIGH_READED + ...
         FABS_FREQ_LOW_READED + ...
         FABS_FREQ_HIGH_READED + ...
         ALIGN_FREQ_LOW_READED + ...
         ALIGN_FREQ_HIGH_READED + ...
         DETECTOR_FREQ_LOW_READED + ...
         DETECTOR_FREQ_HIGH_READED + ...
         BITS_FREQ_LOW_READED + ...
         BITS_FREQ_HIGH_READED;
num=1;

if DRAW_SOURCE && ORIG_READED
    subplot(graphs,1,num);
    rawOrig = rawOrig';
    plot(rawOrig);
    ylim([min(rawOrig) max(rawOrig)]);
    xlabel('time, ms');
    ylabel('original signal');
    num = num + 1;
end
if DRAW_FILTER50 && FILTER50_READED
    subplot(graphs,1,num);
    rawFilter50 = rawFilter50';
    plot(rawFilter50);
    ylim([min(rawFilter50) max(rawFilter50)]);
    xlabel('time, ms');
    ylabel('50 Hz filtered');
    num = num + 1;
end
if DRAW_FILTERED && DRAW_FREQ_LOW && FILTER_FREQ_LOW_READED
    subplot(graphs,1,num);
    rawFilter200 = rawFilter200';
    plot(rawFilter200);
    ylim([min(rawFilter200) max(rawFilter200)]);
    xlabel('time, ms');
    ylabel('freqLow signal');
    num = num + 1;
end
if DRAW_FABS && DRAW_FREQ_LOW && FABS_FREQ_LOW_READED
    subplot(graphs,1,num);
    rawFabs200 = rawFabs200';
    plot(rawFabs200);
    ylim([0 max(rawFabs200)]);
    xlabel('time, ms');
    ylabel('freqLow absed');
    num = num + 1;
end
if DRAW_ALIGN && DRAW_FREQ_LOW && ALIGN_FREQ_LOW_READED
    subplot(graphs,1,num);
    rawFilterAlign200 = rawFilterAlign200';
    plot(rawFilterAlign200);
    ylim([min(rawFilterAlign200) max(rawFilterAlign200)]);
    xlabel('time, ms');
    ylabel('freqLow aligned');
    num = num + 1;
end
if DRAW_DETECTORS && DRAW_FREQ_LOW && DETECTOR_FREQ_LOW_READED
    subplot(graphs,1,num);
    rawDataRecvFreq1 = rawDataRecvFreq1';
    plot(rawDataRecvFreq1);
    xlabel('time, ms');
    ylim([-0.5 1.5 ]);
    ylabel('detector data');
    num = num + 1;
end
if DRAW_FILTERED && DRAW_FREQ_HIGH && FILTER_FREQ_HIGH_READED
    subplot(graphs,1,num);
    rawFilter400 = rawFilter400';
    plot(rawFilter400);
    ylim([min(rawFilter400) max(rawFilter400)]);
    xlabel('time, ms');
    ylabel('freqHigh signal');
    num = num + 1;
end
if DRAW_FABS && DRAW_FREQ_HIGH && FABS_FREQ_HIGH_READED
    subplot(graphs,1,num);
    rawFabs400 = rawFabs400';
    plot(rawFabs400);
    ylim([0 max(rawFabs400)]);
    xlabel('time, ms');
    ylabel('freqHigh absed');
    num = num + 1;
end
if DRAW_ALIGN && DRAW_FREQ_HIGH && ALIGN_FREQ_HIGH_READED
    subplot(graphs,1,num);
    rawFilterAlign400 = rawFilterAlign400';
    plot(rawFilterAlign400);
    ylim([0 max(rawFilterAlign400)]);
    xlabel('time, ms');
    ylabel('freqHigh aligned');
    num = num + 1;
end
if DRAW_DETECTORS && DRAW_FREQ_HIGH && DETECTOR_FREQ_HIGH_READED
    subplot(graphs,1,num);
    rawDataRecvFreq2 = rawDataRecvFreq2';
    plot(rawDataRecvFreq2);
    xlabel('time, ms');
    ylim([-0.5 1.5 ]);
    ylabel('detector data');
    num = num + 1;
end
if DRAW_DETECTORS && DETECTOR_FREQ_LOW_READED && DETECTOR_FREQ_HIGH_READED
    figure();
    plot(t, rawDataRecvFreq1, t, -rawDataRecvFreq2+1);
    xlabel('time, ms');
    ylim([-0.5 1.5 ]);
    ylabel('detector data');
end
if DRAW_BITS && BITS_FREQ_LOW_READED && BITS_FREQ_HIGH_READED
    figure();
    subplot(2,1,1);
    bar(bitsFreq1);
    ylim([-0.5 1.5 ]);
    ylabel('detector freqLow bits');
    subplot(2,1,2);
    bar(bitsFreq2);
    ylim([-0.5 1.5 ]);
    ylabel('detector freqHigh bits');
end
if DRAW_RESULT && BITS_RESULT_READED
    figure();
    bar(bitsResult);
    ylim([-0.5 1.5 ]);
    ylabel('detector result bits');
end
if DRAW_SPEC
    hs=fft(rawFilter50);
    shs=fftshift(hs);
    ahs=abs(shs');
    figure();
    plot(f, ahs);
    xlim([10 3000]);
end
