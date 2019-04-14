%dynamic central force
clc;clear all;
row_num = 320;
colum_num = 400;
circle_num = 50;
ele_ratio = 1.75882*10^11;  %e/m

%for quiver
for i = 1:row_num
     for j = 1:colum_num
        x_cordinate(i,j) = j;
    end
end
for i = 1:row_num
    for j = 1:colum_num
        y_cordinate(i,j) = i;
    end
end

%for centrol force
e_x = zeros(row_num,colum_num,circle_num);
e_y = zeros(row_num,colum_num,circle_num);
sx = 10;
for z = 50:99
    example_x = matfile(strcat('potential/save_potential_ex',int2str(z),'.mat'));
    example_y = matfile(strcat('potential/save_potential_ey',int2str(z),'.mat'));
    e_x(:,:,100-z) = example_x.e_x;
    e_y(:,:,100-z) = example_y.e_y;
    %quiver(x_cordinate(1:sx:end,1:sx:end),y_cordinate(1:sx:end,1:sx:end),e_x(1:sx:end,1:sx:end,100-z), e_y(1:sx:end,1:sx:end,100-z),'AutoScaleFactor',5);
end
e_x = e_x*ele_ratio;
e_y = e_y*ele_ratio; 

%initialize background
for i = 1:row_num
    for j = 1:colum_num
        sheet(i,j)=100;
    end
end

%sphere
center = [160 200];
real_center = [200,160];%front is x behind is y
radius = 50;
for i = 1:row_num
    for j = 1:colum_num
        if norm(center-[i j])<radius
            sheet(i,j) = 50;
        end
    end
end



current_x = 200;
current_y = 80;
desired_radius = 80;
speed_x = 1920937;
speed_y = 0;
size = 1;
force_index = 25; %choose which electronic field to use
t = 0.000001;





while judge(current_x,current_y,colum_num,row_num,size)==1
    sheet(round(current_y),round(current_x)) = 0;
    imshow(mat2gray(sheet));
    hold on;
    quiver(x_cordinate(1:sx:end,1:sx:end),y_cordinate(1:sx:end,1:sx:end),e_x(1:sx:end,1:sx:end,force_index), e_y(1:sx:end,1:sx:end,force_index),'AutoScaleFactor',2);
    axis equal
    hold off;  
    drawnow
    current_x = current_x + speed_x*t;
    current_y = current_y + speed_y*t;
    
    vector_rad = [current_x current_y]-real_center;
    vector_norm_rad = vector_rad/norm(vector_rad);
    vector_tangent = rotate_vector(vector_norm_rad,90);
    tangent_speed = dot([speed_x,speed_y],vector_tangent);
    normal_speed = dot([speed_x,speed_y],vector_norm_rad);
    factor = 1 + (sqrt(sum(vector_rad.^2))-desired_radius)*100/desired_radius;
    needing_center_force = (factor*tangent_speed^2)/sqrt(sum(vector_rad.^2)) + 0.1*normal_speed/t;
    force_index = find_index(e_x, e_y, needing_center_force, current_x, current_y, circle_num);    
    disp(force_index);
    speed_x = speed_x-e_x(round(current_y),round(current_x),force_index)*t;
    speed_y = speed_y-e_y(round(current_y),round(current_x),force_index)*t;
end

function y = judge(x_cordinate,y_cordinate, x_range, y_range,size)
    if (x_cordinate-size>0)&&(x_cordinate+size<=x_range)&&(y_cordinate-size>0)&&(y_cordinate+size<=y_range)
        y = 1;
    else
        y = 0;
    end
end

function y = rotate_vector(vector,angle)
th = angle*pi/180;
R = [cos(th) -sin(th) ;sin(th) cos(th)] ;
y = transpose(R*transpose(vector));
end

function y = find_index(force_x, force_y, needing_force, pos_x, pos_y, total_index)
nearest_index = 1;
min = 9999999999;
for i = 1:total_index
    if abs(sqrt(force_x(round(pos_y),round(pos_x),i)^2+force_y(round(pos_y),round(pos_x),i)^2)-needing_force)<min
        nearest_index = i;
    end
end
y = nearest_index;
return
end

