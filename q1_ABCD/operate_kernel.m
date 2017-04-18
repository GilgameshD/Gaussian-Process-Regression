function [maxlik, handle, hyp] = operate_kernel(current_handle, opt, ker, current_hyp)

    % at the begnning
    if isempty(current_handle)
        switch ker
            case 'SE'
                handle = {'covSEiso'};
                [maxlik, hyp] = get_maxlik(handle, current_hyp);
            case 'RQ'
                handle = {'covRQiso'};
                [maxlik, hyp] = get_maxlik(handle, current_hyp);
            case 'LIN'
                handle = {'covLINiso'};
                [maxlik, hyp] = get_maxlik(handle, current_hyp);
            case 'PER'
                handle = {'covPeriodic'};
                [maxlik, hyp] = get_maxlik(handle, current_hyp);
            case 'NOI'
                handle = {'covNoise'};
                [maxlik, hyp] = get_maxlik(handle, current_hyp);
        end
    else
        if strcmp(opt, 'add')
            switch ker
                case 'SE'
                    handle = {'covSum', {current_handle, 'covSEiso'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'RQ'
                    handle = {'covSum', {current_handle, 'covRQiso'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'LIN'
                    handle = {'covSum', {current_handle, 'covLINiso'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'PER'
                    handle = {'covSum', {current_handle, 'covPeriodic'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'NOI'
                handle = {'covSum', {current_handle, 'covNoise'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
            end
        else
            switch ker
                case 'SE'
                    handle = {'covProd', {current_handle, 'covSEiso'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'RQ'
                    handle = {'covProd', {current_handle, 'covRQiso'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'LIN'
                    handle = {'covProd', {current_handle, 'covLINiso'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
                case 'PER'
                    handle = {'covProd', {current_handle, 'covPeriodic'}};
                    [maxlik, hyp] = get_maxlik(handle, current_hyp);
            end
        end
   end
end