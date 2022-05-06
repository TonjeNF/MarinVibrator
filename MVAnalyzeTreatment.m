function Pulses = MVAnalyzeTreatment(Tmeta_i,tempdir,par)


fsize=31;
lineW=1;
lineW_curve=3;
MarkSz=20;
s = get(0, 'ScreenSize');

% Extract time-pressure data for all sensors from one treatment

% Loop over the different deplyments relevant for this treatment
for j=1:length(Tmeta_i.Hydrophone)
    % read TEMP files
 
     tmpfil = fullfile(tempdir,['Block',num2str(Tmeta_i.BlockNo),'_Treat_',Tmeta_i.Treatment,'_Hydr',num2str(j),'_' , Tmeta_i.Hydrophone(j).Location, '.mat']);
    

%      Ser på SEL for 1 time for alle eksponeringar.
% Ser og på RMS
% Ser på Max(over 10 sekund)
% For det max, ta SEL for 10 sekund.
% Sjå på frekvensspekter spektrogram for 1 time
% og for 23 sekund ved ulike tider.
% samanlikn med luftkanon 



    % Generate descriptive figure file names
    figfil = fullfile(tempdir,['Block',num2str(Tmeta_i.BlockNo),'_Treat',num2str(Tmeta_i.TreatmentNo),'_',Tmeta_i.Treatment,...
        '_',Tmeta_i.Hydrophone(j).DeplNumber,'_Location_',Tmeta_i.Hydrophone(j).Location]);

%     % Temporary pulse file to avoid detecting the pulses at each run
%     pulsefil = [figfil,'_pulses.mat'];
    
    % Generate a separate folder for the pulses
    if ~exist(figfil)
        mkdir(figfil)
    end
    
    if exist(tmpfil)
        load(tmpfil,'Dat'); % Loads DAT
        
        % Filter pressure data
        [C,A] = butter(3,[5 10000]/(par.Fs/2),'bandpass');
        p = filtfilt(C,A,Dat.Pressure);% ca 30 sec run time
        t = Dat.Time;
        
        %Plukker ut ein time og legg til data for å kompensere for gap
        %mellom filer.
                secHour=3600+3600/24 + (3600/24/24); % kompenserer for at vi har eit sekund gap og 23 sekund data. 1/24 del manglar. Legg til dette. (den delen vi legg til har og 1/24 del som manglar, dette må og leggjast til)
        indHour = t > 3600 & (t <secHour+3600 );


        % Estimate SEL average
        D.Ex_all=(1/par.Fs)*sum(p.^2);
        D.SEL_all_dB=10*log10(D.Ex_all/1e-12);
        D.Ex_1h=(1/par.Fs)*sum(p(indHour).^2); 
        D.SEL_1h_dB=10*log10(D.Ex_1h/1e-12);
        D.rms=20*log10(rms(p)./1e-6);

%% Plot figure with filtered data and text with
        %1 hour SEL:
        %3 hour SEL:
        %RMS for all period in plot and in txt.
       
       

    f= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
 plot(t/60,p)
hold on
plot(t(indHour)/60,p(indHour))
 
        title([Tmeta_i.Treatment ', ' Tmeta_i.Hydrophone(j).Location ' RMS: ' num2str(round(D.rms,1)) ' dB re 1 \muPa'])
        legend(['SEL all: ' num2str(round(D.SEL_all_dB,1)) ' dB re 1 \muPa^2 s'] ,[' 1 hour SEL: ' num2str(round(D.SEL_1h_dB,1)) ' dB re 1 \muPa^2 s'])
        xlabel('Time relative to start treatment (min)')
        ylabel('Pressure (Pa)')
            set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
        'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
        print(f,fullfile(figfil,'3h_raw'),'-dpng')
       
        close(f)



 %% Plot SEL and peak pressure for 10 seconds at a time
  %Plukkar ut SEL og abs(peak) kvar 10 sek med 9 sek overlapp.
                        m1=1;
                        
                        for r=1:floor((length(t)-15*par.Fs)/par.Fs)
                            m2=m1-1+(par.Fs*10);
                            Pulses.SELcum_dB(r)=10*log10((1/par.Fs)*sum(p(m1:m2).^2)./1e-12);
                            Pulses.peakcum_dB(r)=20*log10(max(abs(p(m1:m2)))./1e-6);
                            Pulses.tidcum(r)=t(round(m1+(m2-m1)/2));
                            m1=m1+par.Fs;
                            
                        end

               

    f= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
 plot(Pulses.tidcum/60,Pulses.SELcum_dB,'k.')

 
        title([Tmeta_i.Treatment ', ' Tmeta_i.Hydrophone(j).Location ' RMS: ' num2str(round(D.rms,1)) ' dB re 1 \muPa'])
   legend(['max SEL(10 s): ' num2str(round(max(Pulses.SELcum_dB),1)) 'dB re 1 \muPa^2 s'])
        xlabel('Time relative to start treatment, min')
        ylabel('SEL (10 s), dB re 1 \muPa^2 s')
            set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
        'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
            set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
            print(f,fullfile(figfil,'SEL10s'),'-dpng')
        
        close(f)


    f= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
 plot(Pulses.tidcum/60,Pulses.peakcum_dB,'k.')

 
        title([Tmeta_i.Treatment ', ' Tmeta_i.Hydrophone(j).Location ' RMS: ' num2str(round(D.rms,1)) ' dB re 1 \muPa'])
   legend(['max peak pr 10 s: ' num2str(round(max(Pulses.peakcum_dB),1)) ' dB re 1 \muPa'])
        xlabel('Time relative to start treatment, min')
        ylabel('Peak presure, dB re 1 \muPa')
            set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
        'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
            set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
        print(f,fullfile(figfil,'peak10s'),'-dpng')
        
        close(f)

%  %% sjå på frekvensinnhald. Spektrogram får eg ikkje til å gje noko fornuftig.
% 
% 
% %finn ein måte for å sjå på frekvens
% %plukk ut 10 sekund på lavaste, middels og max nivå for skot. Plott FFT for
% %kvart av desse sekunda, 1 s om gongen, i 3 subplot for kvar eksponering.
% 
% %Tider: minimum: 3975 middels: 3025 maks: 2256
% ti(1)=2260; %max
% ti(2)=3025; %med
% ti(3)=3975;%min
% 
% %lag figur som plotter ein snutt rundt desse områda.
% 
% 
% 
%  for q=1:length(ti)
%     tt=ti(q)-5;
%   indf=(t>ti(q)-5) & (t < ti(q)+5);
%   figure(100)
%    subplot(3,1,q)
%    plot(t(indf),p(indf))
% for o=1:10
%     inds=(t>tt) & (t < tt+1);
%     tt=tt+1;
%     S1=p(inds);
%    tuk=tukeywin(length(S1),0.05)'; %Tapering: lagar vindu som gir ein glatt overgang ved å setje start og sluttverdi på tidsvindu til 0
% S=tuk.*S1;
% Y=fft(S); %1 sekund signal-sekvens
%         L=length(S);
%         P2=abs(Y/L);
%         P1=P2(1:L/2+1); %tek halve spekteret
%         P1(2:end-1)=2*P1(2:end-1); %gongar mesteparten av spekteret med 2
%         frekv=par.Fs*(0:(L/2))/L;
%         ESD=((abs(P1)).^2)*(L/(2*par.Fs));
%         
%             pulse(q).frek=frekv;
%             pulse(q).P1(o,:)=P1;
%             pulse(q).ESD(o,:)=ESD;
%  
%           
% 
% end
% end
% 
%     
%  f= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
%      subplot(3,1,1)
%    plot(pulse(1).frek,pulse(1).P1)
%        ylabel('Pa')
%             set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
%         'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
%             set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
%             xlim([0 500])
% 
%    subplot(3,1,2)
%    plot(pulse(1).frek,pulse(2).P1)
%        ylabel('Pa')
%             set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
%         'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
%             set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
%             xlim([0 500])
%    subplot(3,1,3)
% plot(pulse(1).frek,pulse(3).P1)
%     ylabel('Pa')
%             set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
%         'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
%             set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
% 
% xlim([0 500])
% 
% 
%     ylabel('Pa')
%             set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
%         'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
%             set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
% 
% 
%        
%         xlabel('frequency, Hz')
%         
%         print(f,fullfile(figfil,'freqs'),'-dpng')
% 
%   close(f)
% 
% 



    end

%writetable(struct2table(Pulses), [figfil\figfil '_10sSelAndPeak.csv'])

save([fullfile(figfil,'data.mat')], 'Pulses')
    clear Pulses D Dat
end
end


     