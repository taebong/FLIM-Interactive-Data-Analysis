%% BH_GETDATABLOCK V 0.93
% BH_GETDATABLOCK reads data blocks from Becker & Hickl .sdt files.
%
%%% Syntax
%   data = BH_GETDATABLOCK(sp_struct, block_no)
%       Reads the data block specified by block no. and the 
%       sp_struct obtained by calling bh_readsetup on an .sdt file 
function data = bh_getdatablock(sp, block_no)
%  BH_GETDATABLOCK reads data blocks from Becker & Hickl .sdt files.
%
%  data = BH_GETDATABLOCK(sp_struct, block_no)
%       Reads the data block specified by block no. and the sp_struct obtained 
%       by calling bh_readsetup on an .sdt file 

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
    
    % Creation modes
    NOT_USED             = 0;
    MEAS_DATA            = 1;  % normal measurement modes
    FLOW_DATA            = 2;  % continuos flow measurement ( BIFL )  
    MEAS_DATA_FROM_FILE  = 3;
    CALC_DATA            = 4;  % calculated data
    SIM_DATA             = 5;  % simulated data
    FIFO_DATA            = 8;  % FIFO mode data
    FIFO_DATA_FROM_FILE  = 9;  % FIFO mode data
    MOM_DATA             =10;  % moments mode data
    MOM_DATA_FROM_FILE   =11;

    DATA_USHORT = 0;
    DATA_ULONG = 256;
    DATA_DBL = 512; 
    DATA_MASK = 3840;
    
    blk = bh_blockinfo(sp);
    block_no = abs(round(block_no));
    if block_no > size(blk)
        data = [];
        return
    end
    
    fid = fopen(sp.filename);
    fseek(fid,blk{block_no}.data_offs,-1);
    meas_creat = bitand(blk{block_no}.block_type, 15);
    meas_mode = bitand(blk{block_no}.block_type, 240);
    meas = bh_getmeasdesc(sp,blk{block_no}.meas_desc_block_no+1);
    
    data_type = bitand(blk{block_no}.block_type, DATA_MASK);
    
    type_str = '';
    type_len = 0; 
    
    switch data_type
        case DATA_USHORT
            type_str = 'uint16=>uint16';
            type_len = 2;
        case DATA_ULONG
            type_str = 'uint32=>uint32';
            type_len = 4;
        case DATA_DBL
            type_str = 'double=>double';
            type_len = 8;
        otherwise
            data = [];
            disp('Data type not recognized cannot read block');
            fclose(fid)
            return
    end
    switch meas_mode
        case IMG_BLOCK
            if meas_creat == 8 || meas_creat == 9
                no_of_curves = uint32(blk{block_no}.block_length)/uint32(meas.adc_re)/type_len;
                % zip compressed blocks
                if bitget(blk{block_no}.block_type, 13)
                    %disp('Reading compressed data block ...')
                    zipbuf = fread(fid, blk{block_no}.next_block_offs-blk{block_no}.data_offs, 'uint8=>uint8');
                    fn = [tempname() '.zip']; 
                    tmp_fid = fopen(fn,'w');
                    fwrite(tmp_fid, zipbuf);
                    fclose(tmp_fid); 
                    unzip(fn);
                    % get filesize
                    % s = dir('myfile.dat');
                    % fid = fopen('myfile.dat');
                    % filesize = s.bytes;     
                    tmp_fid = fopen('data_block', 'r');
                    data = fread(tmp_fid, blk{block_no}.block_length/type_len, type_str);
                    fclose(tmp_fid);
                    delete (fn);
                    delete 'data_block';
                    %disp('Reading compressed block done.');
                % end zip decomp
                else
                    data = fread(fid, blk{block_no}.block_length/type_len, type_str);
                end
                if no_of_curves == meas.image_x*meas.image_y
                    data = reshape(data, meas.adc_re, meas.image_y, meas.image_x);
                else
                    data = reshape(data, meas.adc_re, no_of_curves);
                end
            else
                data = [];
                disp('Cannot read data block');
                fclose(fid); 
                return
            end
        case {DECAY_BLOCK, PAGE_BLOCK}
            data = fread(fid, blk{block_no}.block_length/type_len, type_str);
            no_of_curves = uint32(blk{block_no}.block_length)/uint32(meas.adc_re)/type_len;
            if no_of_curves == meas.scan_x*meas.scan_y
                data = reshape(data, meas.adc_re, meas.scan_y, meas.scan_x);
            else
            data = reshape(data, meas.adc_re, no_of_curves);
            end
        case FCS_BLOCK
            points = meas.fcs_points;
            data = fread(fid, 2*points, type_str);
            data = reshape(data, points,2);
        case MCS_BLOCK
            data = fread(fid, meas.hist_mcs_points, type_str);
        case FIDA_BLOCK
            data = fread(fid, meas.hist_fida_points, type_str);
        case FILDA_BLOCK
            data = fread(fid, meas.hist_filda_points, type_str);
        case MCS_TA_BLOCK
            data = fread(fid, meas.hist_mcsta_points, type_str);
        case IMG_MCS_BLOCK
            data = fread(fid, blk{block_no}.block_length/type_len, type_str);
             no_of_curves = uint32(blk{block_no}.block_length)/uint32(meas.hist_mcsta_points)/type_len;
             if no_of_curves == meas.image_x*image_y
                 data = reshape(data, meas.hist_mcsta_points, image_y, image_x);
             else
                 dat = reshape(data, meas.hist_mcsta_points, no_of_curves);
             end
        otherwise
            
            data = []; 
            disp ('Many things to do...Filetype invalid or not yet supported');
    end
        
    
    fclose(fid);
    
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
