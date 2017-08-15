function grouped_decay_struct = GroupDecayStruct(decay_struct,newname)

if iscell(decay_struct)
    decay_struct = cell2mat(decay_struct);
end

decaymat = cell2mat({decay_struct.decay});
decaysum = sum(decaymat,2);
time = decay_struct(1).time;

if isfield(decay_struct,'filename')
    filename = [decay_struct.filename];
    grouped_decay_struct.filename = filename;
end

if isfield(decay_struct,'pathname')
    pathname = unique([decay_struct.pathname]);
    grouped_decay_struct.pathname = pathname;
end

if isfield(decay_struct,'flimblock')
    flimblock = unique(cell2mat({decay_struct.flimblock}));
    grouped_decay_struct.flimblock = flimblock;
end

if isfield(decay_struct,'setting')
    setting = {decay_struct.setting};
    grouped_decay_struct.setting = setting;
end

if isfield(decay_struct,'laserT')
    laserT = mean(cell2mat({decay_struct.laserT}));
    grouped_decay_struct.laserT = laserT;
end

grouped_decay_struct.name = newname;
grouped_decay_struct.time = time;
grouped_decay_struct.decay = decaysum;

grouped_decay_struct = DecayStructInitializer(grouped_decay_struct);