function tau = calc_tau(n_cases, date)

    % find the latest number of cases and today's date
    n_cases_today = n_cases(end,1) ; 
    date_today = date(end,1) ; 
    
    % divide by two, round to nearest whole number
    n_cases_half_today = round(n_cases_today / 2) ; 
    
    % find the value in n_cases closest to this number
    [~, tau_index] = min(n_cases - n_cases_half_today) ; 
    
    % find the date at which this was true
    date_half_today = date(tau_index,1) ; 
    
    % return the time constant in days
    tau = datenum(date_today) - datenum(date_half_today) ; 
    
end