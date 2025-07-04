require "spec_helper"
require "ad2gnu"

describe AD2Gnu::Local do
  before(:all) do
    @ad2gnu = AD2Gnu::Base.new(:personale).local_login
  end

  it "#users returns array of AD2Gnu::LocalUser" do
    expect(@ad2gnu.local.users).to all(be_a(AD2Gnu::LocalUser))
  end

  it "#groups returns array of AD2Gnu::LocalGroup" do
    expect(@ad2gnu.local.groups).to all(be_a(AD2Gnu::LocalGroup))
  end

  it "#get_user returns AD2Gnu::LocalUser" do
    expect(@ad2gnu.local.get_user("pietro.donatini")).to be_a(AD2Gnu::LocalUser)
  end

  it "#get_dn_from_uid pietro.donatini returns uid=pietro.donatini,@base" do
    expect(@ad2gnu.local.get_dn_from_uid("pietro.donatini")).to eq("uid=pietro.donatini,#{@ad2gnu.local.base}")
  end

  it "#get_dn_from_uid for unexistent uid returns nil" do
    expect(@ad2gnu.local.get_dn_from_uid("pietro.donatini123")).to eq(nil)
  end

  it "#get_dn_from_uidNumber 436108 -> uid=pietro.donatini,@base" do
    expect(@ad2gnu.local.get_dn_from_uidNumber("436108")).to eq("uid=pietro.donatini,#{@ad2gnu.local.base}")
  end

  it "#get_group matematica returns AD2Gnu::LocalGroup" do
    expect(@ad2gnu.local.get_group("matematica")).to be_a(AD2Gnu::LocalGroup)
  end

  # it "#exists? accept AD2Gnu::ADUser or string" do
  #   expect(@ad2gnu.local.get_group("pippo")).to be_a(AD2Gnu::LocalGroup)
  # end

  # it "#check_user_in_group returns true if present" do
  #   @ad2gnu.local.groups.each do |group|
  #     p group
  #   end
  # end
end
