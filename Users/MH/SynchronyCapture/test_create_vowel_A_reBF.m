clear;
clc;

figHan.PSD= 1;
figHan.time_spl= 2;

allBFs= [210 480 520 2100 5216 7746 9999];
% allBFs= 210;

CodesDir= '/media/parida/DATAPART1/Matlab/Design_Exps_NEL/SynchronyCapture/';
outDataDir= '/media/parida/DATAPART1/Matlab/Design_Exps_NEL/SynchronyCapture/output/testing/';

redo_wavfiles= 0;

nSP_rows= 5;
nSP_cols= 2;
SPorder= reshape(1:nSP_rows*nSP_cols, nSP_cols, nSP_rows)';
SPorder= SPorder(:);

all_SPLs= nan(length(allBFs), 10); % Assuming 10 wav-files

for bfVar= 1:length(allBFs)
    BF_Hz= allBFs(bfVar);
    
    if redo_wavfiles
        create_vowel_A_reBF(outDataDir, BF_Hz, CodesDir);
    end
    
    wav_files= dir([outDataDir '*BF' num2str(BF_Hz) '_*.wav']);
    
    %% plot
    xtick_vals= sort([100 500 2e3 5e3]);
    xtick_labs= cellfun(@(x) num2str(x), num2cell(xtick_vals), 'UniformOutput', false);
    fSize= 16;
    figure(figHan.PSD);
    clf;
    figure(figHan.time_spl);
    clf;
    
    ax= nan(length(wav_files), 1);
    bx= nan(length(wav_files), 1);
    cx= nan(length(wav_files), 1);
    
    for fileVar=1:length(wav_files)
        [x, fs] =audioread([outDataDir wav_files(fileVar).name]);
        
        
        %%
        figure(figHan.PSD);
        ax(fileVar)= subplot(5,2, SPorder(fileVar));
        nfft= 2^nextpow2(numel(x));
        [Pxx_dB, Freq]= plot_dpss_psd(x, fs, 'yrange', 60, 'norm', true, 'plot', false);
        Pxx_dBSPL= Pxx_dB*nfft/fs; % un-norm
        Pxx_dBSPL= dbspl(sqrt(db2mag(Pxx_dBSPL*2)/nfft* fs*length(x)));
        ylim([-85 -15]);
        title('')
        ylabel(wav_files(fileVar).name(max(strfind(wav_files(fileVar).name, '_'))+1:end-4));
        if ~ismember(SPorder(fileVar), [9 10])
            xlabel('');
            set(gca,'XTick', xtick_vals, 'XTickLabel', '');
        else
            text(BF_Hz*1.03, min(ylim)+1, sprintf('BF=%.0fHz', BF_Hz));
        end
        hold on;
        ind= dsearchn(Freq, BF_Hz);
        plot([Freq(ind) Freq(ind)], [-100 0], 'r-', 'LineWidth', 2.5);
        fprintf('Duration is %.0f ms\n', 1e3*numel(x)/fs);
        
        % Also calculate near CF (octave range) power
        ind_freq_lower= dsearchn(Freq, BF_Hz/sqrt(2));
        ind_freq_upper= dsearchn(Freq, BF_Hz*sqrt(2));
        totalPower_nearBF= sum(db2mag(2*Pxx_dB(ind_freq_lower:ind_freq_upper)));
        nearCF_dBSPL= dbspl(totalPower_nearBF);
        text(min(xlim), min(ylim)+1, sprintf('~CF:%.1f dB SPL', nearCF_dBSPL));
        
        figure(figHan.time_spl);
        tX= (1:length(x))/fs;
        subplot(5,2, SPorder(fileVar));
        
        yyaxis left;
        bx(fileVar)= gca;
        plot(tX, x);
        ylabel(wav_files(fileVar).name(max(strfind(wav_files(fileVar).name, '_'))+1:end-4));
        text(min(xlim), min(ylim)+.1, sprintf('SUM:%.1f dB SPL', calc_dbspl(x)));
        all_SPLs(bfVar, fileVar)= calc_dbspl(x);
        
        yyaxis right;
        cx(fileVar)= gca;
        [splVals, timeVals] = gen_get_spl_vals(x, fs, 20e-3, .5);
        plot(timeVals, splVals, 'd-');
        
        if ~ismember(SPorder(fileVar), [9 10])
            xlabel('');
            set(gca, 'XTickLabel', '');
        else 
            xlabel('Time (sec)');
        end
    end
    
    figure(figHan.PSD);
    linkaxes(ax, 'x') ;
    set(findall(gcf,'-property','FontSize'),'FontSize', fSize);
    set(gcf, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
    set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
    saveas(figHan.PSD, sprintf('%sPSD_CF_%.0fHz', outDataDir, BF_Hz), 'png');
    
    figure(figHan.time_spl);
    linkaxes(bx, 'x') ;
    linkaxes(cx, 'y') ;
    set(findall(gcf,'-property','FontSize'),'FontSize', fSize);
    set(gcf, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
    saveas(figHan.time_spl, sprintf('%sTIME_CF_%.0fHz', outDataDir, BF_Hz), 'png');
end