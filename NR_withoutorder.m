% This code use to read the bus data
fid = fopen('ieee14BusesData.txt','r');
Bus = textscan(fid,'%u8 %s %u8 %s %u8 %u8 %u8 %f32 %f32 %f32 %f32 %f32 %f32 %f32 %f32 %f32 %f32 %f32 %f32 %f32');
fclose(fid);
% Total_buses = length([Bus{1,1}]);
% This code use to read the branch data
fid = fopen('ieee14BranchesData.txt','r');
Branch = textscan(fid,'%f32 %f32 %u8 %u8 %u8 %u8 %f32 %f32 %f32 %u8 %u8 %u8 %u8 %u8 %f32 %f32 %f32 %f32 %f32 %f32 %f32');
fclose(fid);
Branches = [Branch{1,1}, Branch{1,2}, Branch{1,7}, Branch{1,8}, Branch{1,9}, Branch{1,15}];
BranchY = 1./(Branches(:,3)+Branches(:,4)*1i);
BranchB = Branch{1,9};
Total_buses = length([Bus{1,1}]); %to give the total number of the buses
% To find the Y bus matrix
Yij = zeros(Total_buses);
for i = 1:size(Branches,1)
    BUS1 = Branches(i,1);
    BUS2 = Branches(i,2);
    Yij(BUS1,BUS1) = Yij(BUS1,BUS1) + BranchY(i) + (Branches(i,5)-0.5*BranchB(i))*1i;
    Yij(BUS2,BUS2) = Yij(BUS2,BUS2) + BranchY(i) + (Branches(i,5)-0.5*BranchB(i))*1i;
    Yij(BUS1,BUS2) = Yij(BUS1,BUS2) - BranchY(i);
    Yij(BUS2,BUS1) = Yij(BUS2,BUS1) - BranchY(i);
end
Yij_Magnitude = abs(Yij); % magnitude of Yij
Yij_Angle = angle(Yij); % phase angle of Yij in radian
%************** Buses Type *************
BusType = [Bus{1,7}];
PQ = find(BusType == 0 | BusType == 1);
PV = find(BusType == 2);
Swing = find(BusType == 3);
BUS_no = [Bus{1,1}]; Bus_no_PVPQ = [Bus{1,1}]; Bus_no_PVPQ(Swing) = [];
Voltage = [Bus{1,8}]; Voltage(PQ',1) = 1 ; % Set PQ buses Voltage = 1
Phase_Angle = [Bus{1,9}]; Phase_Angle([PQ',PV'],1) = 0 ; % Set PV&PQ buses Phase angle = 0
Pi = [Bus{1,12}]; Pi(Swing) = 0 ; % Set swing bus P = 0
Qi = [Bus{1,13}]; Qi(Swing) = 0; % Set swing bus Q = 0
P_injection = (Pi - [Bus{1,10}])/100;
Q_injection = (Qi - [Bus{1,11}])/100;
count = 0; Err = 1; Stp_Err = 0.01; % Err= error.. Stp_Err= stopping error
while Err > Stp_Err
    DELTA_P = [];
    DELTA_Q = [];
    J11 = []; J12 = []; J21 = []; J22 = [];
    %J11 i/i
    for i = Bus_no_PVPQ'
        S = 0; Jacobian = 0;
        for j = BUS_no'
            S = S + Voltage(j)*Yij_Magnitude(i,j)*cos(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
            Jacobian = Jacobian + Voltage(j)*Yij_Magnitude(i,j)*sin(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
        end
        DELTA_P = [DELTA_P; P_injection(i) - Voltage(i)*S];
        J11 = [J11, -Voltage(i)*Jacobian - (Voltage(i)^2)*Yij_Magnitude(i,i)*sin(Yij_Angle(i,i))];
    end
    J11 = diag(J11);
    % J11 i/j
    J11_nondiag = [];
    for i = Bus_no_PVPQ'
        for j = Bus_no_PVPQ'
            if i ~= j
                J11_nondiag(i,j) = Voltage(i)*Voltage(j)*Yij_Magnitude(i,j)*sin(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
            end
        end
    end
    J11_nondiag(Swing,:) = [];
    J11_nondiag(:,Swing) = [];
    J11 = J11 + J11_nondiag;
    %J12 i/i and J21 i/i
    for i = PQ'
        Jacobian = 0;
        for j = BUS_no'
            Jacobian = Jacobian + Voltage(j)*Yij_Magnitude(i,j)*cos(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
        end
        J12(find(Bus_no_PVPQ==i),find(PQ==i)) = Jacobian + Voltage(i)*Yij_Magnitude(i,i)*cos(Yij_Angle(i,i));
        J21(find(PQ==i),find(Bus_no_PVPQ==i)) = Voltage(i)*Jacobian - (Voltage(i)^2)*Yij_Magnitude(i,i)*cos(Yij_Angle(i,i));
    end
    % J12 i/j
    for i = Bus_no_PVPQ'
        for j = PQ'
            if i ~= j
                J12(find(Bus_no_PVPQ==i),find(PQ==j)) = Voltage(i)*Yij_Magnitude(i,j)*cos(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
            end
        end
    end
    % J21 i/j
    for i = PQ'
        for j = Bus_no_PVPQ'
            if i ~= j
                J21(find(PQ==i),find(Bus_no_PVPQ==j)) = -Voltage(i)*Voltage(j)*Yij_Magnitude(i,j)*cos(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
            end
        end
    end
    % J22 i/i
    for i = PQ'
        S = 0;
        for j = BUS_no'
            S = S + Voltage(j)*Yij_Magnitude(i,j)*sin(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
        end
        DELTA_Q = [DELTA_Q; Q_injection(i)-Voltage(i)*S];
        J22(find(PQ==i),find(PQ==i)) = S - Voltage(i)*Yij_Magnitude(i,i)*sin(Yij_Angle(i,i));
    end
    %J22 i/j
    for i = PQ'
        for j = PQ'
            if i ~= j
                J22(find(PQ==i),find(PQ==j)) = Voltage(i)*Yij_Magnitude(i,j)*sin(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
            end
        end
    end
    Delta_PhaseangleVoltage = [DELTA_P; DELTA_Q];
    % Jacobian
    Jacobian = [J11, J12; J21, J22];
    Jacobian(find(abs(Jacobian)<0.5)) = 0;
    
    [TJ, TJF] = store_in_linked_list(Jacobian);
    ordered_index = 1:22;
    [TQ, TQF] = LU_linked_list(TJ, TJF, ordered_index);
    
    dv_x = FB_linked_list(TQ, TQF, Delta_PhaseangleVoltage(ordered_index));
    
    dv_x = ordering_scheme_reversion(dv_x, ordered_index);
  
    Phase_Angle(Bus_no_PVPQ',1) = Phase_Angle(Bus_no_PVPQ',1) + dv_x(1:length(Bus_no_PVPQ));
    Voltage(PQ',1) = Voltage(PQ',1) + dv_x(length(Bus_no_PVPQ)+1:end);
    
    Err = max(abs(Delta_PhaseangleVoltage));
end
% compute the P and Q
for i = BUS_no'
    sigma1 = 0; sigma2 = 0;
    for j = BUS_no'
        sigma1 = sigma1 + Voltage(j)*Yij_Magnitude(i,j)*cos(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
        sigma2 = sigma2 + Voltage(j)*Yij_Magnitude(i,j)*sin(Phase_Angle(i)-Phase_Angle(j)-Yij_Angle(i,j));
    end
    P_injection(i) = Voltage(i)*sigma1;
    Q_injection(i) = Voltage(i)*sigma2;
end
Pgen = P_injection + [Bus{1,10}]/100;
Qgen = Q_injection + [Bus{1,11}]/100;