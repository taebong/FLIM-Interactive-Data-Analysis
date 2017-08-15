function y = bh_isvalid(filename)

    BH_HEADER_CHKSUM = 21930;  % decimal, 0x55aa hex
    BH_HEADER_SIZE = 20; % header size in 16bit word units without chk_sum

    fid = fopen(filename);
    checksum = fread(fid,BH_HEADER_SIZE,'uint16=>uint32');    
    chk_sum_file = fread(fid,1,'uint16=>uint32');
    fclose(fid);

    if rem(chk_sum_file+sum(checksum), 65536) == BH_HEADER_CHKSUM
        y = true;
    else
        y = false;
    end
end