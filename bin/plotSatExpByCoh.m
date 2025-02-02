%%
basename = 'pcorVsDurByCoh';
data = loadFiles(basename, subj);
outfile = @(dotmode) fullfile('..', 'plots', ['satExpByCoh' '-' subj '-' dotmode '.' fig_ext]);

%%

sz = 180;
lw1 = 2;
lw2 = 6;
lw3 = 3;
dotmodes = {'2d', '3d'};

%%

for i = 1:length(dotmodes)
    dotmode = dotmodes{i};
    i1 = strcmp(data.pts.dotmode, dotmode);
    i2 = strcmp(data.params.dotmode, dotmode);
    if sum(i1) == 0 || sum(i2) == 0
        continue
    end

    fig = figure(i); clf; hold on;
%     title([dotmode ': percent correct vs. duration (msec)']);
    xlbl = xlabel('Duration (msec)');
    ylabel('% Correct');    
    set(gca,'XScale','log');
    
    crvs = [];
    dots = [];
    ebrs = [];
    
    cohs = sort(unique(data.params.coh));
    colorOrder = colorSchemes(dotmode, 'coh', numel(cohs));
    for ci = 1:length(cohs)
        coh = cohs(ci);
        isCoh1 = data.pts.coh == coh;
        isCoh2 = data.params.coh == coh;
        is_bin = strcmp(data.pts.is_bin_or_fit, 'bin');
        is_fit = strcmp(data.pts.is_bin_or_fit, 'fit');
        
        xb = data.pts.xs(isCoh1 & is_bin & i1);
        yb = data.pts.ys(isCoh1 & is_bin & i1);
        ns = data.pts.ntrials(isCoh1 & is_bin & i1);
        xf = data.pts.xs(isCoh1 & is_fit & i1);
        yf = data.pts.ys(isCoh1 & is_fit & i1);
        err = sqrt((yb.*(1-yb))./ns);
        errs = [err err];
        
        A = data.params.A(isCoh2 & i2);
        B = data.params.B(isCoh2 & i2);
        T = data.params.T(isCoh2 & i2);
        
        % use mean of parameters to plot line
        A = mean(A);
        B = mean(B);
        T = mean(T);
        
        disp([dotmode ' ' num2str(coh) ' ' num2str(A)])
        
        color = colorOrder(ci, :);
        lbl = num2str(sprintf('%d%%', coh*100));
%         plot([T+x_delay, T+x_delay], [0.4, 1.0], '--', 'Color', color, 'LineWidth', lw3, 'HandleVisibility', 'off');
        crv = plot(xf, yf, '-', 'Color', color, 'LineWidth', lw2, 'DisplayName', num2str(lbl));
        ebr = errorbar(xb, yb, errs(:,1), errs(:,2), 'Color', 'k', 'LineWidth', lw1, 'LineStyle', 'none', 'Marker', 'none', 'HandleVisibility', 'off');
        dts = scatter(xb, yb, sz, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color, 'LineWidth', lw1, 'HandleVisibility', 'off');
        errorbar_tick(ebr, 0); % problem with log
        
        crvs = [crvs; crv];
        dots = [dots; dts];
        ebrs = [ebrs; ebr];
    end
    crvs = crvs(end:-1:1);
    uistack(dots, 'bottom');
    uistack(ebrs, 'bottom');
    uistack(crvs, 'bottom');
    
    xlim([floor(min(data.pts.xs)), 6000]);
    ylim([0.45, 1.0]);
    
    set(gca, 'XTick', [33, 200, 1000, 6000]);
    set(gca, 'XTickLabel', {'33', '200', '1000', '6000'});
    set(gca, 'YTick', [0.5, 0.75, 1.0]);
    set(gca, 'YTickLabel', {'50', '75', '100'});
    leg = legend('Location', 'NorthWest');
    set(leg, 'LineWidth', lw1);
    plotFormats;
    print(fig, ['-d' fig_ext], outfile(dotmode));
end
