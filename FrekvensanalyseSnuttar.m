clear all;close all

fsize=31;
lineW=1;
lineW_curve=3;
MarkSz=20;
s = get(0, 'ScreenSize');
if exist('rootdir.json','file')
    fid = fopen('rootdir.json','rt'); % Opening the file.
    raw = fread(fid,inf); % Reading the contents.
    fclose(fid); % Closing the file.
    str = char(raw'); % Transformation.
    par = jsondecode(str); % Using the jsondecode function to parse JSON from string.
    rootdir = par.rootdir;
    tempdir = par.tempdir;
else
    rootdir = '\\ces.hi.no\nmdstorage\SCRATCH\S2022812_H.U.SverdrupII[1007]\EXPERIMENTS\HYDROPHONES';
    tempdir = '.';
end
resdir=fullfile(tempdir,'Results');

%
% load(fullfile([tempdir, 'Block1_Treat_BASS_Hydr4_OuterBay.mat']))
%
% ind(1)=find(Dat.Time>2225,1); %max nivå
% ind(2)=find(Dat.Time>2916,1);
% ind(3)=find(Dat.Time>3742,1);
%
% %plukk ut 30 sekund rundt desse nivåa:
% Fs=48000;
% for i=1: length(ind)
%
%     ind30=ind(i)-30*Fs:ind(i)+30*Fs;
%
%     Psnutt(i,:)=detrend(Dat.Pressure(ind30));
%     Tsnutt(i,:)=Dat.Time(ind30);
% end
%
% figure
% plot(Dat.Time,detrend(Dat.Pressure))
% hold on
% plot(Tsnutt(1,:),Psnutt(1,:))
% plot(Tsnutt(2,:),Psnutt(2,:))
%
% plot(Tsnutt(3,:),Psnutt(3,:))
% xlim([2000 4000])
% xlabel('seconds')
% ylabel('Pa')
%
%
% figure
% plot(Tsnutt(1,:),Psnutt(1,:))
% figure
% plot(Tsnutt(2,:),Psnutt(2,:))
% figure
% plot(Tsnutt(3,:),Psnutt(3,:))
%
% save(fullfile([tempdir,'\snuttarBlokk1Bass.mat']), 'Tsnutt', 'Psnutt', 'Fs')


load(fullfile([tempdir '\snuttarBlokk1Bass.mat']))


%plukkar ut 10 sekund for analyse:

%snutt 1: ser manuelt 2218:2228

ind2(1)=find(Tsnutt(1,:)>2218,1);
ind2(2)=find(Tsnutt(2,:)>2908,1);
ind2(3)=find(Tsnutt(3,:)>3715,1);


for i=1:length(ind2)

    %     ind30=ind(i)-15*Fs:ind(i)+15*Fs;
    %
    %     Psnutt(i,:)=Dat.Pressure(ind30);
    inds=ind2(i):ind2(i)+10*Fs-1;

    S1=Psnutt(i,inds);

    tuk=tukeywin(length(S1),0.3)'; %Tapering: lagar vindu som gir ein glatt overgang ved å setje start og sluttverdi på tidsvindu til 0
    S=tuk.*S1;%
    t=Tsnutt(i,inds);
    L=length(S);

    f1= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
    subplot(2,1,1)
    plot(Tsnutt(i,:),Psnutt(i,:))
    hold on
    plot(t,S1)
    plot(t,S)
    ylabel(['Pa'])
    xlabel('seconds')

    %fft-analyse
    Y=fft(S);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;

    subplot(2,1,2)
    plot(f,P1)
    xlim([0 300])
    xlabel('frekvens, Hz')
    ylabel(['Pa'])
    set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
        'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
    set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);

    print(f1,fullfile([resdir,'\frekvens_' num2str(i)]),'-dpng')
    close(f1)

end


