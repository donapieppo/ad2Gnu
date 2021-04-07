module AD2Gnu
class Samba
def Samba.SidToString(sid)

  return nil unless sid[0,1].unpack("C")[0] == 1
  return nil unless sid.length == 8 + 4 * sid[1,1].unpack("C")[0]

  sid_str = "S-1-"

  sid_str += sid[7,1].unpack("C")[0].to_s +
             (sid[6,1].unpack("C")[0] << 8).to_s +
             (sid[5,1].unpack("C")[0] << 16).to_s +
             (sid[4,1].unpack("C")[0] << 24).to_s

  (0 .. sid[1,1].unpack("C")[0] - 1).each do |l|
    sid_str += "-" + sid[4 * l + 8, 4].unpack("I")[0].to_s
  end

  sid_str
end
end
end
