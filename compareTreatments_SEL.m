clear all


if exist('rootdir.json','file')
    fid = fopen('rootdir.json','rt'); % Opening the file.
    raw = fread(fid,inf); % Reading the contents.
    fclose(fid); % Closing the file.
    str = char(raw'); % Transformation.
    par = jsondecode(str); % Using the jsondecode function to parse JSON from string.
  
    tempdir = par.tempdir;
else

    tempdir = '.';
end


fsize=31;
lineW=1;
lineW_curve=3;
MarkSz=20;
s = get(0, 'ScreenSize');

% Metadata for each hydrophone 
[~,~,Hmeta_raw] = xlsread('MarineVibratorHydrophoneMetaData.csv');
Hmeta=cell2struct(Hmeta_raw(2:end,:),Hmeta_raw(1,:),2);

% Metadata for each hydrophone deployment
[~,~,Dmeta_raw] = xlsread('MarineVibratorHydrophoneDeploymentMetaData.csv');
Dmeta=cell2struct(Dmeta_raw(2:end,:),Dmeta_raw(1,:),2);

% Get metadata for the treatments
[~,~,Tmeta_raw] = xlsread('treatments.csv');
Tmeta=cell2struct(Tmeta_raw(2:end,:),Tmeta_raw(1,:),2);


    % Relevant deplyments for this treatment
    k=1;
     for j=[1 3 4 5] ; %relevante deployments

        
   b=1;%blokk nr

     f= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
     for  i=1:3 % %treatment

  
     
 
    % tmpfil = fullfile(tempdir,['Block',num2str(b),'_Treat_',Tmeta(i).Treatment,'_Hydr',num2str(j),'_' , Dmeta(j).Location, '.mat']);
    figfil = fullfile(tempdir,['Block',num2str(b),'_Treat',num2str(Tmeta(i).TreatmentNo),'_',Tmeta(i).Treatment,...
        '_',Dmeta(j).DeplNumber,'_Location_',Dmeta(j).Location]);
resdir=fullfile(tempdir,'Results');
  if ~exist(resdir)
        mkdir(resdir)
    end

load([fullfile(figfil,'data.mat')])



 plot(Pulses.tidcum/60,Pulses.SELcum_dB,'.')
 hold on
if Tmeta(i).TreatmentNo==1
    tekst(i,:)='BASS';
elseif Tmeta(i).TreatmentNo==2
    tekst(i,:)='sil1';
elseif Tmeta(i).TreatmentNo==3
    tekst(i,:)='sil2';
end
     end
     title(['Block',num2str(b),', ' Dmeta(j).Location])
   legend(tekst(1,:), tekst(2,:), tekst(3,:))
        xlabel('Time relative to start treatment, min')
        ylabel('SEL (10 s), dB re 1 \muPa^2s')
            set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
        'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
            set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
        print(f,fullfile([resdir,'\CompareSEL10s_Block',num2str(b),'_' ,Dmeta(j).Location]),'-dpng')
        
        close(f)
     end