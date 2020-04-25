ORIG_READED           = false;
FILTER50_READED       = false;
FILTER_FREQ1_READED   = false;
FILTER_FREQ2_READED   = false;
FABS_FREQ1_READED     = false;
FABS_FREQ2_READED     = false;
ALIGN_FREQ1_READED    = false;
ALIGN_FREQ2_READED    = false;
DETECTOR_FREQ1_READED = false;
DETECTOR_FREQ2_READED = false;
BITS_FREQ1_READED     = false;
BITS_FREQ2_READED     = false;
BITS_RESULT_READED    = false;

PATH = "Z:\projects\receiver\";

ORIG_FILE           = "original";
FILTER50_FILE       = "filter-50";
FILTER_FREQ1_FILE   = "filter-200";
FILTER_FREQ2_FILE   = "filter-400";
FABS_FREQ1_FILE     = "fabs-200";
FABS_FREQ2_FILE     = "fabs-400";
ALIGN_FREQ1_FILE    = "align-200";
ALIGN_FREQ2_FILE    = "align-400";
DETECTOR_FREQ1_FILE = "detector-200";
DETECTOR_FREQ2_FILE = "detector-400";
BITS_FREQ1_FILE     = "bits-200";
BITS_FREQ2_FILE     = "bits-400";
BITS_RESULT_FILE    = "result";

DRAW_SPEC      = false;
DRAW_FILTER    = false;
DRAW_FILTERED  = true;
DRAW_FABS      = false;
DRAW_ALIGN     = true;
DRAW_DETECTORS = false;
DRAW_BITS      = true;
DRAW_RESULT    = false;

DRAW_SOURCE    = true;
DRAW_FILTER50  = true;
DRAW_FREQ1     = true;
DRAW_FREQ2     = true;

% if DRAW_SOURCE
    fileFd = fopen(PATH+ORIG_FILE);
    if (-1 ~= fileFd)
        rawOrig=fread(fileFd, 'double');
        fclose(fileFd);
        ORIG_READED=true;
    end
% end

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
if DRAW_FREQ1 && DRAW_FILTERED
    fileFd = fopen(PATH+FILTER_FREQ1_FILE);
    if (-1 ~= fileFd)
        rawFilter200=fread(fileFd, 'double');
        fclose(fileFd);
        FILTER_FREQ1_READED=true;
    end
end
if DRAW_FREQ2 && DRAW_FILTERED
    fileFd = fopen(PATH+FILTER_FREQ2_FILE);
    if (-1 ~= fileFd)
        rawFilter400=fread(fileFd, 'double');
        fclose(fileFd);
        FILTER_FREQ2_READED=true;
    end
end
if DRAW_FREQ1 && DRAW_FABS
    fileFd = fopen(PATH+FABS_FREQ1_FILE);
    if (-1 ~= fileFd)
        rawFabs200=fread(fileFd, 'double');
        fclose(fileFd);
        FABS_FREQ1_READED=true;
    end
end
if DRAW_FREQ2 && DRAW_FABS
    fileFd = fopen(PATH+FABS_FREQ2_FILE);
    if (-1 ~= fileFd)
        rawFabs400=fread(fileFd, 'double');
        fclose(fileFd);
        FABS_FREQ2_READED=true;
    end
end
if DRAW_FREQ1 && DRAW_ALIGN
    fileFd = fopen(PATH+ALIGN_FREQ1_FILE);
    if (-1 ~= fileFd)
        rawFilterAlign200=fread(fileFd, 'double');
        fclose(fileFd);
        ALIGN_FREQ1_READED=true;
    end
end
if DRAW_FREQ2 && DRAW_ALIGN
    fileFd = fopen(PATH+ALIGN_FREQ2_FILE);
    if (-1 ~= fileFd)
        rawFilterAlign400=fread(fileFd, 'double');
        fclose(fileFd);
        ALIGN_FREQ2_READED=true;
    end
end
if DRAW_FREQ1 && DRAW_DETECTORS
    fileFd = fopen(PATH+DETECTOR_FREQ1_FILE);
    if (-1 ~= fileFd)
        rawDataRecvFreq1=fread(fileFd, 'double');
        fclose(fileFd);
        DETECTOR_FREQ1_READED=true;
    end
end
if DRAW_FREQ2 && DRAW_DETECTORS
    fileFd = fopen(PATH+DETECTOR_FREQ2_FILE);
    if (-1 ~= fileFd)
        rawDataRecvFreq2=fread(fileFd, 'double');
        fclose(fileFd);
        DETECTOR_FREQ2_READED=true;
    end
end
if DRAW_FREQ1 && DRAW_BITS
    fileFd = fopen(PATH+BITS_FREQ1_FILE);
    if (-1 ~= fileFd)
        bitsFreq1=fread(fileFd, 'double');
        fclose(fileFd);
        BITS_FREQ1_READED=true;
    end
end
if DRAW_FREQ2 && DRAW_BITS
    fileFd = fopen(PATH+BITS_FREQ2_FILE);
    if (-1 ~= fileFd)
        bitsFreq2=fread(fileFd, 'double');
        fclose(fileFd);
        BITS_FREQ2_READED=true;
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
         FILTER_FREQ1_READED + ...
         FILTER_FREQ2_READED + ...
         FABS_FREQ1_READED + ...
         FABS_FREQ2_READED + ...
         ALIGN_FREQ1_READED + ...
         ALIGN_FREQ2_READED + ...
         DETECTOR_FREQ1_READED + ...
         DETECTOR_FREQ2_READED + ...
         BITS_FREQ1_READED + ...
         BITS_FREQ2_READED;
num=1;

if DRAW_SOURCE && ORIG_READED
    subplot(graphs,1,num);
    rawOrig = rawOrig';
    plot(rawOrig);
    xlabel('time, ms');
    ylabel('original signal');
    num = num + 1;
end
if DRAW_FILTER50 && FILTER50_READED
    subplot(graphs,1,num);
    rawFilter50 = rawFilter50';
    plot(rawFilter50);
    xlabel('time, ms');
    ylabel('50 Hz filtered');
    num = num + 1;
end
if DRAW_FILTERED && DRAW_FREQ1 && FILTER_FREQ1_READED
    subplot(graphs,1,num);
    rawFilter200 = rawFilter200';
    plot(rawFilter200);
    xlabel('time, ms');
    ylabel('freq1 signal');
    num = num + 1;
end
if DRAW_FABS && DRAW_FREQ1 && FABS_FREQ1_READED
    subplot(graphs,1,num);
    rawFabs200 = rawFabs200';
    plot(rawFabs200);
    xlabel('time, ms');
    ylabel('freq1 absed');
    num = num + 1;
end
if DRAW_ALIGN && DRAW_FREQ1 && ALIGN_FREQ1_READED
    subplot(graphs,1,num);
    rawFilterAlign200 = rawFilterAlign200';
    plot(rawFilterAlign200);
    ylim([0 max(rawFilterAlign200)]);
    xlabel('time, ms');
    ylabel('freq1 aligned');
    num = num + 1;
end
if DRAW_DETECTORS && DRAW_FREQ1 && DETECTOR_FREQ1_READED
    subplot(graphs,1,num);
    rawDataRecvFreq1 = rawDataRecvFreq1';
    plot(rawDataRecvFreq1);
    xlabel('time, ms');
    ylim([-0.5 1.5 ]);
    ylabel('detector data');
    num = num + 1;
end
if DRAW_FILTERED && DRAW_FREQ2 && FILTER_FREQ2_READED
    subplot(graphs,1,num);
    rawFilter400 = rawFilter400';
    plot(rawFilter400);
    ylim([-1.5 1.5 ]);
    xlabel('time, ms');
    ylabel('freq2 signal');
    num = num + 1;
end
if DRAW_FABS && DRAW_FREQ2 && FABS_FREQ2_READED
    subplot(graphs,1,num);
    rawFabs400 = rawFabs400';
    plot(rawFabs400);
    xlabel('time, ms');
    ylabel('freq2 absed');
    num = num + 1;
end
if DRAW_ALIGN && DRAW_FREQ2 && ALIGN_FREQ2_READED
    subplot(graphs,1,num);
    rawFilterAlign400 = rawFilterAlign400';
    plot(rawFilterAlign400);
    ylim([0 max(rawFilterAlign400)]);
    xlabel('time, ms');
    ylabel('freq2 aligned');
    num = num + 1;
end
if DRAW_DETECTORS && DRAW_FREQ2 && DETECTOR_FREQ2_READED
    subplot(graphs,1,num);
    rawDataRecvFreq2 = rawDataRecvFreq2';
    plot(rawDataRecvFreq2);
    xlabel('time, ms');
    ylim([-0.5 1.5 ]);
    ylabel('detector data');
    num = num + 1;
end
if DRAW_DETECTORS && DETECTOR_FREQ1_READED && DETECTOR_FREQ2_READED
    figure();
    plot(t, rawDataRecvFreq1, t, -rawDataRecvFreq2+1);
    xlabel('time, ms');
    ylim([-0.5 1.5 ]);
    ylabel('detector data');
end
if DRAW_BITS && BITS_FREQ1_READED && BITS_FREQ2_READED
    figure();
    subplot(2,1,1);
    bar(bitsFreq1);
    ylim([-0.5 1.5 ]);
    ylabel('detector freq1 bits');
    subplot(2,1,2);
    bar(bitsFreq2);
    ylim([-0.5 1.5 ]);
    ylabel('detector freq2 bits');
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
