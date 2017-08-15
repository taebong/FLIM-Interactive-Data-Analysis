function MultiD_tiff_convert(path, AniBool)
% Take sdt files sorted by 'MultiD_sdt_sort', get integrated intensity
% images by summing along time domain, save them as tiffs in a subfolder.

% 1 tiff folder for each Pos folder that has all images in that folder in order of z, t
% If it is 1-chan data, just z slices of that one channel
% If it is 2-chan data (NADH and FAD), then concatenate the image pairs side-by-side
% path - the path to the main acquisition folder
% clear all;
% path = 'C:\Users\Tim\Documents\Academic - Research\Data\2014-04-30 MultiD Cemb\S1\';
% AniBool=0;

% Version: Parallelize. Much quicker.

if path(end)~='\'; path = [path '\']; end;
if ~exist('AniBool') AniBool = 0; end
slashes = strfind(path,'\');
Run = path(slashes (end-1)+1:end-1);
sdtpath = [path 'sorted_sdts\'];
Dpos = dir(sdtpath); Dpos(1:2)=[]; Dpos(~[Dpos.isdir])=[];
remove = [];
for i = 1:length(Dpos)
    if length(Dpos(i).name)>5
        remove = [remove i];
    end
end
Dpos(remove)=[];
block_1=1;
block_2=2;
% load nameinds. If frames were partially converted before, Stack frame
% correspondence in column 6 should still be there, so function will pick
% up where it left off.
load([path 'name_indexes.mat']);

for posnum = 1:length(Dpos)
    Dnad = dir([sdtpath Dpos(posnum).name '\*NADH*.sdt']);
    Dfad = dir([sdtpath Dpos(posnum).name '\*FAD*.sdt']);
    D = dir([sdtpath Dpos(posnum).name '*.sdt']);
    sdtL = max([length(Dnad) length(Dfad) length(D)]);
    tifpath = [sdtpath 'IntTiffs_' Dpos(posnum).name '_' Run '\'];
    [a,b] = mkdir(tifpath);
    Dtiffs = dir(tifpath); Dtiffs(1:2)=[];
    uManPosNum = str2num(Dpos(posnum).name(4:end)); 
    % See if a tiff conversion was started before. If so, determine which
    % tiffs have not been converted yet and convert those.
    % ALSO, refill in the correspondence in 'nameinds'. If it errored out
    % previously, nameinds may not have been saved.
    frs2do = 1:sdtL;
    inds=cell(sdtL,1);
    if ~isempty(Dtiffs)
        for k = 1:length(Dtiffs)
            frnum = str2num(Dtiffs(k).name(3:7));
            frs2do(frs2do==frnum)=[];
            
            %             nsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dnad(frnum).name]);
            %             fsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dfad(frnum).name]);
            %             ve = nsdt.Version;
            if ~isempty(Dnad) % Only NADH images taken
                dashes = strfind(Dnad(frnum).name,'_');
                t = str2num(Dnad(frnum).name(dashes(1)+1:dashes(2)-1));
                z = str2num(Dnad(frnum).name(dashes(3)+1:end-4));
%                 if t==5 & z ==1
%                     disp('')
%                 end
            elseif ~isempty(Dfad)
                dashes = strfind(Dfad(frnum).name,'_');
                t = str2num(Dfad(frnum).name(dashes(1)+1:dashes(2)-1));
                z = str2num(Dfad(frnum).name(dashes(3)+1:end-4));
            else
                error('Dnad and Dfad both empty')
            end
            inds{frnum} = ([nameinds{:,2}]==uManPosNum)&([nameinds{:,3}]==t)&([nameinds{:,5}]==z);
        end
    end
    
    % If both channels are present, construct a side-by-side stack.
    % Otherwise just do the one channel
    if ~isempty(Dnad)&~isempty(Dfad)
        % If acquisition was stopped part way through, just go up to
        % the last frame that had both NADH and FAD.
        sdtL = min([length(Dnad) length(Dfad)]);
        test = cell(sdtL,1);
        % parfor i = ind1:sdtL % Set up for par once that's fixed in
        % Matlab
        for i = 1:sdtL
            % Save time by skipping frames that were already done
            if isempty(find(frs2do==i))
                continue;
            end
%             try
            test{i} = i;
            nsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dnad(i).name]);
            fsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dfad(i).name]);
            ve = nsdt.Version;
            dashes = strfind(Dnad(i).name,'_');
            t = str2num(Dnad(i).name(dashes(1)+1:dashes(2)-1));
            z = str2num(Dnad(i).name(dashes(3)+1:end-4));
            disp(['t' num2str(t) ', Pos' num2str(uManPosNum) ', z' num2str(z)]);
            
            % Find correct nameind index and fill in the new stack
            % frame number. Define inds in a cell so code can run
            % in parallel
            inds{i} = ([nameinds{:,2}]==uManPosNum)&([nameinds{:,3}]==t)&([nameinds{:,5}]==z);
            % Check Column 7 for '-1' flag. If it's not there, write the
            % tiff
            if ~isempty(find(cell2mat(nameinds(inds{i},7))==-1))
                continue;
            end
            % Only look at NADH image. If it's a fifo image, the corresponding FAD
            % better be, too.
            %             try
            nadch1 = bh_getdatablock_v095(nsdt,block_1);
            nadch1 = squeeze(sum(nadch1,1));
            fadch1 = bh_getdatablock_v095(fsdt,block_1);
            fadch1 = squeeze(sum(fadch1,1));
            % If either image is empty, skip this frame
            if isempty(find(nadch1))|isempty(find(fadch1))
                nameinds(inds{i},[7 8]) = num2cell(-1);
                continue;
            end
            if AniBool
                nadch2 = bh_getdatablock_v095(nsdt,block_2);
                nadch2 = squeeze(sum(nadch2,1));
                fadch2 = bh_getdatablock_v095(fsdt,block_2);
                fadch2 = squeeze(sum(fadch2,1));
                if str2num(ve(1))==3 % File is a fifo image
                    %                             Stk(i).data = uint8([(nadch1+nadch2) (fadch1+fadch2)]);
                    im = uint8([(nadch1+nadch2) (fadch1+fadch2)]);
                else
                    error('Data type not a fifo image');
                end
            else
                if str2num(ve(1))==3
                    %                             Stk(i).data = uint8([(nadch1) (fadch1)]);
                    im = uint8([(nadch1) (fadch1)]);
                else
                    error('Data type not a fifo image');
                end
            end
            imwrite(im,[tifpath 'fr' num2str(i,'%05i') '.tif'],'tiff','Compression','none');
            
            fclose('all');
%             catch
%             end
        end
        
        % When tiff conversions are finally finished, fill in all the
        % nameinds and save below
        for i = 1:length(inds)
            if ~isempty(inds{i})
                indall = find(inds{i}); %Include flagged entries (-1)
                indnonflag = find(inds{i}&[nameinds{:,7}]>-1); %Exclude -1's
                Nindfin = indall(strcmp(nameinds(indall,4),'NADH'));
                Findfin = indall(strcmp(nameinds(indall,4),'FAD'));
                nameinds(indall,6) = num2cell(i);
                if size(indnonflag,2)==size(indall,2) % Neither NADH or FAD flagged
                    % Enter number of scans integrated to make intensity matrix as
                    % the 8th column of this accounting tool
                    nsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dnad(i).name]);
                    nmeas = bh_getmeasdesc(nsdt, block_1);
                    nameinds(Nindfin,8) = num2cell(nmeas.hist_fida_points);
                    fsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dfad(i).name]);
                    fmeas = bh_getmeasdesc(fsdt, block_1);
                    nameinds(Findfin,8) = num2cell(fmeas.hist_fida_points);
                else % One is flagged, so this frame is bad. Flag the other, too
                    nameinds(Nindfin,[7 8]) = num2cell(-1);
                    nameinds(Findfin,[7 8]) = num2cell(-1);
                end
            end
        end
    else
        i=1;
        for i = 1:sdtL
            if isempty(find(frs2do==i))
                continue;
            end
            if ~isempty(Dnad) % Only NADH images taken
                sdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dnad(i).name]);
                dashes = strfind(Dnad(i).name,'_');
                t = str2num(Dnad(i).name(dashes(1)+1:dashes(2)-1));
                z = str2num(Dnad(i).name(dashes(3)+1:end-4));
            end
            if ~isempty(Dfad)% Only FAD images taken
                sdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dfad(i).name]);
                dashes = strfind(Dfad(i).name,'_');
                t = str2num(Dfad(i).name(dashes(1)+1:dashes(2)-1));
                z = str2num(Dfad(i).name(dashes(3)+1:end-4));
            end
            ve = sdt.Version;
            
            disp(['t' num2str(t) ', Pos' num2str(uManPosNum) ', z' num2str(z)]);
            % Find correct nameind index and fill in the new stack
            % frame number
            inds{i} = ([nameinds{:,2}]==uManPosNum)&([nameinds{:,3}]==t)&([nameinds{:,5}]==z);
            
            % Only look at NADH image. If it's a fifo image, the corresponding FAD
            % better be, too.
            ch1 = bh_getdatablock_v095(sdt,block_1);
            ch1 = squeeze(sum(ch1,1));
            % If either image is empty, skip this frame
            if isempty(find(ch1))
                nameinds(inds{i},[7 8]) = num2cell(-1);
                continue;
            end
            if AniBool
                ch2 = bh_getdatablock_v095(sdt,block_2);
                ch2 = squeeze(sum(ch2,1));
                if str2num(ve(1))==3 % File is a fifo image
                    im = uint8(ch1+ch2);
                else
                    error('Data type not a fifo image');
                end
            else
                if str2num(ve(1))==3
                    im = uint8(ch1);
                else
                    error('Data type not a fifo image');
                end
            end
            imwrite(im,[tifpath 'fr' num2str(i,'%05i') '.tif'],'tiff','Compression','none');
            
            %             catch
            %                 disp(['Fr' num2str(i) ' failed.'])
            %             end
            fclose('all');
        end
        % When tiff conversions are finally finished, fill in all the
        % nameinds and save below
        for i = 1:length(inds)
            if i == 323
                disp('')
            end
            if ~isempty(inds{i})
                indall = find(inds{i}); %Include flagged entries (-1)
                indnonflag = find(inds{i}&[nameinds{:,7}]>-1); %Exclude -1's
                Nindfin = indall(strcmp(nameinds(indall,4),'NADH'));
                Findfin = indall(strcmp(nameinds(indall,4),'FAD'));
                nameinds(indall,6) = num2cell(i);
                if size(indnonflag,2)==size(indall,2) % Neither NADH or FAD flagged
                    % Enter number of scans integrated to make intensity matrix as
                    % the 8th column of this accounting tool
                    if ~isempty(Dnad) % Only NADH images taken
                        nsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dnad(i).name]);
                        nmeas = bh_getmeasdesc(nsdt, block_1);
                        nameinds(Nindfin,8) = num2cell(nmeas.hist_fida_points);
                    end
                    if ~isempty(Dfad) % Only NADH images taken
                        fsdt = bh_readsetup([sdtpath Dpos(posnum).name '\' Dfad(i).name]);
                        fmeas = bh_getmeasdesc(fsdt, block_1);
                        nameinds(Findfin,8) = num2cell(fmeas.hist_fida_points);
                    end
                else % One is flagged, so this frame is bad. Flag the other, too
                    nameinds(Nindfin,[7 8]) = num2cell(-1);
                    nameinds(Findfin,[7 8]) = num2cell(-1);
                end
            end
        end
    end
    
end
% Any file not converted to a tiff will still have '-1' in column 6.
% Propagate that flage to columns 7 and 8 to exclude from future processing
nameinds([nameinds{:,6}]==-1,[7 8]) = num2cell(-1);
save([path 'name_indexes.mat'],'nameinds')
