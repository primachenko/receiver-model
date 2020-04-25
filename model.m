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
