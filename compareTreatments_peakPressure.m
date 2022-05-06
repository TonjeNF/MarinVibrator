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
for b=1:10;%blokk nr
    for j=[1 3 4 5] ; %relevante deployments




        
        teljar=0;
        f= figure('Position', [0 0 s(3) s(4)], 'visible', 'off');
        for  i=1:3 % %treatment




            % tmpfil = fullfile(tempdir,['Block',num2str(b),'_Treat_',Tmeta(i).Treatment,'_Hydr',num2str(j),'_' , Dmeta(j).Location, '.mat']);
            figfil = fullfile(tempdir,['Block',num2str(b),'_Treat',num2str(Tmeta(i).TreatmentNo),'_',Tmeta(i).Treatment,...
                '_',Dmeta(j).DeplNumber,'_Location_',Dmeta(j).Location]);
            resdir=fullfile(tempdir,'Results');
            if ~exist(resdir)
                mkdir(resdir)
            end

            test=1;

            try
                load([fullfile(figfil,'data.mat')])

            catch;
                test=0;

            end


          

            if test>0

                teljar=teljar+1
                if Tmeta(teljar).TreatmentNo==1
                    tekst(teljar,:)='BASS';
                    col=[0 0.4470 0.7410];
                elseif Tmeta(teljar).TreatmentNo==2
                    tekst(teljar,:)='sil1';
                      col=[0.8500 0.3250 0.0980];
                elseif Tmeta(teljar).TreatmentNo==3
                    tekst(teljar,:)='sil2';
                      col=[0.9290 0.6940 0.1250];
                end

              plot(Pulses.tidcum/60,Pulses.peakcum_dB,'.', 'MarkerFaceColor',col)
            hold on
            end
            title(['Block',num2str(b),', ' Dmeta(j).Location])
            if teljar==3
                legend(tekst(1,:), tekst(2,:), tekst(3,:))
            elseif teljar==2
                legend(tekst(1,:), tekst(2,:))
            elseif teljar ==1
                legend(tekst(1,:))
            end
            end
        xlabel('Time relative to start treatment, min')
        ylabel('peak pressure ( every 10 s), dB re 1 \muPa')
        set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',fsize, ...
            'FontWeight','Normal', 'LineWidth', lineW,'layer','top');
        set(findobj(gcf, 'Type', 'Line'),'LineWidth',lineW,'MarkerSize',MarkSz);
        ylim([115 155])
        print(f,fullfile([resdir,'\ComparePeak10s_Block',num2str(b),'_' ,Dmeta(j).Location]),'-dpng')
       
       
  
    end 
    close(f)
end

