require "spec_helper"
require "ad2gnu"

describe AD2Gnu::AD do
  before(:all) do
    @ad2gnu = AD2Gnu::Base.new(:personale).ad_login
  end

  it "#get_user_by_upn pietro.donatini@unibo.it returns AD2Gnu::ADUser" do
    expect(@ad2gnu.ad.get_user_by_upn("pietro.donatini@unibo.it")).to be_a(AD2Gnu::ADUser)
  end

  it "#get_user_by_upn pietro.donatini@unibo.it returns AD2Gnu::ADUser with idAnagraficaUnica=436108" do
    expect(@ad2gnu.ad.get_user_by_upn("pietro.donatini@unibo.it").idAnagraficaUnica).to eq("436108")
  end

  it "#get_user_by_id 436108 returns AD2Gnu::ADUser with upn=pietro.donatini@unibo.it" do
    expect(@ad2gnu.ad.get_user_by_id(436108).upn).to eq("pietro.donatini@unibo.it")
  end

  it "#get_users_from_cn CN=Str01931.Personale.OptBase returns hash with pietro.donatini as key" do
    res = @ad2gnu.ad.get_users_from_cn("Str01931.Personale.OptBase")
    expect(res["pietro.donatini"].idAnagraficaUnica).to eq("436108")
  end

  # it "#get_dn_from_uid returns pietro.donatini -> uid=pietro.donatini,@base" do
  #   expect(@ad2gnu.local.get_dn_from_uid("pietro.donatini")).to eq("uid=pietro.donatini,#{@ad2gnu.local.base}")
  # end
  #
  # it "#get_dn_from_uid for unexistent uid returns pietro.donatini -> nil" do
  #   expect(@ad2gnu.local.get_dn_from_uid("pietro.donatini123")).to eq(nil)
  # end
  #
  # it "#get_dn_from_uidNumber 436108 -> uid=pietro.donatini,@base" do
  #   expect(@ad2gnu.local.get_dn_from_uidNumber("436108")).to eq("uid=pietro.donatini,#{@ad2gnu.local.base}")
  # end
  #
  # it "#get_group returns AD2Gnu::LocalGroup" do
  #   expect(@ad2gnu.local.get_group("matematica")).to be_a(AD2Gnu::LocalGroup)
  # end
  #
  # it "#exists? accept AD2Gnu::ADUser or string" do
  #   expect(@ad2gnu.local.get_group("pippo")).to be_a(AD2Gnu::LocalGroup)
  # end

  # it "#check_user_in_group returns true if present" do
  #   @ad2gnu.local.groups.each do |group|
  #     p group
  #   end
  # end
end
