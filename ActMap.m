fs=1;
beatn=1;
%BB activation time,from SA_d 5 to Bach 16
Numi=5;
Numj=16;
Act_BB=delayij(Numi,Numj,beatn,fs,cells);
%SACT,from SAN 1 to SA_d 5
Numi=1;
Numj=5;
Act_SACT=delayij(Numi,Numj,beatn,fs,cells);
%RA activation time,from SA_d 5 to CT 6 OR from SA_d 5 to RA 14 
Numi=5;
Numj=6;
d3=delayij(Numi,Numj,beatn,fs,cells);
Numi=5;
Numj=14;
d4=delayij(Numi,Numj,beatn,fs,cells);
Act_RA=max([abs(d3),abs(d4)]);
%LA activation time,from SA_d 5 to LA 18
Numi=5;
Numj=18;
Act_LA=delayij(Numi,Numj,beatn,fs,cells);
%AVI,from RA_a 13 to RBB 24
Numi=13;
Numj=24;
Act_AVI=delayij(Numi,Numj,beatn,fs,cells);
%From HPS to ventricular activation, from LNB 19 to SEP_LV_m 37, RVA 29
Numi=19;
Numj=37;
Act_HPS_LV=delayij(Numi,Numj,beatn,fs,cells);
Numi=19;
Numj=29;
Act_HPS_RV=delayij(Numi,Numj,beatn,fs,cells);
%Full HPS activation, from LNB 19 to RV 34, LV 39
Numi=19;
Numj=34;
d9=delayij(Numi,Numj,beatn,fs,cells);
Numi=19;
Numj=39;
d10=delayij(Numi,Numj,beatn,fs,cells);
Act_HPS=max([abs(d9),abs(d10)]);
%Full ventricular activation, from SEP_LV_m 37 to SEP_RV 32, CS_LV 36, RVm
%41, LVm 43
Numi=37;
Numj=32;
d11=delayij(Numi,Numj,beatn,fs,cells);
Numi=37;
Numj=36;
d12=delayij(Numi,Numj,beatn,fs,cells);
Numi=37;
Numj=41;
d13=delayij(Numi,Numj,beatn,fs,cells);
Numi=37;
Numj=43;
d14=delayij(Numi,Numj,beatn,fs,cells);
Act_LVRV=max([abs(d11),abs(d12),abs(d13),abs(d14)]);
%RV-LV, from RVA 29 to SEP_LV_m 37
Numi=29;
Numj=37;
Act_RV_LV=delayij(Numi,Numj,beatn,fs,cells);

function d=delayij(Numi,Numj,beatn,fs,cells)
i=(Numi-1)*5+3;
j=(Numj-1)*5+3;
[~,activationi]=findpeaks(cells(i,:),'MinPeakDistance',200);
[~,activationj]=findpeaks(cells(j,:),'MinPeakDistance',200);
d=(activationi(1,beatn)-activationj(1,beatn))/fs;
end