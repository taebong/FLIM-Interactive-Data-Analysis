%% BH_READSETUP v.0.93
% BH_READSETUP reads setup parameters from a B&H .set or .sdt file
%%% Syntax
%   BH_READSETUP(filename) returns a structure containing various 
%       setup parameters from .set or .sdt files. For .sdt files this 
%       structure is used in calls to bh_getdatablock and related 
%       functions to read data blocks and measurement details.
%
%       filename     - Full name of .sdt or .set file including the 
%                     file extension and the full path if not in the
%                     current directory.
% 
%       return value - Structure containing various setup parameters: 
%                       soft_rev - SPCM version no.
%                       modules - no. of SPC modules used
%                       filename - name of  the file. Used in calls
%                                  to bh_getdatablock etc.
%                      If filename is no valid .sdt/.set file the 
%                      return value is [].
function sp = bh_readsetup(filename)
% BH_READSETUP reads setup parameters from a B&H .set or .sdt file
% 
%   SP = BH_READSETUP(FILENAME) returns a structure containing various 
%   setup parameters from .set or .sdt files. For .sdt files this 
%   structure is used in calls to bh_getdatablock and related 
%   functions to read data blocks and measurement details.

    if ~bh_isvalid(filename)
        sp = [];
        return;
    end
    
    fid = fopen(filename);    
    % 1. Read bh_file_header
    sp.revision = fread(fid,1,'int16=>int16');
    sp.info_offs = fread(fid, 1, 'int32=>int32');
    sp.info_length = fread(fid,1,'int16=>int16');
    sp.setup_offs = fread(fid,1, 'int32=>int32');
    sp.setup_length = fread(fid,1,'int16=>int16');
    sp.data_block_offs = fread(fid,1,'int32=>int32');
    sp.no_of_data_blocks = fread(fid,1,'int16=>int16');
    sp.data_block_length = fread(fid,1,'int32=>int32');
    sp.meas_desc_block_offs = fread(fid,1,'int32=>int32');
    sp.no_of_meas_desc_blocks = fread(fid,1,'int16=>int16');
    sp.meas_desc_block_length = fread(fid,1,'int16=>int16');
    sp.header_valid = fread(fid,1,'uint16=>uint16');
    sp.reserved1 = fread(fid,1,'uint32=>uint32');
    sp.reserved2 = fread(fid,1,'uint32=>uint32');
    sp.chksum = fread(fid,1,'uint16=>uint16');
    sp.filename = filename;
    sp.modules = 1;
    % 2. Read ASCII setup
    fseek(fid, sp.setup_offs, -1);
    text_line = '';
    
    while ~feof(fid) && ~strcmp(text_line,'*END')
       text_line = fgetl(fid);
       strfields = regexp(text_line, ...
           '(\s+#\w+\s+)\[(\S+),(\S+),(\S+)\]','tokens', 'once');
       if size(strfields,2)~=4
           continue
       end
       switch strfields{2}
           case {
                   'SP_MODE', ...
                   'SP_CFD_LL', ...
                   'SP_CFD_LH',...
                   'SP_CFD_ZC', ...
                   'SP_CFD_HF', ...
                   'SP_SYN_ZC', ...
                   'SP_SYN_FD', ...
                   'SP_SYN_FQ', ...
                   'SP_SYN_HF', ...
                   'SP_TAC_R', ...
                   'SP_TAC_G', ...
                   'SP_TAC_OF', ...
                   'SP_TAC_LL', ...
                   'SP_TAC_LH', ...
                   'SP_TAC_TC', ...
                   'SP_TAC_TD', ...
                   'SP_ADC_RE', ...
                   'SP_EAL_DE', ...
                   'SP_FIF_FNO', ...
                   'SP_FIF_TYP', ...
                   'SP_BORD_U', ...
                   'SP_BORD_L', ...
                   'SP_PIX_T', ...
                   'SP_IMG_X', ...
                   'SP_IMG_Y', ...
                   'SP_EPX_DIV', ...
                   'SP_LDIV', ...
                   'SP_PIX', ...
                   'SP_SPE_FN', ...
                   'SP_ROUT', ...
                   'SP_SCAN_X', ...
                   'SP_SCAN_Y', ...
                   }
               switch strfields{3}
                   case 'F'
                    sp.(strfields{2}) = str2double(strfields{4});
                   case 'I'
                       sp.(strfields{2}) = int32(str2double(strfields{4}));
                   case 'B'
                       if strcmp(strfields{4},1)
                           sp.(strfields{2}) = true;
                       else
                           sp.(strfields{2}) = false;
                       end
                   otherwise
                       sp.(strfields{2}) = strfields{4};
               end    
           otherwise
       end
       if length(text_line)>6 ...
           && strcmp(text_line(3:5), '#MP') ...
           && ~isempty(str2double(text_line(6))) 
           sp.modules = str2double(text_line(6))+1;
       end
    end
    
    % 3. Read info text
    fseek(fid, sp.info_offs, -1);
    text_line = '';
    while ~feof(fid) && ~strcmp(text_line,'*END')
        text_line = fgetl(fid);
        strfields = regexp(text_line, ...
           '\s+(\S+)\s+:\s+(.*$)', 'tokens','once');
       if size(strfields,2)~=2
           continue
       end
       sp.(strfields{1}) = strfields{2};
    end
    
    % 4. Read binary setup
    fseek(fid, sp.setup_offs, -1);
    setup = fread(fid, sp.setup_length, 'uint8=>char');
    k = strfind(setup', 'BIN_PARA_BEGIN');
    fseek(fid, sp.setup_offs + int32(k+15),-1);
    % 4.1 bh_bin_hdr
    sp.binary_setup_length = fread(fid, 1, 'uint32=>uint32');
    sp.soft_rev = fread(fid,1,'uint32=>uint32');
    sp.bin_para_length = fread(fid,1,'uint32=>uint32');
    sp.bin_reserved1 = fread(fid, 1,'uint32=>uint32');
    sp.bin_reserved2 = fread(fid,1,'uint16=>uint16');
    % 4.2 SPCBinHdr
    if sp.soft_rev > 790
        bin_hdr.FCS_old_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.FCS_old_size = fread(fid,1,'uint32=>uint32');
        bin_hdr.gr1_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.gr1_size = fread(fid,1,'uint32=>uint32');
        bin_hdr.FCS_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.FCS_size = fread(fid,1,'uint32=>uint32');
        bin_hdr.FIDA_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.FIDA_size = fread(fid,1,'uint32=>uint32');
        bin_hdr.FILDA_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.FILDA_size = fread(fid,1,'uint32=>uint32');
        bin_hdr.gr2_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.gr_no = fread(fid,1,'uint16=>uint16');
        bin_hdr.hst_no = fread(fid,1,'uint32=>uint32');
        bin_hdr.hst_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.GVD_offs= fread(fid,1,'uint32=>uint32');
        bin_hdr.GVD_size = fread(fid,1,'uint16=>uint16');
        bin_hdr.FIT_offs = fread(fid,1,'uint16=>uint16');
        bin_hdr.FIT_size = fread(fid,1,'uint16=>uint16');
    end
    if sp.soft_rev > 899
        bin_hdr.extdev_offs = fread(fid,1,'uint16=>uint16');
        bin_hdr.extdev_size  = fread(fid,1,'uint16=>uint16');
        bin_hdr.binhdrext_offs = fread(fid,1,'uint32=>uint32');
        bin_hdr.binhdrext_size = fread(fid,1,'uint16=>uint16');
    end
    
    sp.binhdr = bin_hdr;

    % 4 ... parameters for various displays, curves etc.
    % Not implememnted yet
    
    % 5. Measurement description blocks
    
     
    fclose(fid);
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
