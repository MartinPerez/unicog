function [cardiac_phase, verbose] = tapas_physio_get_cardiac_phase(...
    pulset,scannert, verbose, svolpulse)
% estimates cardiac phases from cardiac pulse data
%
% USAGE
%   cardiac_phase = tapas_physio_get_cardiac_phase(pulset,scannert, verbose, svolpulse)
%
% INPUT
%        pulset     - heart-beat/pulseoxymeter data read from spike file
%        scannert   - scanner slice pulses read from log file
%        verbose    - set verbose.level >=3, if figures for debugging are wanted
%        svolpulse  - volume start pulses from log file (only for plot reasons)
%
% OUTPUT
%        cardiac_phase - phase in heart-cycle when each slice of each
%        volume was acquired
%        fh         - figure handle
%
% The regressors are calculated as described in
% Glover et al, 2000, MRM, (44) 162-167
% Josephs et al, 1997, ISMRM, p1682
%_______________________________________________________________________
% Author: Lars Kasper, heavily based on an earlier implementation of
%                      Eric Featherstone and Chloe Hutton 26/03/07 (FIL,
%                      UCL London)
%
% Copyright (C) 2009, Institute for Biomedical Engineering, ETH/Uni Zurich.
%
% This file is part of the PhysIO toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.
%
% $Id: tapas_physio_get_cardiac_phase.m 753 2015-07-05 20:03:43Z kasperla $
%

%% Added by A. Moreno - 04/07/2016
% To improve figures visualization
linewidth = 1;
axesfontsize = 15;
%%

% Find the time of pulses just before and just after each scanner time
% point. Where points are missing, fill with NaNs and set to zero later.

isVerbose = verbose.level >=3;

scannertpriorpulse = zeros(1,length(scannert));
scannertafterpulse = scannertpriorpulse;
for i=1:length(scannert)
    n = find(pulset < scannert(i), 1, 'last');
    if ~isempty(n) && (n+1)<=size(pulset,1)
        scannertpriorpulse(i) = pulset(n);
        scannertafterpulse(i) = pulset(n+1);
    else
        scannert(i)=NaN;
        scannertafterpulse(i) = NaN;
        scannertpriorpulse(i)= 0;
    end
end

% Calculate cardiac phase at each slice (from Glover et al, 2000).
cardiac_phase=(2*pi*(scannert'-scannertpriorpulse)./(scannertafterpulse-scannertpriorpulse))';



if isVerbose
    % 1. plot chosen slice start event
    % 2. plot chosen c_sample phase on top of chosen slice scan start, (as a stem
    % and line of phases)
    % 3. plot all detected cardiac r-wave peaks
    % 4. plot volume start event
    titstr = 'tapas_physio_get_cardiac_phase: scanner and R-wave pulses - output phase';
    fh = tapas_physio_get_default_fig_params();
    set(fh, 'Name', titstr);
    %stem(scannert, cardiac_phase, 'k'); hold on;
    %plot(scannert, cardiac_phase, 'k');
    %stem(pulset,3*ones(size(pulset)),'r', 'LineWidth',2);
    %stem(svolpulse,7*ones(size(svolpulse)),'g', 'LineWidth',2);
    %% Changed by A. Moreno - 04/07/2016
    stem(scannert, cardiac_phase, 'k', 'LineWidth', linewidth); hold on;
    plot(scannert, cardiac_phase, 'k', 'LineWidth', linewidth);
    stem(pulset,3*ones(size(pulset)),'r', 'LineWidth', linewidth);
    stem(svolpulse,7*ones(size(svolpulse)),'g', 'LineWidth', linewidth);
    legend('estimated phase at slice events', ...
        '', ...
        'heart beat R-peak', ...
        'scan volume start');
    title(regexprep(titstr,'_', '\\_'));
    xlabel('t (seconds)');
    %stem(scannertpriorpulse,ones(size(scannertpriorpulse))*2,'g');
    %stem(scannertafterpulse,ones(size(scannertafterpulse))*2,'b');
    
    %% Added by A. Moreno - 04/07/2016
    set(gca,'FontSize',axesfontsize)
end


%cardiac_phase=cardiac_phase((nslices*ndummies)+slicenum:nslices:end);
n=find(isnan(cardiac_phase));

if ~isempty(n) % probably no heartbeat after last scan found
    Nvol = length(svolpulse);
    Nsli = length(scannert)/Nvol;
    
    iVolPhaseNaN = ceil(n/Nsli);
    
    [iVolExamples, iVolinN] = unique(iVolPhaseNaN'); % show only first occurence
    
    if min(iVolExamples) < Nvol
        verbose = tapas_physio_log(sprintf('Zero-padding for non-existent pulse data in %d slice(s)',size(n,1)), ...
            verbose, 1);
        
        for iVol = setdiff(iVolExamples, Nvol)
            iSli = Nsli - mod(Nsli - n(iVolinN(iVol)),Nsli);
            verbose = tapas_physio_log(sprintf('Volume %d, first occurence in slice %d\n', iVol, iSli), ...
                verbose);  
        end
        verbose = tapas_physio_log(sprintf('NOTE: cardiac phase regressors might be mis-estimated for these volumes\n'), ...
            verbose);
    end
end
