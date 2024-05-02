%% Read final result file from main 1 and plot histograms, Ye Ma 2020 Nov. Imoto et al 2022 (PMID: 35809574)

clear
clc
close all
addpath ./functions
set(0,'DefaultFigureWindowStyle','docked')
selpath =  uigetdir('', 'Please select the folder containing the results');
imglist=dir(fullfile(selpath,sprintf('*.tif')));
mkdir screenshot
mkdir output
load([selpath,'/','FinalResults.mat'], 'PunctaStatsResults', 'DistanceResults', 'ContourResults', 'PixelSize');

NumBin=7;
%%
FWHMMajor_Nonfiltered=PunctaStatsResults(:,4).*PixelSize.*2.3548;
indx_filtered=find(FWHMMajor_Nonfiltered<=280);

DistanceToActiveZone=DistanceResults(indx_filtered,1);
FWHMMajorAxis=PunctaStatsResults(indx_filtered,4).*PixelSize.*2.3548;
FWHMMinorAxis=PunctaStatsResults(indx_filtered,5).*PixelSize.*2.3548;
Area=2.*pi.*FWHMMajorAxis.*FWHMMinorAxis;
TotalIntensity=PunctaStatsResults(indx_filtered,10)./65535;

PunctaParasList=table(indx_filtered,DistanceToActiveZone,FWHMMajorAxis,FWHMMinorAxis,Area,TotalIntensity);
%%  Display the results ---- histogram
close all
figure;
histogram(DistanceToActiveZone,NumBin,'Normalization','probability');
xlabel('Distance from active zone boundary');
ylabel('Fraction of dynamin cluster')
set(gca,'FontSize',38);

figure;
histogram(FWHMMajorAxis,NumBin);
xlabel('FWHM along major axis (nm)');
ylabel('Number of dynamin puncta')
set(gca,'FontSize',38);

figure;
histogram(FWHMMinorAxis,NumBin);
xlabel('FWHM along minor axis (nm)');
ylabel('Number of dynamin puncta')
set(gca,'FontSize',38);

figure;
histogram(Area,NumBin);
xlabel('Area of the puncta (nm^2)');
ylabel('Number of dynamin puncta')
set(gca,'FontSize',38);

figure;
histogram(TotalIntensity,NumBin);
xlabel('Total Intensity (A.U.)');
ylabel('Number of dynamin puncta')
set(gca,'FontSize',38);

%% Display the results ---- scatter plot
figure;
scatter(DistanceToActiveZone,FWHMMajorAxis,100,'k','filled');
xlabel('Distance from the active zone (nm)');
ylabel('FWHM along major axis (nm)')
set(gca,'FontSize',38);

figure;
scatter(DistanceToActiveZone,FWHMMinorAxis,100,'k','filled');
xlabel('Distance from the active zone (nm)');
ylabel('FWHM along minor axis (nm)')
set(gca,'FontSize',38);

figure;
scatter(DistanceToActiveZone,Area,100,'k','filled');
xlabel('Distance from the active zone (nm)');
ylabel('Area of the puncta (nm^2)')
set(gca,'FontSize',38);

figure;
scatter(DistanceToActiveZone,TotalIntensity,100,'k','filled');
xlabel('Distance from the active zone (nm)');
ylabel('Total Intensity (A.U.)')
set(gca,'FontSize',38);

%%
figure;
H=histogram(DistanceToActiveZone,NumBin,'Normalization','probability');
BinEdges=H.BinEdges';
BinEdges=[-100   -50    0    50   100   150   200   250   300   350   400]';

H=histogram(DistanceToActiveZone,BinEdges,'Normalization','probability');
xlabel('Distance from active zone boundary');
ylabel('Fraction of dynamin cluster')
yyaxis left

Mean_MajorAxis=zeros(length(BinEdges)-1,1);
Mean_MinorAxis=zeros(length(BinEdges)-1,1);
Mean_TotalIntensity=zeros(length(BinEdges)-1,1);
STD_MajorAxis=zeros(length(BinEdges)-1,1);
STD_MinorAxis=zeros(length(BinEdges)-1,1);
STD_TotalIntensity=zeros(length(BinEdges)-1,1);
X=zeros(length(BinEdges)-1,1);
puncta_index_set=cell(length(BinEdges)-1,1);

for ii=1:length(BinEdges)-1
    ind = find(DistanceToActiveZone>=BinEdges(ii) & DistanceToActiveZone<BinEdges(ii+1));
    Mean_MajorAxis(ii) = mean(FWHMMajorAxis(ind));
    Mean_MinorAxis(ii) = mean(FWHMMinorAxis(ind));
    Mean_TotalIntensity(ii) = mean(TotalIntensity(ind));
    STD_MajorAxis(ii) = std(FWHMMajorAxis(ind));
    STD_MinorAxis(ii) = std(FWHMMinorAxis(ind));
    STD_TotalIntensity(ii) = std(TotalIntensity(ind));
    X(ii)=(BinEdges(ii)+BinEdges(ii+1))/2;
    puncta_index_set{ii}=ind;
end
hold on
yyaxis right
p2=errorbar(X,Mean_MajorAxis,STD_MajorAxis,'c-','LineWidth',2);
p3=errorbar(X,Mean_MinorAxis,STD_MinorAxis,'m-','LineWidth',2);
set(gca,'FontSize',30);
ylabel('Puncta size (nm)')
legend([p2,p3],'Major axis','Minor axis')
%%
figure;
histogram(DistanceToActiveZone,BinEdges,'Normalization','probability');
xlabel('Distance from active zone boundary');
ylabel('Fraction of dynamin cluster')
yyaxis left
hold on
yyaxis right
p4=errorbar(X,Mean_TotalIntensity,STD_TotalIntensity,'r-','LineWidth',2);
set(gca,'FontSize',30);
ylabel('Total Intensity (A.U.)')
legend([p4],'Intensity')
%%
BinEdgeStart=BinEdges(1:end-1);
BinEdgeEnd=BinEdges(2:end);
Fraction=H.Values';
BinStatsList=table(BinEdgeStart,BinEdgeEnd,Fraction,Mean_MajorAxis,STD_MajorAxis,Mean_MinorAxis,STD_MinorAxis,Mean_TotalIntensity,STD_TotalIntensity,puncta_index_set);
%%
BinPunctaMajorAxisSizeList=zeros(500,length(BinEdges)-1);
BinPunctaMinorAxisSizeList=zeros(500,length(BinEdges)-1);
BinPunctaAreaList=zeros(500,length(BinEdges)-1);
BinPunctaIntensityList=zeros(500,length(BinEdges)-1);
BinPunctaDistanceList=zeros(500,length(BinEdges)-1);

for ii=1:length(BinEdges)-1
    for jj=1:length(puncta_index_set{ii})
        BinPunctaMajorAxisSizeList(jj,ii)=PunctaParasList.FWHMMajorAxis(puncta_index_set{ii}(jj));
        BinPunctaMinorAxisSizeList(jj,ii)=PunctaParasList.FWHMMinorAxis(puncta_index_set{ii}(jj));
        BinPunctaAreaList(jj,ii)=PunctaParasList.Area(puncta_index_set{ii}(jj));
        BinPunctaIntensityList(jj,ii)=PunctaParasList.TotalIntensity(puncta_index_set{ii}(jj));
        BinPunctaDistanceList(jj,ii)=PunctaParasList.DistanceToActiveZone(puncta_index_set{ii}(jj));
    end
end
