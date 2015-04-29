%Generate dummy status (with random values) to test without KITT
function statustext = dummystatus()
    dir   = num2str(randi([100 200]), '%03u');
    speed = num2str(randi([135 165]), '%03u');
    dist  = num2str(randi([0 999], 2, 1), '%03u');
    batt  = num2str(randi([0 99999]), '%05u');
    audio = num2str(randi([0 1]));
    statustext = ['D' dir ' ' speed '\n' ...
        'U' dist(1) ' ' dist(2) '\n' ...
        'A' batt '\n' ...
        'Audio ' audio '\n'];
end