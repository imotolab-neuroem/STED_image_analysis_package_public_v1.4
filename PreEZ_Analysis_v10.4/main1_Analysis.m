%% Analysis for synapses in 2ch 2D STED images, Ye MA 2020 Nov, Imoto et al 2022 (PMID: 35809574)

clear
clc
close all
addpath ./functions
set(0,'DefaultFigureWindowStyle','docked')
selpath = uigetdir('', 'Please select the folder containing the ROI images');
imglist=dir(fullfile(selpath,sprintf('*.tif')));

% For dynamin channel
PeakThresholdFactor=0.7;
V=0.3:0.1:0.9;
PixelSize=20;
windowSize=2;
preview_flag=0;

distance_accumulated=[];
NumActiveZone=0;
NumDynCluster=0;
PunctaStatsResults=[];
DistanceResults=[];
ContourResults={};

%% Selection
for imgind=1:length(imglist)
    Tmp = loadtiff([imglist(imgind).folder,'/',imglist(imgind).name]);
    Ch0_dyn=Tmp(:,:,1);
    Ch1_bas=Tmp(:,:,2);
    
    % Add a while loop here to allow user to repeat the selection process
    user_confirmed = false; % Initialization
    while ~user_confirmed
        %% Preview
        [PeakY,PeakX,PeakVal]=localMaximum(double(Ch0_dyn),3,1,PeakThresholdFactor.*max(Ch0_dyn(:)));
        figure(1);
        annotation('textbox', [0.35, 0.98, 0, 0], 'string', imglist(imgind).name, 'Interpreter', 'none');
        subplot(341);hold on;imagesc(Ch0_dyn);scatter(PeakX,PeakY,'c*');axis equal;axis off;hold off;title('Ch 1');set(gca,'XDir','normal');set(gca,'YDir','reverse');
  
    C=contourc(double(Ch1_bas),V.*double(max(Ch1_bas(:))));
    subplot(342);imagesc(Ch1_bas);axis equal;axis off;hold on;title('Ch 2');set(gca,'XDir','normal');set(gca,'YDir','reverse');
    S=contourdata(C);
    for k=1:length(S)
        plot(S(k).xdata,S(k).ydata,'LineWidth',2)
    end
    hold off
    colormap(hot)
    subplot(343);imshowpair(Ch0_dyn,Ch1_bas);title('Composite preview');set(gca,'XDir','normal');set(gca,'YDir','reverse');
    %% Select dynamin cluster
    subplot(345);hold on;imagesc(Ch0_dyn);scatter(PeakX,PeakY,'c*');axis equal;axis off;title('Select ch1 cluster, end with ENTER');set(gca,'XDir','normal');set(gca,'YDir','reverse');
    [xi,yi]=getpts();
    if isempty(xi)
        close figure 1
        continue
    end
    NumDynCluster=NumDynCluster+length(xi);
    xlist=[];
    ylist=[];
    PeakList=PeakX+1j*PeakY;
    for i=1:length(xi)
        temp=abs(PeakList-xi(i)-1j.*yi(i));
        [~,ind]=min(temp);
        xlist(i)=PeakX(ind);
        ylist(i)=PeakY(ind);
    end
    xlist=xlist';
    ylist=ylist';
    scatter(xlist,ylist,'ko')
    hold off;
    %% Select active zone contour
    subplot(346);imagesc(Ch1_bas);axis equal;axis off;hold on;title('Select ch2 cluster boundary, end with ENTER');set(gca,'XDir','normal');set(gca,'YDir','reverse');
    S=contourdata(C);
    for k=1:length(S)
        plot(S(k).xdata,S(k).ydata,'LineWidth',2)
    end
    colormap(hot)
    [x_SelectedContour,y_SelectedContour]=getpts();
    if isempty(x_SelectedContour)
        close figure 1
        continue
    end
    NumActiveZone=NumActiveZone+length(x_SelectedContour);
    distance_current_set=[];xy_set=[];ind_selectedContour_set=[];
    for jjj = 1:length(x_SelectedContour)
        d=100.*ones(length(S),1);
        for k=1:length(S)
            [~,distance_tmp,~] = distance2curve([S(k).xdata,S(k).ydata],[x_SelectedContour(jjj),y_SelectedContour(jjj)],'linear');
            d(k)=distance_tmp;
        end
        [~,ind_selectedContour]=min(d);
        ind_selectedContour_set(jjj)=ind_selectedContour;
        %%  Calculate distance
        [xy,distance_current_tmp,t_a] = distance2curve([S(ind_selectedContour).xdata,S(ind_selectedContour).ydata],[xlist,ylist],'spline');
        distance_current_set(:,jjj)=distance_current_tmp;
        xy_set(:,:,jjj)=xy;
    end
    [distance_current,indmin]=min(distance_current_set,[],2);
    xy_current=[];
    for kkkk=1:length(indmin)
        xy_current(kkkk,:)=xy_set(kkkk,:,indmin(kkkk));
    end
    subplot(347);imshowpair(Ch0_dyn,Ch1_bas);axis equal;axis off;hold on;set(gca,'XDir','normal');set(gca,'YDir','reverse');
    for kkk=1:length(ind_selectedContour_set)
        plot(S(ind_selectedContour_set(kkk)).xdata,S(ind_selectedContour_set(kkk)).ydata,'c-','LineWidth',2)
    end
    scatter(xlist,ylist,'c*')
    scatter(xy_current(:,1),xy_current(:,2),'r*')
    line([xlist,xy_current(:,1)]',[ylist,xy_current(:,2)]','color',[0 0 1])
    title('Distance calculated')
    hold off
    ActiveZoneContour={};

% Add confirmation from the user to proceed or redo the selections
        disp('Press Enter if satisfied with your selections, or "n" to redo.');
k = waitforbuttonpress;
current_char = get(gcf, 'CurrentCharacter');

if current_char == char(13)  % 13 is the Enter key's ASCII
    user_confirmed = true;
else
    clf(figure(1));
end

    end

    %%  Display the distance result
    for iii=1:length(distance_current)
        if inpolygon(xlist(iii),ylist(iii),S(ind_selectedContour_set(indmin(iii))).xdata,S(ind_selectedContour_set(indmin(iii))).ydata)
           distance_current(iii)=-distance_current(iii);
        end
        ActiveZoneContour{iii}=S(ind_selectedContour_set(indmin(iii)));
    end
    distance_current=distance_current.*PixelSize;
    subplot(348);stem(distance_current);title('Distance distribution');xlabel('ch1 cluster #');ylabel('Distance from ch2 cluster boundary')
    distance_accumulated=[distance_accumulated',distance_current']';
    subplot(344);histogram(distance_accumulated,10,'Normalization','probability');title('Accumulated distance distribution');xlabel('Distance from ch2 cluster boundary');ylabel('Fraction of ch1 cluster')
    str1={'# of ch2 cluster = ',num2str(NumActiveZone)};
    str2={'# of ch1 cluster = ',num2str(NumDynCluster)};
    annotation('textbox', [0.91, 0.91, 0.8, 0], 'string', str1);
    annotation('textbox', [0.91, 0.85, 0.8, 0], 'string', str2);
    text(2,7,str1)
    text(2,10,str2)
    %% Gaussian fitting for dynamin size
    points = [xlist,ylist];
  % Results = [Amp,xPos,yPos,sigmaX,sigmaY,angle,background=0,X0,Y0,sum(ccd_image(:))]
    Results_temp = LS_fittingVer2_GivenPeak(Ch0_dyn,points,PeakThresholdFactor,windowSize,preview_flag);   
    paras=[Results_temp(:,1:7)];
    [npts,~]=size(paras);
    [sizey,sizex]=size(Ch0_dyn);
    [X,Y]= meshgrid(1:sizex,1:sizey);    % combine X and Y into a single matrix, and split them in Gauss2d
    grid = [X Y];
    image_gaussian_overlap=zeros(size(Ch0_dyn));
    for i1=1:npts
        y=Gauss2d(paras(i1,:),grid);
        image_gaussian_overlap=image_gaussian_overlap+y;
    end
    subplot(349);imagesc(image_gaussian_overlap);axis equal;axis off;colormap(hot)
    for i2=1:npts
        text(Results_temp(i2,8),Results_temp(i2,9),num2str(i2),'Color','cyan','FontSize',14)
        text(Results_temp(i2,8),Results_temp(i2,9)+1,num2str(Results_temp(i2,4).*PixelSize.*2.3548),'Color','cyan','FontSize',14)
        text(Results_temp(i2,8),Results_temp(i2,9)+2,num2str(Results_temp(i2,5).*PixelSize.*2.3548),'Color','cyan','FontSize',14)
    end
    
    Results_temp(:,11)=imgind;
    distance_current(:,2)=imgind;
    PunctaStatsResults=[PunctaStatsResults',Results_temp']';
    DistanceResults=[DistanceResults',distance_current']';
    ContourResults=[ContourResults,ActiveZoneContour];

% Create new folders inside the selected folder
output_folder = fullfile(selpath, 'output');
screenshot_folder = fullfile(selpath, 'screenshot');
mkdir(output_folder);
mkdir(screenshot_folder);

    %%
    subplot(3,4,10);histogram(PunctaStatsResults(:,4).*PixelSize.*2.3548,10);title('Histogram of FHWM along major axis');xlabel('FHWM along major axis (nm)');ylabel('Count');
    subplot(3,4,11);histogram(PunctaStatsResults(:,5).*PixelSize.*2.3548,10);title('Histogram of FHWM along minor axis');xlabel('FHWM along minor axis (nm)');ylabel('Count');
    subplot(3,4,12);histogram(PunctaStatsResults(:,10)./65535,10);title('Histogram of total intensity');xlabel('Total Intensity (A.U.)');ylabel('Count');
    pause()
    %%  Save
    %screenshot
    print('-dtiff','-r100', fullfile(screenshot_folder, [imglist(imgind).name,'_screenshot.tiff']));
    %save
    save(fullfile(output_folder, [imglist(imgind).name,'_result.mat']), 'Results_temp', 'distance_current', 'ActiveZoneContour');
    %%  Close figure
    close figure 1
end
% Save 'FinalResults.mat' in the selected folder
save(fullfile(selpath, 'FinalResults.mat'), 'PunctaStatsResults', 'DistanceResults', 'ContourResults', 'PixelSize');

