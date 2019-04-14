clc;clear all;
%save different electrical field

row_num = 320;
colum_num = 400;

for z = 52:100
    % background + edges
    for i = 1:row_num
        for j = 1:colum_num
            a(i,j,1) = 0;
            a(i,j,2) = 0;
        end
    end
    %sphere
    center = [160 200];
    radius = 50;
    for i = 1:row_num
        for j = 1:colum_num
            if norm(center-[i j])<radius
                a(i,j,2) = 100-z;
                a(i,j,1) = 1;
            end
        end
    end
    %%{
    %iterative finite difference method
    complete = 1; % 1 all correct   0 have false
    sprintf('Start')
    for k=1:500000
        complete = 1;
        for i=2:row_num-1
            for j=2:colum_num-1
                if a(i,j,1)==0
                    if complete== 1
                        if abs((a(i,j,2)-differential_value(a,i,j))/a(i,j,2)) > 0.0001
                            complete = 0;
                        end
                    end
                    a(i,j,2) = differential_value(a,i,j);
                end
            end
        end
        if complete == 1 
            break
        end
    end

    sprintf('End')
    disp(k)
    %}

    %caculate electric field
    divident = 1; 
    e_x = zeros(row_num/divident,colum_num/divident);   %
    e_y = zeros(row_num/divident,colum_num/divident);   %

    for i=2:row_num/divident-1
        for j = 2:colum_num/divident-1
            [e_x(i,j), e_y(i,j)] = electric_vector(a,i*divident,j*divident);
        end
    end


%{
    %quiver for corridinate
    for i = 1:row_num/divident
        for j = 1:colum_num/divident
            x_cordinate(i,j) = j*divident;
        end
    end
    for i = 1:row_num/divident
        for j = 1:colum_num/divident
            y_cordinate(i,j) = i*divident;
        end
    end

    quiver(x_cordinate,y_cordinate,e_x, e_y,'linewidth',2,'MaxHeadSize',2000);
%}
    save(strcat('potential/save_potential_ex',int2str(z),'.mat'),'e_x')
    save(strcat('potential/save_potential_ey',int2str(z),'.mat'),'e_y')
end



function y = differential_value(a, i, j)
y = (a(i+1,j,2) + a(i-1,j,2) + a(i,j+1,2) +a(i, j-1,2))/4;
end

function [x,y] = electric_vector(a,i,j)
x= -(a(i,j+1,2)-a(i,j-1,2))/(2);
y = -(a(i+1,j,2)-a(i-1,j,2))/(2);
end