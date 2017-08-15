%% BH_BLOCKINFO V 0.93
% BH_BLOCK_INFO extracts information from Becker&Hickl .sdt and lists  
% the data block types contained. 
%%% Syntax
%   BH_BLOCKINFO(sp_struct) returns an array of structures containing 
%       information on the measurement blocks in an .sdt file and prints 
%       a description of the block contents.
%       
%       sp_struct     - structure returned from a call to <bh_readsetup>
% 
%       return value - Structure array with one elemet for each block.
%                       soft_rev - SPCM version no.
%                       modules - no. of SPC modules used
%                       filename - name of  the file. Used in calls
%                                  to bh_getdatablock etc.
%                      If filename is no valid .sdt/.set file the 
%                      return value is [].
%
%   Most of the time this is needed to get an overview of the file
%   contents. The actual data can be read using <BH_GETDATABLOCK>
%
function blk_info = bh_blockinfo(sp, varargin)
% BH_BLOCK_INFO extracts information from Becker&Hickl .sdt and lists  
% the data block types contained. 
%

    % Block Types
    DECAY_BLOCK = 0;           % one decay curve
    PAGE_BLOCK  = 16;          % set of decay curves = measured page
    FCS_BLOCK   = 32;          % FCS histogram curve                 
    FIDA_BLOCK  = 48;          % FIDA histogram curve                 
    FILDA_BLOCK = 64;          % FILDA histogram curve                 
    MCS_BLOCK   = 80;          % MCS histogram curve
    IMG_BLOCK   = 96;          % fifo image - set of curves = PS FLIM
    MCSTA_BLOCK = 112;         % MCS Triggered Accumulation histogram curve                 
    IMG_MCS_BLOCK=128;         % fifo image - set of curves = MCS FLIM
    MOM_BLOCK   = 144;         % moments mode - set of moments data frames
    
    if sp.no_of_data_blocks <= 0
        return
    end
    blk_info = {};
    data = struct;
    if ~bh_isvalid(sp.filename)
        return
    end
    fid = fopen(sp.filename);
    % read bh_file_block_header
    
    block.next_block_offs = sp.data_block_offs;
    
    for i=1:sp.no_of_data_blocks
        fseek(fid,block.next_block_offs,-1);

        block.block_no = fread(fid,1,'uint16=>uint16');
        block.data_offs = fread(fid,1, 'int32=>int32');
        block.next_block_offs = fread(fid,1, 'int32=>int32');
        block.block_type = fread(fid,1,'uint16=>uint16');
        block.meas_desc_block_no = fread(fid,1,'int16=>int16');
        block.lblock_no = fread(fid,1,'uint32=>uint32');
        block.block_length = fread(fid,1, 'uint32=>uint32');

        if block.block_no >= hex2dec('7ffe')
            block.block_no = block.lblock_no;
        end

        data = block; 

        meas_mode = bitand(block.block_type, 240); % get bits 5-8

        switch meas_mode
            case DECAY_BLOCK
                data.mode = 'Single curve Measurement';
            case PAGE_BLOCK
                data.mode = 'Set of curve';
            case FCS_BLOCK
                data.mode = 'FCS curve';
            case IMG_BLOCK
                data.mode = 'ps FLIM image (FIFO_IMG)';
            case IMG_MCS_BLOCK
                data.mode = 'MCS FLIM (FIFO_IMG)';
            case FIDA_BLOCK
                data.mode = 'FIDA histogram curve';
            case FILDA_BLOCK
                data.mode = 'FILDA histogram curve';
            case MCSTA_BLOCK
                data.mode = 'MCS Triggered Acc. histogram curve';
            case MOM_BLOCK
                data.mode = 'Moments mode';
            case MCS_BLOCK
                data.mode = 'MCS histogram curve';
            otherwise
                data.mode = 'unknown';
        end
        disp( sprintf('%d: %s', i, data.mode));
        blk_info{i} = data;
    end
end
function y = bh_isvalid(filename)

    BH_HEADER_CHKSUM = 21930;  % decimal, 0x55aa hex
    BH_HEADER_SIZE = 20; % header size in 16bit word units without chk_sum

    fid = fopen(filename);
    if fid == -1
        y = false;
        return
    end
    checksum = fread(fid,BH_HEADER_SIZE,'uint16=>uint32');    
    chk_sum_file = fread(fid,1,'uint16=>uint32');
    fclose(fid);
    if rem(chk_sum_file+sum(checksum), 65536) == BH_HEADER_CHKSUM
        y = true;
    else
        y = false;
    end
end
%% License Agreement
% Copyright (c) 2010, Becker & Hickl GmbH.
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright
%   notice, this list of conditions and the following disclaimer.
% * Redistributions in binary form must reproduce the above copyright
%   notice, this list of conditions and the following disclaimer in the
%   documentation and/or other materials provided with the distribution.
% * Neither the name of the Becker & Hickl GmbH (B&H) nor the names of its 
%   contributors may be used to endorse or promote products derived from 
%   this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. 
% IN NO EVENT SHALL B&H BE LIABLE FOR ANY DIRECT, INDIRECT, 
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
% NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
