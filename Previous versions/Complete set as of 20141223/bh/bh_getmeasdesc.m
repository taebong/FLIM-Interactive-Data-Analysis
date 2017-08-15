%% BH_GETMEASDESC V 0.93
% BH_GETMEASDESC reads measurement description blocks from .sdt files
%
%%% Syntax
% BH_GETMEASDESC reads measurement description blocks from .sdt files
% 
%   m = BH_GETMEASDESC(sp_struct, block_no)
%       returns a structure with information on the specified block of
%       the .sdt file specified by sp_struct which is obtained from a 
%       call to BH_READSETUP.
%       If the block_no is invalid [] is returned. 

function meas = bh_getmeasdesc(sp, blk_no)
% BH_GETMEASDESC reads measurement description blocks from .sdt files
% 
%   m = BH_GETMEASDESC(sp_struct, block_no)
%       returns a structure with information on the specified block of
%       the .sdt file specified by sp_struct which is obtained from a 
%       call to BH_READSETUP.
%       If the block_no is invalid [] is returned. 
    if ~isfield(sp, 'header_valid')
        meas = [];
        return
    end
    blk_no = round(blk_no);
    if (sp.no_of_meas_desc_blocks < blk_no )|| blk_no <1
        meas = [];
        return
    end
    
    fid = fopen(sp.filename);
    fseek(fid, sp.meas_desc_block_offs + int32(sp.meas_desc_block_length*(blk_no-1)),-1);
    
    meas.time = fread(fid, 9, 'char=>char')'; % time of creation
    meas.date = fread(fid,11,'char=>char')';  % date of creation
    meas.mod_ser_no =  fread(fid,16,'char=>char')'; % serial number of the module */
    meas.meas_mode = fread(fid,1,'int16=>int16');
    meas.cfd_ll = fread(fid,1, 'float=>float');
    meas.cfd_lh = fread(fid,1, 'float=>float');
    meas.cfd_zc = fread(fid,1, 'float=>float');
    meas.cfd_hf = fread(fid,1, 'float=>float');
    meas.syn_zc = fread(fid,1, 'float=>float');
    meas.syn_fd = fread(fid,1, 'int16=>int16');
    meas.syn_hf = fread(fid,1, 'float=>float');
    meas.tac_r = fread(fid,1, 'float=>float');
    meas.tac_g = fread(fid,1, 'int16=>int16');
    meas.tac_of = fread(fid,1, 'float=>float');
    meas.tac_ll = fread(fid,1, 'float=>float');
    meas.tac_lh = fread(fid,1, 'float=>float');
    meas.adc_re = fread(fid,1, 'int16=>int16');
   
    meas.eal_de = fread(fid,1, 'int16=>int16');
    meas.ncx = fread(fid,1, 'int16=>int16');
    meas.ncy = fread(fid,1, 'int16=>int16');
    meas.page = fread(fid,1, 'uint16=>uint16');
    meas.col_t = fread(fid,1, 'float=>float');
    meas.rep_t = fread(fid,1, 'float=>float');
    meas.stopt = fread(fid,1, 'int16=>int16');
    meas.overfl = fread(fid,1, 'char=>char');
    meas.use_motor = fread(fid,1, 'int16=>int16');
    meas.steps = fread(fid,1, 'uint16=>uint16');
    meas.offset = fread(fid,1, 'float=>float');
    meas.dither = fread(fid,1, 'int16=>int16');
    meas.incr = fread(fid,1, 'int16=>int16');
    meas.mem_bank = fread(fid,1, 'int16=>int16');
    meas.mod_type = fread(fid,16, 'char=>char')';
    meas.syn_th = fread(fid,1, 'float=>float');
    meas.dead_time_comp = fread(fid,1, 'int16=>int16');
    meas.polarity_l = fread(fid,1, 'int16=>int16'); % 2 = disabled line markers
    meas.polarity_f=fread(fid,1, 'int16=>int16');
    meas.polarity_p=fread(fid,1, 'int16=>int16');
    meas.linediv = fread(fid,1, 'int16=>int16'); % line predivider = 2 ** ( linediv)
    meas.accumulate = fread(fid,1, 'int16=>int16');
    meas.flbck_y = fread(fid,1, 'int32=>int32');
    meas.flbck_x = fread(fid,1, 'int32=>int32');
    meas.bord_u = fread(fid,1, 'int32=>int32');
    meas.bord_l = fread(fid,1, 'int32=>int32');
    meas.pix_time = fread(fid,1, 'float=>float');
	meas.pix_clk = fread(fid,1, 'int16=>int16');
    meas.trigger = fread(fid,1, 'int16=>int16');
    meas.scan_x = fread(fid,1, 'int32=>int32');
	meas.scan_y = fread(fid,1, 'int32=>int32');
    meas.scan_rx = fread(fid,1, 'int32=>int32');
    meas.scan_ry = fread(fid,1, 'int32=>int32');
    meas.fifo_typ = fread(fid,1, 'int16=>int16');
    meas.epx_div = fread(fid,1, 'int32=>int32');
    meas.mod_type_code = fread(fid,1, 'uint16=>uint16');
    saved_pos = ftell(fid);
    
    if sp.soft_rev > 789
        meas.mod_fpga_ver =  fread(fid,1, 'int16=>int16');
        meas.overflow_corr_factor = fread(fid,1, 'float=>float');
        meas.adc_zoom = fread(fid,1, 'int32=>int32');
        meas.cycles = fread(fid,1, 'int32=>int32');
        %MeasStopInfo
        meas.status = fread(fid,1, 'uint16=>uint16');
        meas.flags = fread(fid,1, 'uint16=>uint16');
        meas.stop_time = fread(fid,1, 'float=>float');
        meas.cur_step = fread(fid,1, 'int32=>int32');
        meas.cur_cycle = fread(fid,1, 'int32=>int32');
        meas.cur_page = fread(fid,1, 'int32=>int32');
        meas.min_sync_rate = fread(fid,1, 'float=>float');
        meas.min_cfd_rate = fread(fid,1, 'float=>float');
        meas.min_tac_rate = fread(fid,1, 'float=>float');
        meas.min_adc_rate = fread(fid,1, 'float=>float');

        meas.max_sync_rate = fread(fid,1, 'float=>float');
        meas.max_cfd_rate = fread(fid,1, 'float=>float');
        meas.max_tac_rate = fread(fid,1, 'float=>float');
        meas.max_adc_rate = fread(fid,1, 'float=>float');
        meas.reserved1 = fread(fid,1, 'int32=>int32');
        meas.reserved2 = fread(fid,1, 'float=>float');
    end
    if sp.soft_rev > 809
        % FCSInfo
        meas.fcs_chan = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_decay_calc = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_mt_resol = fread(fid,1 ,'uint32=>uint32');
        meas.fcs_cortime = fread(fid,1, 'float=>float');
        meas.fcs_calc_photons = fread(fid,1 ,'uint32=>uint32');
        meas.fcs_points = fread(fid, 1, 'int32=>int32');
        meas.fcs_end_time = fread(fid,1, 'float=>float');
        meas.fcs_overruns = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_type = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_cross_chan = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_mod = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_cross_mod = fread(fid,1 ,'uint16=>uint16');
        meas.fcs_cross_mt_resol = fread(fid,1, 'uint32=>uint32');
        % Fifo img
        meas.image_x = fread(fid, 1, 'int32=>int32');
        meas.image_y = fread(fid, 1, 'int32=>int32');
        meas.image_rx = fread(fid, 1, 'int32=>int32');
        meas.image_ry = fread(fid, 1, 'int32=>int32');
        meas.xy_gain = fread(fid,1 ,'int16=>int16');
        meas.dig_flags = fread(fid,1 ,'int16=>int16');
        meas.adc_de = fread(fid,1 ,'int16=>int16');
        meas.det_type = fread(fid,1 ,'int16=>int16');
        meas.x_axis = fread(fid,1 ,'int16=>int16');
    end
    if sp.soft_rev > 839
        meas.hist_fida_time = fread(fid,1, 'float=>float');
        meas.hist_filda_time = fread(fid,1, 'float=>float');
        meas.hist_fida_points = fread(fid, 1, 'int32=>int32');
        meas.hist_filda_points = fread(fid, 1, 'int32=>int32');
        meas.hist_mcs_time = fread(fid,1, 'float=>float');
        meas.hist_mcs_points = fread(fid, 1, 'int32=>int32');
        meas.hist_cross_calc_phot = fread(fid, 1, 'uint32=>uint32');
        meas.hist_mcsta_points = fread(fid,1 ,'uint16=>uint16');
        meas.hist_mcsta_flags = fread(fid,1 ,'uint16=>uint16');
        meas.hist_mcsta_tpp = fread(fid, 1, 'uint32=>uint32');
        meas.hist_calc_markers = fread(fid, 1, 'uint32=>uint32');
        meas.hist_reserved3 = fread(fid,1, 'double');
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
