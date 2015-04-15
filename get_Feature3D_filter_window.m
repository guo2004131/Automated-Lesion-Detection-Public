function Feature3D = get_Feature3D_filter_window(BlockSize)
% Inputs: BlockSize.This input should be an matrix [d1, d2, d3]
% 1st Feature Range: 01 ~ 06
% 2nd Feature Range: 07 ~ 18
% 3rd Feature Range: 19 ~ 24
% 4th Feature Range: 25 ~ 26
%% Parameter Setting
% BlockSize = [4,4,4];
Feature3D = zeros(BlockSize(1),BlockSize(2),BlockSize(3),13);
count = 1;
%% Feature 1
%-------------------------------------------------------------------------%
% block-wise feature (axial view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(1)/2)
	out_window(i,:,:) = 1;
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;
% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(1)/2)
% 	out_window(i,:,:) = -1;
% end
% Feature3D(:,:,:,count) = out_window;    
% count = count + 1;
%-------------------------------------------------------------------------%
% block-wise feature (coronal view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(2)/2)
	out_window(:,i,:) = 1;
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;
% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(2)/2)
% 	out_window(:,i,:) = -1;
% end
% Feature3D(:,:,:,count) = out_window;    
% count = count + 1;
%-------------------------------------------------------------------------%
% block-wise feature (saggital view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(3)/2)
	out_window(:,:,i) = 1;
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;
% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(3)/2)
% 	out_window(:,:,i) = -1;
% end
% Feature3D(:,:,:,count) = out_window;    
% count = count + 1;
%-------------------------------------------------------------------------%
%% Feature 2
%-------------------------------------------------------------------------%
% diagnoal feature (axial view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:BlockSize(1)
	for j = 1:BlockSize(2)
        if i+j <= BlockSize(3)
            out_window(i,j,:) = 1;
        end
        if i+j == BlockSize(3) + 1
            out_window(i,j,:) = 0;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:BlockSize(1)
% 	for j = 1:BlockSize(2)
%         if i+j <= BlockSize(3)
%             out_window(i,j,:) = -1;
%         end
%         if i+j == BlockSize(3) + 1
%             out_window(i,j,:) = 0;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;

out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:BlockSize(1)
	for j = 1:BlockSize(2)
        if (BlockSize(3)-i)+j <= BlockSize(3)-1
            out_window(i,j,:) = 1;
        end
        if (BlockSize(3)-i)+j == BlockSize(3);
            out_window(i,j,:) = 0;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:BlockSize(1)
% 	for j = 1:BlockSize(2)
%         if (BlockSize(3)-i)+j <= BlockSize(3)-1
%             out_window(i,j,:) = -1;
%         end
%         if (BlockSize(3)-i)+j == BlockSize(3);
%             out_window(i,j,:) = 0;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;
%-------------------------------------------------------------------------%
% diagnoal feature (coronal view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:BlockSize(1)
	for j = 1:BlockSize(3)
        if i+j <= BlockSize(2)
            out_window(i,:,j) = 1;
        end
        if i+j == BlockSize(2) + 1
            out_window(i,:,j) = 0;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:BlockSize(1)
% 	for j = 1:BlockSize(3)
%         if i+j <= BlockSize(2)
%             out_window(i,:,j) = -1;
%         end
%         if i+j == BlockSize(2)+1
%             out_window(i,:,j) = 0;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;

out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:BlockSize(1)
	for j = 1:BlockSize(3)
        if (BlockSize(2)-i)+j <= BlockSize(2)-1
            out_window(i,:,j) = 1;
        end
        if (BlockSize(2)-i)+j == BlockSize(2) 
            out_window(i,:,j) = 0;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:BlockSize(1)
% 	for j = 1:BlockSize(3)
%         if (BlockSize(2)-i)+j <= BlockSize(2)-1
%             out_window(i,:,j) = -1;
%         end
%         if (BlockSize(2)-i)+j == BlockSize(2) 
%             out_window(i,:,j) = 0;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;
%-------------------------------------------------------------------------%
% diagnoal feature (saggital view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:BlockSize(2)
	for j = 1:BlockSize(3)
        if i+j <= BlockSize(1)
            out_window(:,i,j) = 1;
        end
        if i+j == BlockSize(1)+1
            out_window(:,i,j) = 0;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:BlockSize(2)
% 	for j = 1:BlockSize(3)
%         if i+j <= BlockSize(1)
%             out_window(:,i,j) = -1;
%         end
%         if i+j == BlockSize(1)+1
%             out_window(:,i,j) = 0;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;

out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:BlockSize(2)
	for j = 1:BlockSize(3)
        if (BlockSize(1)-i)+j <= BlockSize(1)-1
            out_window(:,i,j) = 1;
        end
        if (BlockSize(1)-i)+j == BlockSize(1)
            out_window(:,i,j) = 0;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:BlockSize(2)
% 	for j = 1:BlockSize(3)
%         if (BlockSize(1)-i)+j <= BlockSize(1)-1
%             out_window(:,i,j) = -1;
%         end
%         if (BlockSize(1)-i)+j == BlockSize(1)
%             out_window(:,i,j) = 0;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;
%-------------------------------------------------------------------------%
%% Feature 3
%-------------------------------------------------------------------------%
% Sub_tube feature (axial view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(1)/2)
	for j = 1:floor(BlockSize(2)/2)
        out_window(i,j,:) = 1;
	end
end
for i = BlockSize(1):-1:floor(BlockSize(1)/2)+1
	for j = BlockSize(2):-1:floor(BlockSize(1)/2)+1
        out_window(i,j,:) = 1;
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(1)/2)
% 	for j = 1:floor(BlockSize(2)/2)
%         out_window(i,j,:) = -1;
% 	end
% end
% for i = BlockSize(1):-1:floor(BlockSize(1)/2)+1
% 	for j = BlockSize(2):-1:floor(BlockSize(1)/2)+1
%         out_window(i,j,:) = -1;
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;
%-------------------------------------------------------------------------%
% Sub_tube feature (coronal view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(1)/2)
	for j = 1:floor(BlockSize(3)/2)
        out_window(i,:,j) = 1;
	end
end
for i = BlockSize(1):-1:floor(BlockSize(1)/2)+1
	for j = BlockSize(3):-1:floor(BlockSize(3)/2)+1
        out_window(i,:,j) = 1;
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(1)/2)
% 	for j = 1:floor(BlockSize(3)/2)
%         out_window(i,:,j) = -1;
% 	end
% end
% for i = BlockSize(1):-1:floor(BlockSize(1)/2)+1
% 	for j = BlockSize(3):-1:floor(BlockSize(3)/2)+1
%         out_window(i,:,j) = -1;
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;
%-------------------------------------------------------------------------%
% Sub_tube feature (saggital view)
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(2)/2)
	for j = 1:floor(BlockSize(3)/2)
        out_window(:,i,j) = 1;
	end
end
for i = BlockSize(2):-1:floor(BlockSize(2)/2)+1
	for j = BlockSize(3):-1:floor(BlockSize(3)/2)+1
        out_window(:,i,j) = 1;
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(2)/2)
% 	for j = 1:floor(BlockSize(3)/2)
%         out_window(:,i,j) = -1;
% 	end
% end
% for i = BlockSize(2):-1:floor(BlockSize(2)/2)+1
% 	for j = BlockSize(3):-1:floor(BlockSize(3)/2)+1
%         out_window(:,i,j) = -1;
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% count = count + 1;
%% Feature 4
out_window = -1*ones(BlockSize(1),BlockSize(2),BlockSize(3));
for i = 1:floor(BlockSize(1)/2)
	for j = 1:floor(BlockSize(2)/2)
        for k = 1:floor(BlockSize(3)/2)
            out_window(i,j,k) = 1;
        end
	end
end
for i = floor(BlockSize(1)/2)+1:BlockSize(1)
	for j = floor(BlockSize(2)/2)+1:BlockSize(2)
        for k = 1:floor(BlockSize(3)/2)
            out_window(i,j,k) = 1;
        end
	end
end
for i = floor(BlockSize(1)/2)+1:BlockSize(1)
	for j = 1:floor(BlockSize(2)/2)
        for k = floor(BlockSize(3)/2)+1:BlockSize(3)
            out_window(i,j,k) = 1;
        end
	end
end
for i = 1:floor(BlockSize(1)/2)%+1:BlockSize(1)
	for j = floor(BlockSize(2)/2)+1:BlockSize(2)
        for k = floor(BlockSize(3)/2)+1:BlockSize(3)
            out_window(i,j,k) = 1;
        end
	end
end
Feature3D(:,:,:,count) = out_window;
count = count + 1;

% out_window = ones(BlockSize(1),BlockSize(2),BlockSize(3));
% for i = 1:floor(BlockSize(1)/2)
% 	for j = 1:floor(BlockSize(2)/2)
%         for k = 1:floor(BlockSize(3)/2)
%             out_window(i,j,k) = -1;
%         end
% 	end
% end
% for i = floor(BlockSize(1)/2)+1:BlockSize(1)
% 	for j = floor(BlockSize(2)/2)+1:BlockSize(2)
%         for k = 1:floor(BlockSize(3)/2)
%             out_window(i,j,k) = -1;
%         end
% 	end
% end
% for i = floor(BlockSize(1)/2)+1:BlockSize(1)
% 	for j = 1:floor(BlockSize(2)/2)
%         for k = floor(BlockSize(3)/2)+1:BlockSize(3)
%             out_window(i,j,k) = -1;
%         end
% 	end
% end
% for i = 1:floor(BlockSize(1)/2)%+1:BlockSize(1)
% 	for j = floor(BlockSize(2)/2)+1:BlockSize(2)
%         for k = floor(BlockSize(3)/2)+1:BlockSize(3)
%             out_window(i,j,k) = -1;
%         end
% 	end
% end
% Feature3D(:,:,:,count) = out_window;
% % count = count + 1;